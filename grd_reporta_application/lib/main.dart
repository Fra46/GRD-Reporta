import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:get/get.dart';

import 'ui/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp();

  // Inicializar Hive (almacenamiento local / offline)
  await Hive.initFlutter();

  // Abrir cajas locales necesarias
  await Hive.openBox('settings');
  await Hive.openBox('offline_reports');
  await Hive.openBox('session');

  runApp(const GrdReportaApp());
}