class Validators {
  Validators._();

  static String? required(String? value, [String field = 'Este campo']) {
    if (value == null || value.trim().isEmpty) {
      return '$field es obligatorio';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Ingrese su correo';
    final regex = RegExp(r'^[\w.-]+@[\w.-]+\.\w{2,}$');
    if (!regex.hasMatch(value.trim())) return 'Correo inválido';
    return null;
  }

  static String? minLength(String? value, int min, [String field = 'Campo']) {
    if (value == null || value.trim().length < min) {
      return '$field debe tener al menos $min caracteres';
    }
    return null;
  }

  static String? positiveInt(String? value, [String field = 'Valor']) {
    if (value == null || value.trim().isEmpty) return null;
    final n = int.tryParse(value.trim());
    if (n == null || n < 0) return '$field debe ser un número entero positivo';
    return null;
  }

  static String? positiveDouble(String? value, [String field = 'Valor']) {
    if (value == null || value.trim().isEmpty) return null;
    final n = double.tryParse(value.trim());
    if (n == null || n < 0) return '$field debe ser un número positivo';
    return null;
  }
}