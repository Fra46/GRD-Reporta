// lib/ui/app.dart
// GRD Reporta App — Gobernación del Cesar
// Widget raíz: define rutas y tema visual

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/nuevo_evento_page.dart';
import 'pages/detalle_evento_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/edan_form_page.dart';

class GrdReportaApp extends StatelessWidget {
  const GrdReportaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GRD Reporta — Cesar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF1A5276), // azul institucional
        useMaterial3: true,
      ),
      // Decide la pantalla inicial según si hay sesión activa
      home: Consumer<AuthController>(
        builder: (_, auth, __) {
          if (auth.estaAutenticado) return const HomePage();
          return const LoginPage();
        },
      ),
      routes: {
        '/login':          (_) => const LoginPage(),
        '/home':           (_) => const HomePage(),
        '/nuevo-evento':   (_) => const NuevoEventoPage(),
        '/dashboard':      (_) => const DashboardPage(),
      },
      onGenerateRoute: (settings) {
        // Rutas con parámetros (eventoId)
        if (settings.name == '/detalle-evento') {
          final eventoId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (_) => DetalleEventoPage(eventoId: eventoId),
          );
        }
        if (settings.name == '/edan-form') {
          final eventoId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (_) => EdanFormPage(eventoId: eventoId),
          );
        }
        return null;
      },
    );
  }
}