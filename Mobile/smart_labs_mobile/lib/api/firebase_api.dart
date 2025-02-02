import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:smart_labs_mobile/utils/secure_storage.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Payload: ${message.data}');
}

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final SecureStorage _secureStorage = SecureStorage();

  Future<void> initNotification() async {
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    if (fCMToken != null) {
      await _secureStorage.storeFcmToken(fCMToken);
    }
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }
}
