import 'dart:convert';

import 'package:constata/services/messaging/notification_service.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../src/shared/utils.dart';

class FirebaseMessagingService {
  final NotificationService _notificationService;

  FirebaseMessagingService(this._notificationService);

  Future<void> init() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    getDeviceFirebaseToken();
    _onMessage();
  }

  getDeviceFirebaseToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    print('Firebase Token: $token');
  }

  void _onMessage() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        _notificationService.showLocalNotification(CustomNotification(
          id: android.hashCode,
          title: notification.title ?? '',
          body: notification.body ?? '',
          remoteMessage: message,
          payload: message.data['payload'] ?? '',
        ));
      }
    });
  }

  _onMessageOpenedApp() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      _notificationService.showNotification(message);
    });
  }

  Future<List<String>> getTopics() async {
    try {
      var firebaseMessaging = FirebaseMessaging.instance;
      String? token = await firebaseMessaging.getToken();
      if (token != null) {
        var options = BaseOptions(headers: {
          'Authorization':
              'key =AAAAs6OplPk:APA91bGs2sfj2ZqcE9CLqE4ko7ryfz2RB2mlQIaKVsNGWXncPmNQj22gfi_-sXacVHpfVtUxlHjg03hrHw3tkehkcENXmyobNa0SEwtc2Fg2LOQsmvyrOOtmGGhvaSW6jwO8CKilkD28'
        });
        var dio = Dio(options);
        var response = await dio.get(
            'https://iid.googleapis.com/iid/info/' + token,
            queryParameters: {'details': true});
        print(response.data);

        if (response.data['rel'] != null) {
          Map<String, dynamic> subscribedTopics =
              response.data['rel']['topics'];
          List<String> topics = [];
          subscribedTopics.forEach((key, value) {
            topics.add(key);
          });
          return topics;
        } else {
          return [];
        }
      } else {
        throw Exception(
            'Erro ao obter token do Firebase Messaging Service (FMS) para o usuário atual.');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> subscribeToTopic(String topic) async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic(topic);
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> unsubscribeFromAllTopics() async {
    List<String> listTopics = await getTopics();

    for (var entry in listTopics) {
      await Future.delayed(
          const Duration(milliseconds: 100)); // throttle due to 3000 QPS limit
      await FirebaseMessaging.instance.unsubscribeFromTopic(entry);
      debugPrint('Unsubscribed from: ' + entry);
    }
  }

  Future<bool> sendMessageNewTranfer(String obraName) async {
    final obraConverted = convertToValidTopicName(obraName);

    var headers = {
      'Authorization':
          'key=AAAAs6OplPk:APA91bGs2sfj2ZqcE9CLqE4ko7ryfz2RB2mlQIaKVsNGWXncPmNQj22gfi_-sXacVHpfVtUxlHjg03hrHw3tkehkcENXmyobNa0SEwtc2Fg2LOQsmvyrOOtmGGhvaSW6jwO8CKilkD28',
      'Content-Type': 'application/json'
    };
    var request =
        http.Request('POST', Uri.parse('https://fcm.googleapis.com/fcm/send'));
    request.body = json.encode({
      "to": "/topics/$obraConverted",
      "notification": {
        "body":
            "🚧 Novo pedido de transferência disponível para a obra $obraName!",
        "title": "Novo Pedido de Transferência"
      },
      "data": {}
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      return true;
    } else {
      print(response.reasonPhrase);
      return false;
    }
  }

  Future<bool> sendMessageConfirmedTranfer(
      String obraName, String effectiveName) async {
    final obraConverted = convertToValidTopicName(obraName);

    var headers = {
      'Authorization':
          'key=AAAAs6OplPk:APA91bGs2sfj2ZqcE9CLqE4ko7ryfz2RB2mlQIaKVsNGWXncPmNQj22gfi_-sXacVHpfVtUxlHjg03hrHw3tkehkcENXmyobNa0SEwtc2Fg2LOQsmvyrOOtmGGhvaSW6jwO8CKilkD28',
      'Content-Type': 'application/json'
    };
    var request =
        http.Request('POST', Uri.parse('https://fcm.googleapis.com/fcm/send'));
    request.body = json.encode({
      "to": "/topics/$obraConverted",
      "notification": {
        "body":
            "✅ Transferência de $effectiveName confirmada para a obra $obraName!",
        "title": "Confirmação de Transferência"
      },
      "data": {}
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      return true;
    } else {
      print(response.reasonPhrase);
      return false;
    }
  }

  Future<bool> sendMessageDeniedTransfer(
      String obraOrigin, String obraTarget, String effectiveName) async {
    final obraConverted = convertToValidTopicName(obraOrigin);

    var headers = {
      'Authorization':
          'key=AAAAs6OplPk:APA91bGs2sfj2ZqcE9CLqE4ko7ryfz2RB2mlQIaKVsNGWXncPmNQj22gfi_-sXacVHpfVtUxlHjg03hrHw3tkehkcENXmyobNa0SEwtc2Fg2LOQsmvyrOOtmGGhvaSW6jwO8CKilkD28',
      'Content-Type': 'application/json'
    };
    var request = http.Request(
      'POST',
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
    );
    request.body = json.encode({
      "to": "/topics/$obraConverted",
      "notification": {
        "body":
            "❌ Transferência de $effectiveName recusada para a obra $obraTarget.",
        "title": "Transferência Negada"
      },
      "data": {}
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      return true;
    } else {
      print(response.reasonPhrase);
      return false;
    }
  }
}
