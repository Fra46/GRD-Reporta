class AppConstants {
  AppConstants._();

  // ── Cloudinary ─────────────────────────────────────────────
  static const String cloudinaryCloudName = 'dnlbwyd4t';
  static const String cloudinaryUploadPreset = 'grd_reporta_unsigned';
  static const String cloudinaryFolder = 'grd_reporta/eventos';

  // ── Firestore collections ───────────────────────────────────
  static const String colEvents   = 'events';
  static const String colUsers    = 'users';
  static const String colEdan     = 'edan';

  // ── Roles ───────────────────────────────────────────────────
  static const String roleAdmin       = 'admin';
  static const String roleCoordinador = 'coordinador';
  static const String roleAnalista    = 'analista';
  static const String roleDirectivo   = 'directivo';

  // ── Estados de evento ───────────────────────────────────────
  static const String estadoAbierto      = 'abierto';
  static const String estadoEnProceso    = 'en_proceso';
  static const String estadoEnValidacion = 'en_validacion';
  static const String estadoCerrado      = 'cerrado';

  // ── Criticidad ──────────────────────────────────────────────
  static const String criticidadBaja  = 'baja';
  static const String criticidadMedia = 'media';
  static const String criticidadAlta  = 'alta';

  // ── Límites ─────────────────────────────────────────────────
  static const int maxFotosPorEvento = 4;
  static const int gpsTimeoutSeconds = 15;
  static const int imageQuality      = 75;
  static const int imageMaxWidth     = 1920;
}