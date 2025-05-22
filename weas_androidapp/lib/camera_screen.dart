import 'package:flutter/material.dart';
import 'package:weas_androidapp/constants/endpoints.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CameraScreenAudio extends StatefulWidget {
  const CameraScreenAudio({super.key});

  @override
  State<CameraScreenAudio> createState() => _CameraScreenAudioState();
}


class _CameraScreenAudioState extends State<CameraScreenAudio> {
WebViewController?
    controller;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();


    controller = WebViewController()
  ..setJavaScriptMode(JavaScriptMode.unrestricted)
  ..setNavigationDelegate(
    NavigationDelegate(
      onProgress: (int progress) {
        // Update loading bar.
      },
      onPageStarted: (String url) {},
      onPageFinished: (String url) {},
      onWebResourceError: (WebResourceError error) {},
      onNavigationRequest: (NavigationRequest request) {
        if (request.url.startsWith('https://www.youtube.com/')) {
          return NavigationDecision.prevent;
        }
        return NavigationDecision.navigate;
      },
    ),
  )
  ..loadRequest(Uri.parse('$baseurl/audio'));
  }
 @override
Widget build(BuildContext context) {
  return Scaffold(
    
    body: WebViewWidget(controller: controller!),
  );
}
}


class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}


class _CameraScreenState extends State<CameraScreen> {
WebViewController?
    controller;
  @override
  void initState() {
    super.initState();


    controller = WebViewController()
  ..setJavaScriptMode(JavaScriptMode.unrestricted)
  ..setNavigationDelegate(
    NavigationDelegate(
      onProgress: (int progress) {
        // Update loading bar.
      },
      onPageStarted: (String url) {},
      onPageFinished: (String url) {},
      onWebResourceError: (WebResourceError error) {},
      onNavigationRequest: (NavigationRequest request) {
        if (request.url.startsWith('https://www.youtube.com/')) {
          return NavigationDecision.prevent;
        }
        return NavigationDecision.navigate;
      },
    ),
  )
  ..loadRequest(Uri.parse('$baseurl/video_feed'));
  }
 @override
Widget build(BuildContext context) {
  return Scaffold(
    
    body: WebViewWidget(controller: controller!),
  );
}
}