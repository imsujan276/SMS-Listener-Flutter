import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sms_catch/sms_model.dart';
import 'package:sms_catch/sqlite_service.dart';
import 'package:telephony/telephony.dart';

import 'lifecycle_event_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SqliteService().initDB();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Home(),
    );
  }
}

Future<void> handleBackgroundSms(SmsMessage message) async {
  print("\n************** backgound sms handler *****************");
  print(message.address);
  print(message.body);
  print(message.date);
  print("**************----------------*****************\n\n");
  final SMS sms = SMS(
    text: message.body!,
    sender: message.address!,
    date: message.date!,
  );
  await SqliteService().insertSMS(sms);
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> with WidgetsBindingObserver {
  SMS? sms;
  Telephony telephony = Telephony.instance;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(LifecycleEventHandler(
      resumeCallBack: () async => getStoredSMS(),
    ));
    telephony.listenIncomingSms(
      onNewMessage: (SmsMessage message) => handleSms(message),
      onBackgroundMessage: handleBackgroundSms,
      listenInBackground: true,
    );
    getStoredSMS();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(LifecycleEventHandler());
    super.dispose();
  }

  Future<void> getStoredSMS() async {
    final List<SMS> storedSMS = await SqliteService().getAllSms();
    setState(() {
      sms = storedSMS.isEmpty ? null : storedSMS.last;
    });
  }

  deleteAllSMS() async {
    await SqliteService().deleteAllSMS();
    getStoredSMS();
  }

  void handleSms(SmsMessage message) async {
    print("\n************** Foreground SMS handler *****************");
    print(message.address); //+977981******67, sender nubmer
    print(message.body); //sms text
    print(message.date); //1659690242000, timestamp
    print("**************----------------*****************\n\n");
    final SMS sms = SMS(
      text: message.body!,
      sender: message.address!,
      date: message.date!,
    );
    await SqliteService().insertSMS(sms);
    getStoredSMS();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SMS Listener"),
        actions: [
          IconButton(
              onPressed: () => getStoredSMS(), icon: const Icon(Icons.refresh)),
          IconButton(
              onPressed: () => deleteAllSMS(), icon: const Icon(Icons.delete)),
        ],
      ),
      body: WillPopScope(
        onWillPop: () {
          if (Platform.isAndroid) {
            if (Navigator.of(context).canPop()) {
              return Future.value(true);
            } else {
              var androidAppRetain = const MethodChannel("android_app_retain");
              androidAppRetain.invokeMethod("sendToBackground");
              return Future.value(false);
            }
          } else {
            return Future.value(true);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          alignment: Alignment.topLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "SMS Text:",
                style: TextStyle(fontSize: 30),
              ),
              const Divider(),
              if (sms != null) ...[
                Text(
                  "Text: ${sms!.text}",
                  style: const TextStyle(fontSize: 20),
                ),
                const Divider(),
                Text(
                  "Sender: ${sms!.sender}",
                  style: const TextStyle(fontSize: 20),
                ),
                const Divider(),
                Text(
                  "DateTime: ${parseDate(sms!.date)}",
                  style: const TextStyle(fontSize: 20),
                ),
                const Divider(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String parseDate(int d) {
    return DateTime.fromMillisecondsSinceEpoch(d).toString();
  }
}
