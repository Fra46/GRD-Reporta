import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../models/user_model.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  RxBool isLoading = false.obs;

  Rxn<User> firebaseUser = Rxn<User>();
  Rxn<UserModel> appUser = Rxn<UserModel>();

  @override
  void onInit() {
    super.onInit();

    firebaseUser.bindStream(_auth.authStateChanges());

    ever(firebaseUser, _handleAuthChanged);
  }

  Future<void> _handleAuthChanged(User? user) async {
    if (user == null) {
      appUser.value = null;
      Get.offAllNamed('/login');
      return;
    }

    await loadUserProfile(user.uid);
  }

  Future<void> loadUserProfile(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();

      if (!doc.exists) {
        await logout();
        Get.snackbar('Error', 'Perfil no encontrado');
        return;
      }

      final data = doc.data()!;

      final user = UserModel.fromMap(data, uid);

      if (!user.active) {
        await logout();
        Get.snackbar('Acceso denegado', 'Usuario inactivo');
        return;
      }

      appUser.value = user;

      Get.offAllNamed('/dashboard');
    } catch (e) {
      Get.snackbar('Error', 'No se pudo cargar el perfil');
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;

      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Error',
        e.message ?? 'No fue posible iniciar sesión',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  String get name => appUser.value?.name ?? '';
  String get email => appUser.value?.email ?? '';
  String get role => appUser.value?.role ?? '';
  String get uid => appUser.value?.uid ?? '';
}