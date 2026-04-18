import 'package:cloud_firestore/cloud_firestore.dart';
import 'enums.dart';

class UsuarioModel {
  final String id; // igual al Firebase Auth UID
  final String username;
  final String nombreCompleto;
  final String email;
  final RolUsuario rol;
  final String? municipioId;
  final String? municipioNombre;
  final String? fcmToken; // para notificaciones push
  final bool activo;
  final DateTime fechaRegistro;

  UsuarioModel({
    required this.id,
    required this.username,
    required this.nombreCompleto,
    required this.email,
    required this.rol,
    this.municipioId,
    this.municipioNombre,
    this.fcmToken,
    required this.activo,
    required this.fechaRegistro,
  });

  bool get puedeReportar  => rol == RolUsuario.reportante || rol == RolUsuario.tecnico;
  bool get puedeValidar   => rol == RolUsuario.tecnico    || rol == RolUsuario.directivo;
  bool get verDashboard   => rol == RolUsuario.directivo  || rol == RolUsuario.tecnico;

  factory UsuarioModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return UsuarioModel(
      id:              doc.id,
      username:        d['username']       ?? '',
      nombreCompleto:  d['nombreCompleto'] ?? '',
      email:           d['email']          ?? '',
      rol:             RolUsuario.fromString(d['rol'] ?? ''),
      municipioId:     d['municipioId'],
      municipioNombre: d['municipioNombre'],
      fcmToken:        d['fcmToken'],
      activo:          d['activo']         ?? true,
      fechaRegistro:   (d['fechaRegistro'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'username':       username,
    'nombreCompleto': nombreCompleto,
    'email':          email,
    'rol':            rol.name,
    if (municipioId     != null) 'municipioId':     municipioId,
    if (municipioNombre != null) 'municipioNombre': municipioNombre,
    if (fcmToken        != null) 'fcmToken':        fcmToken,
    'activo':         activo,
    'fechaRegistro':  Timestamp.fromDate(fechaRegistro),
    'ultimoAcceso':   FieldValue.serverTimestamp(),
  };

  factory UsuarioModel.fromMap(Map<String, dynamic> m) => UsuarioModel(
    id:              m['id'],
    username:        m['username']       ?? '',
    nombreCompleto:  m['nombreCompleto'] ?? '',
    email:           m['email']          ?? '',
    rol:             RolUsuario.fromString(m['rol'] ?? ''),
    municipioId:     m['municipioId'],
    municipioNombre: m['municipioNombre'],
    fcmToken:        m['fcmToken'],
    activo:          m['activo']         ?? true,
    fechaRegistro:   DateTime.parse(m['fechaRegistro']),
  );

  Map<String, dynamic> toMap() => {
    'id': id, 'username': username,
    'nombreCompleto': nombreCompleto, 'email': email,
    'rol': rol.name,
    if (municipioId     != null) 'municipioId':     municipioId,
    if (municipioNombre != null) 'municipioNombre': municipioNombre,
    if (fcmToken        != null) 'fcmToken':        fcmToken,
    'activo': activo,
    'fechaRegistro': fechaRegistro.toIso8601String(),
  };

  UsuarioModel copyWith({String? fcmToken}) => UsuarioModel(
    id: id, username: username, nombreCompleto: nombreCompleto,
    email: email, rol: rol, municipioId: municipioId,
    municipioNombre: municipioNombre,
    fcmToken: fcmToken ?? this.fcmToken,
    activo: activo, fechaRegistro: fechaRegistro,
  );
}