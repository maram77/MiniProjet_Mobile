import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseApi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  FirebaseApi() {
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/logo');
      final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
      );
    } catch (e) {
      print('Error initializing notifications: $e');
    }
  }

  Future<void> _showNotification(String title, String body,
      int notificationId) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
      notificationId,
      title,
      body,
      platformChannelSpecifics,
      payload: 'New Payload',
    );
  }

  int _generateNotificationId(String uniqueKey) {
    return uniqueKey.hashCode.remainder(2147483647);
  }

  Future<void> initNotifications() async {
    _firestore.collection('posts').snapshots().listen((snapshot) async {
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          DocumentSnapshot postSnapshot = await change.doc.reference.get();
          Map<String, dynamic> postData = postSnapshot.data() as Map<
              String,
              dynamic> ?? {};
          String postId = postSnapshot.id;
          final notificationSent = postData['notificationSent'] ?? false;
          if (!notificationSent) {
            final postCategories = List<String>.from(postData['categories']);
            final subscribedStudents = await _fetchSubscribedStudents(
                postCategories);
            if (subscribedStudents.isNotEmpty) {
              int notificationId = _generateNotificationId(postId);
              _sendNotification(postData, notificationId);
            }
            await change.doc.reference.update({'notificationSent': true});
          }
        }
      }
    });
  }

  Future<void> _sendNotification(Map<String, dynamic> postData,
      int notificationId) async {
    _showNotification(
        postData['title'] ?? 'New Post',
        postData['description'] ?? 'Check it out!',
        notificationId
    );
  }

  Future<List<String>> _fetchSubscribedStudents(
      List<String> postCategories) async {
    final subscribedStudents = <String>[];
    for (final category in postCategories) {
      final studentsSnapshot = await _firestore
          .collection('students')
          .where('categories', arrayContains: category)
          .get();
      final studentEmails = studentsSnapshot.docs
          .map((doc) => doc['email'] as String)
          .toList();
      subscribedStudents.addAll(studentEmails);
    }
    return subscribedStudents.toSet().toList();
  }
}