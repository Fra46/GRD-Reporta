import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../models/usuario_model.dart';

class AuthController extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _db   = FirebaseFirestore.instance;

  UsuarioModel? usuario;
  bool cargando = false;
  String? error;

  bool get estaAutenticado => _auth.currentUser != null;

  Future<bool> login(String email, String password) async {
    cargando = true;
    error    = null;
    notifyListeners();

    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email, password: password,
      );

      await _cargarPerfil(cred.user!.uid);

      await _actualizarTokenFCM(cred.user!.uid);

      cargando = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      error    = _mensajeError(e.code);
      cargando = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    usuario = null;
    notifyListeners();
  }

  Future<void> verificarSesion() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _cargarPerfil(user.uid);
    }
    notifyListeners();
  }

  Future<void> _cargarPerfil(String uid) async {
    final doc = await _db.collection('usuarios').doc(uid).get();
    if (doc.exists) {
      usuario = UsuarioModel.fromFirestore(doc);
    }
  }

  Future<void> _actualizarTokenFCM(String uid) async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await _db.collection('usuarios').doc(uid).update({'fcmToken': token});
      }
    } catch (_) {
      
    }
  }

  String _mensajeError(String code) {
    switch (code) {
      case 'user-not-found':    return 'Usuario no encontrado.';
      case 'wrong-password':    return 'Contraseña incorrecta.';
      case 'user-disabled':     return 'Cuenta deshabilitada. Contacte al administrador.';
      case 'too-many-requests': return 'Demasiados intentos. Espere unos minutos.';
      default:                  return 'Error de autenticación. Intente de nuevo.';
    }
  }
}