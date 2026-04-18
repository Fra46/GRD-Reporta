import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Estado reactivo
  RxBool isLoading = false.obs;
  Rxn<User> firebaseUser = Rxn<User>();

  @override
  void onInit() {
    super.onInit();

    // Escucha cambios de sesión
    firebaseUser.bindStream(_auth.authStateChanges());
  }

  // Login
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

      Get.snackbar(
        'Éxito',
        'Inicio de sesión correcto',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Error',
        _getFirebaseError(e),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Ocurrió un problema inesperado',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Usuario actual
  User? get currentUser => _auth.currentUser;

  // Traductor de errores Firebase
  String _getFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Usuario no encontrado';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'invalid-email':
        return 'Correo inválido';
      case 'invalid-credential':
        return 'Credenciales inválidas';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta luego.';
      default:
        return 'No fue posible iniciar sesión';
    }
  }
}