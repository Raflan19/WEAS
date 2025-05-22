import RPi.GPIO as GPIO
from flask import *
import cv2
import time
import threading
import os
import serial
import pyaudio
import pymysql
import datetime
import logging

ip = "192.168.0.100"
prt=3306
psw='root'
dbname='gadget'
ser = serial.Serial('/dev/ttyUSB0', baudrate=9600, timeout=1)

try:
    con = pymysql.connect(host=ip, port=prt, user='root', passwd=psw, db=dbname, charset='utf8')
    cmd = con.cursor()
    print("db connected")
except Exception as e:
    print(e)

flag1 = 0
# Set up GPIO for button press
GPIO.setmode(GPIO.BCM)  # Use BCM pin numbering
BUTTON_PIN = 21  # GPIO 21 for button press

# Set up the button pin as input with pull-up resistor
GPIO.setup(BUTTON_PIN, GPIO.IN, pull_up_down=GPIO.PUD_UP)

# OpenCV setup for video capture
cap = cv2.VideoCapture(0)  # Use the second camera (1)

# Create the Flask app
app = Flask(__name__, template_folder="templates")

VIDEO_FOLDER = os.path.join(app.static_folder, 'uploads')

# Audio setup constants
FORMAT = pyaudio.paInt16
CHANNELS = 2
RATE = 44100
CHUNK = 1024

audio_stream = pyaudio.PyAudio()

# Global variables to track button state and video writer
button_pressed = False
video_writer = None

latitude_degrees = " "
longitude_degrees = " "

# Configure logging
logging.basicConfig(level=logging.DEBUG)

@app.route('/videos/<filename>')
def serve_video(filename):
    app.logger.debug(f"Requested video: {filename}")
    video_path = os.path.join(VIDEO_FOLDER, filename)
    if os.path.exists(video_path):
        app.logger.debug(f"Serving video: {video_path}")
        return send_from_directory(directory=VIDEO_FOLDER, filename=filename, mimetype='video/mp4')
    app.logger.error(f"Video not found: {filename}")
    return jsonify({"error": "video not found"}), 404

@app.route('/list_videos')
def list_videos():
    videos = [f for f in os.listdir(VIDEO_FOLDER)
              if f.endswith('.mp4')]
    return jsonify({"videos":videos})

@app.route('/location_fetch', methods=['GET'])
def location_fetch():
    global latitude_degrees,longitude_degrees,ip
    global button_pressed
    con = pymysql.connect(host=ip, port=prt, user='root', passwd=psw, db=dbname, charset='utf8')
    cmd = con.cursor()
    if button_pressed:
        location = {"lat":latitude_degrees,
                    "lng":longitude_degrees}
    else:
        location = {"lat":"None",
                    "lng":"None"}
    return jsonify(location), 200

@app.route('/deletenotifications', methods=['DELETE'])
def deletenotifications():
    global ip
    con = pymysql.connect(host=ip, port=prt, user='root', passwd=psw, db=dbname, charset='utf8')
    cmd = con.cursor()
    cmd.execute("DELETE FROM noti")
    con.commit()
    return jsonify({"message": "All notifications deleted successfully"}), 200

@app.route('/notifications', methods=['GET'])
def notifications():
    global ip
    con = pymysql.connect(host=ip, port=prt, user='root', passwd=psw, db=dbname, charset='utf8')
    cmd = con.cursor()
    cmd.execute("SELECT id, msg FROM noti")
    notifications = cmd.fetchall()
    
    return jsonify(notifications), 200

@app.route('/previous_alerts', methods=['GET'])
def previous_alerts():
    global ip
    try:
        con = pymysql.connect(host=ip, port=prt, user='root', passwd=psw, db=dbname, charset='utf8')
        cmd = con.cursor()
        query = "SELECT filename, latitude, longitude, timestamp FROM notifications ORDER BY timestamp DESC"
        cmd.execute(query)
        alerts = cmd.fetchall()
        print(alerts)
        alerts_list = []
        for alert in alerts:
            alerts_list.append({
                'time': alert[3].strftime('%Y-%m-%d %H:%M:%S'),
                'latitude': alert[1],
                'longitude': alert[2],
                'videoUrl': alert[0]
            })
        print(alerts_list)
        return jsonify(alerts_list), 200
    except Exception as e:
        print(e)
        return jsonify({'error': str(e)}), 500


@app.route('/login', methods=['POST'])
def login():
    global ip
    con = pymysql.connect(host=ip, port=prt, user='root', passwd=psw, db=dbname, charset='utf8')
    cmd = con.cursor()
    data = request.get_json()
    print(data)
    email = data.get("username")
    password = data.get("password")

    if not email or not password:
        return jsonify({"error": "Email and password required"}), 400

    cmd.execute("SELECT id, username, password FROM login WHERE username = %s", (email,))
    user = cmd.fetchone()
    print(user)

    if user:  # Ensure a user was found
        if user[2] == password:  # Correctly access the password from the tuple
            return jsonify({
                "message": "Login successful", 

            }), 200
        else:
            return jsonify({"error": "Invalid password"}), 401
    else:
        return jsonify({"error": "User not found"}), 404

