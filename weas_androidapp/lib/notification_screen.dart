import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotifService {
  static void init() {
    AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Basic Notifications',
          channelDescription: 'Notification channel for basic tests',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: const Color(0xFF9D50DD),
          importance: NotificationImportance.High,
          playSound: true,
        ),
      ],
    );
  }

  static void showNotification() {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: 'basic_channel',
        title: 'New Alert ',
        body: 'I am in Danger!',
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }
}