# Monitor the GPIO pin for button press
def monitor_button():
    global button_pressed, flag1
    while True:
        val = GPIO.input(BUTTON_PIN)
        if val == 0:  # Button pressed
            if flag1 == 0:  # Avoid multiple triggers
                flag1 = 1
                query = "INSERT INTO noti (msg) VALUES ('detect')"
                cmd.execute(query)
                con.commit()
                button_pressed = True  # Start recording
                threading.Thread(target=start_video_recording).start()
        else:
            if flag1 == 1:  # Button released
                flag1 = 0
                button_pressed = False  # Stop recording
        time.sleep(0.1)  # Debounce delay
        try:
            received_data = ser.readline().decode('utf-8') # Decode bytes to string
            if received_data.startswith('$GPGGA'):
                data_elements = received_data.split(',')
                latitude = data_elements[2]
                longitude = data_elements[4]

                if latitude:
                        # Convert latitude to degrees and decimal degrees
                    latitude_degrees = float(latitude[:2]) + float(latitude[2:]) / 60.0
                        
                        # Convert longitude to degrees and decimal degrees
                    longitude_degrees = float(longitude[:3]) + float(longitude[3:]) / 60.0
                else:
                    latitude_degrees = " "
                    longitude_degrees = " "

        except Exception as e:
            print("GPS read error:", e)
        except KeyboardInterrupt:
            sys.exit(0)


# Function to generate audio header for WAV file
def genHeader(sampleRate, bitsPerSample, channels):
    datasize = 2000 * 10**6
    o = bytes("RIFF", 'ascii')
    o += (datasize + 36).to_bytes(4, 'little')
    o += bytes("WAVE", 'ascii')
    o += bytes("fmt ", 'ascii')
    o += (16).to_bytes(4, 'little')
    o += (1).to_bytes(2, 'little')
    o += (channels).to_bytes(2, 'little')
    o += (sampleRate).to_bytes(4, 'little')
    o += (sampleRate * channels * bitsPerSample // 8).to_bytes(4, 'little')
    o += (channels * bitsPerSample // 8).to_bytes(2, 'little')
    o += (bitsPerSample).to_bytes(2, 'little')
    o += bytes("data", 'ascii')
    o += (datasize).to_bytes(4, 'little')
    return o

# Function to stream audio data
def Sound():
    global button_pressed
    bitspersample = 16
    wav_header = genHeader(RATE, bitspersample, CHANNELS)
    stream = audio_stream.open(format=FORMAT, channels=CHANNELS, rate=RATE, input=True, frames_per_buffer=CHUNK)
    first_run = True
    while True:
        if button_pressed:
            if first_run:
                data = wav_header + stream.read(CHUNK)
                first_run = False
            else:
                data = stream.read(CHUNK)
            yield data
        else:
            time.sleep(0.1)

@app.route("/")
def index():
    return render_template("index.html")

@app.route("/audio")
def audio():
    return Response(Sound(), mimetype="audio/wav")

# Function to generate frames for the video feed
def generate_frames():
    while True:
        if button_pressed:  # Only generate video frames if button is pressed
            ret, frame = cap.read()
            if not ret:
                continue

            # If video_writer is initialized, write frames to the video file
            if video_writer is not None:
                video_writer.write(frame)

            # Encode frame as JPEG
            success, buffer = cv2.imencode('.jpg', frame)
            if not success:
                continue

            # Convert buffer to bytes and yield it to the client
            frame_bytes = buffer.tobytes()
            yield (b'--frame\r\n'
                   b'Content-Type: image/jpeg\r\n\r\n' + frame_bytes + b'\r\n')
        else:
            time.sleep(0.1)  # If button not pressed, just wait

# Start video recording when the button is pressed
def start_video_recording():
    global video_writer
    # Set up VideoWriter object
    fourcc = cv2.VideoWriter_fourcc(*'mp4v')  # Codec for MP4 format
    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = f"output_video_{timestamp}.mp4"
    out_path = f"/home/pi/Gadget/static/uploads/{filename}"
    query = "INSERT INTO notifications (filename,latitude,longitude,timestamp) VALUES (%s,%s,%s,NOW())"
    cmd.execute(query, (filename,latitude_degrees,longitude_degrees))
    con.commit()
    video_writer = cv2.VideoWriter(out_path, fourcc, 20.0, (640, 480))

    # Record for 10 seconds
    start_time = time.time()
    while time.time() - start_time < 10:
        ret, frame = cap.read()
        if ret:
            video_writer.write(frame)

    stop_video_recording()

# Stop video recording
def stop_video_recording():
    global video_writer,latitude_degrees,longitude_degrees
    if video_writer is not None:
        video_writer.release()  # Release the video writer
        video_writer = None
        print("Video saved as 'output_video.mp4'.")
        

@app.route('/video_feed')
def video_feed():
    return Response(generate_frames(), mimetype='multipart/x-mixed-replace; boundary=frame')


if __name__ == "__main__":
    # Start the button press monitoring in a separate thread
    button_thread = threading.Thread(target=monitor_button)
    button_thread.daemon = True
    button_thread.start()

    # Run Flask app
    try:
        app.run(host='0.0.0.0', port=5000)
    except KeyboardInterrupt:
        pass
    finally:
        GPIO.cleanup()  # Clean up GPIO settings when program exits
        cap.release()  # Release the video capture object
        print("GPIO cleaned up and video capture released.")
