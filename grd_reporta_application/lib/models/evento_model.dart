import 'package:cloud_firestore/cloud_firestore.dart';
import 'enums.dart';

class EventoModel {
  final String id;
  final String codigoEvento;

  final TipoEvento tipo;
  final String? subtipo;
  final NivelAlerta nivelAlerta;
  final EstadoEvento estado;
  final String descripcion;

  final String municipioId;
  final String municipioNombre;
  final String? vereda;

  final double latitud;
  final double longitud;
  final String? direccion;

  final DateTime fechaOcurrencia;
  final DateTime fechaReporte;
  final DateTime creadoEn;
  final DateTime actualizadoEn;

  final String reportanteId;
  final String reportanteNombre;

  final int familiasTotales;
  final int personasTotales;
  final double hectareasTotales;

  SyncStatus syncStatus;

  EventoModel({
    required this.id,
    required this.codigoEvento,
    required this.tipo,
    this.subtipo,
    required this.nivelAlerta,
    required this.estado,
    required this.descripcion,
    required this.municipioId,
    required this.municipioNombre,
    this.vereda,
    required this.latitud,
    required this.longitud,
    this.direccion,
    required this.fechaOcurrencia,
    required this.fechaReporte,
    required this.creadoEn,
    required this.actualizadoEn,
    required this.reportanteId,
    required this.reportanteNombre,
    this.familiasTotales = 0,
    this.personasTotales = 0,
    this.hectareasTotales = 0.0,
    this.syncStatus = SyncStatus.local,
  });

  factory EventoModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return EventoModel(
      id:               doc.id,
      codigoEvento:     d['codigoEvento']    ?? '',
      tipo:             TipoEvento.fromString(d['tipo'] ?? ''),
      subtipo:          d['subtipo'],
      nivelAlerta:      NivelAlerta.fromString(d['nivelAlerta'] ?? ''),
      estado:           EstadoEvento.fromString(d['estado'] ?? ''),
      descripcion:      d['descripcion']     ?? '',
      municipioId:      d['municipioId']     ?? '',
      municipioNombre:  d['municipioNombre'] ?? '',
      vereda:           d['vereda'],
      latitud:          (d['latitud']  as num?)?.toDouble() ?? 0.0,
      longitud:         (d['longitud'] as num?)?.toDouble() ?? 0.0,
      direccion:        d['direccion'],
      fechaOcurrencia:  (d['fechaOcurrencia'] as Timestamp).toDate(),
      fechaReporte:     (d['fechaReporte']    as Timestamp).toDate(),
      creadoEn:         (d['creadoEn']        as Timestamp).toDate(),
      actualizadoEn:    (d['actualizadoEn']   as Timestamp).toDate(),
      reportanteId:     d['reportanteId']     ?? '',
      reportanteNombre: d['reportanteNombre'] ?? '',
      familiasTotales:  (d['familiasTotales'] as num?)?.toInt()    ?? 0,
      personasTotales:  (d['personasTotales'] as num?)?.toInt()    ?? 0,
      hectareasTotales: (d['hectareasTotales'] as num?)?.toDouble() ?? 0.0,
      syncStatus:       SyncStatus.synced,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'codigoEvento':    codigoEvento,
      'tipo':            tipo.name,
      if (subtipo != null) 'subtipo': subtipo,
      'nivelAlerta':     nivelAlerta.name,
      'estado':          estado.firestoreKey,
      'descripcion':     descripcion,
      'municipioId':     municipioId,
      'municipioNombre': municipioNombre, // desnormalizado ★
      if (vereda != null) 'vereda': vereda,
      'latitud':         latitud,
      'longitud':        longitud,
      // GeoPoint para consultas geográficas en Firestore
      'geolocalizacion': GeoPoint(latitud, longitud),
      if (direccion != null) 'direccion': direccion,
      'fechaOcurrencia':  Timestamp.fromDate(fechaOcurrencia),
      'fechaReporte':     Timestamp.fromDate(fechaReporte),
      'creadoEn':         Timestamp.fromDate(creadoEn),
      'actualizadoEn':    FieldValue.serverTimestamp(), // el servidor pone la hora
      'reportanteId':     reportanteId,
      'reportanteNombre': reportanteNombre, // desnormalizado ★
      'familiasTotales':  familiasTotales,  // desnormalizado ★
      'personasTotales':  personasTotales,  // desnormalizado ★
      'hectareasTotales': hectareasTotales, // desnormalizado ★
    };
  }

  factory EventoModel.fromMap(Map<String, dynamic> m) {
    return EventoModel(
      id:               m['id'],
      codigoEvento:     m['codigoEvento'],
      tipo:             TipoEvento.fromString(m['tipo'] ?? ''),
      subtipo:          m['subtipo'],
      nivelAlerta:      NivelAlerta.fromString(m['nivelAlerta'] ?? ''),
      estado:           EstadoEvento.fromString(m['estado'] ?? ''),
      descripcion:      m['descripcion']     ?? '',
      municipioId:      m['municipioId']     ?? '',
      municipioNombre:  m['municipioNombre'] ?? '',
      vereda:           m['vereda'],
      latitud:          (m['latitud']  as num?)?.toDouble() ?? 0.0,
      longitud:         (m['longitud'] as num?)?.toDouble() ?? 0.0,
      direccion:        m['direccion'],
      fechaOcurrencia:  DateTime.parse(m['fechaOcurrencia']),
      fechaReporte:     DateTime.parse(m['fechaReporte']),
      creadoEn:         DateTime.parse(m['creadoEn']),
      actualizadoEn:    DateTime.parse(m['actualizadoEn']),
      reportanteId:     m['reportanteId']     ?? '',
      reportanteNombre: m['reportanteNombre'] ?? '',
      familiasTotales:  (m['familiasTotales']  as num?)?.toInt()    ?? 0,
      personasTotales:  (m['personasTotales']  as num?)?.toInt()    ?? 0,
      hectareasTotales: (m['hectareasTotales'] as num?)?.toDouble() ?? 0.0,
      syncStatus:       SyncStatus.values.firstWhere(
                          (s) => s.name == m['syncStatus'],
                          orElse: () => SyncStatus.local),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id':              id,
      'codigoEvento':    codigoEvento,
      'tipo':            tipo.name,
      if (subtipo != null) 'subtipo': subtipo,
      'nivelAlerta':     nivelAlerta.name,
      'estado':          estado.firestoreKey,
      'descripcion':     descripcion,
      'municipioId':     municipioId,
      'municipioNombre': municipioNombre,
      if (vereda != null) 'vereda': vereda,
      'latitud':         latitud,
      'longitud':        longitud,
      if (direccion != null) 'direccion': direccion,
      'fechaOcurrencia':  fechaOcurrencia.toIso8601String(),
      'fechaReporte':     fechaReporte.toIso8601String(),
      'creadoEn':         creadoEn.toIso8601String(),
      'actualizadoEn':    actualizadoEn.toIso8601String(),
      'reportanteId':     reportanteId,
      'reportanteNombre': reportanteNombre,
      'familiasTotales':  familiasTotales,
      'personasTotales':  personasTotales,
      'hectareasTotales': hectareasTotales,
      'syncStatus':       syncStatus.name,
    };
  }

  bool get estaPendiente  => syncStatus == SyncStatus.local;
  bool get tieneUbicacion => latitud != 0.0 && longitud != 0.0;
  bool get puedeValidar   => estado == EstadoEvento.abierto;
  bool get puedeCerrar    => estado == EstadoEvento.enValidacion;

  EventoModel copyWith({
    EstadoEvento? estado,
    NivelAlerta? nivelAlerta,
    String? descripcion,
    int? familiasTotales,
    int? personasTotales,
    double? hectareasTotales,
    SyncStatus? syncStatus,
    DateTime? actualizadoEn,
  }) {
    return EventoModel(
      id: id, codigoEvento: codigoEvento,
      tipo: tipo, subtipo: subtipo,
      nivelAlerta:     nivelAlerta     ?? this.nivelAlerta,
      estado:          estado          ?? this.estado,
      descripcion:     descripcion     ?? this.descripcion,
      municipioId: municipioId, municipioNombre: municipioNombre,
      vereda: vereda, latitud: latitud, longitud: longitud,
      direccion: direccion,
      fechaOcurrencia: fechaOcurrencia, fechaReporte: fechaReporte,
      creadoEn: creadoEn,
      actualizadoEn:    actualizadoEn   ?? this.actualizadoEn,
      reportanteId: reportanteId, reportanteNombre: reportanteNombre,
      familiasTotales:  familiasTotales  ?? this.familiasTotales,
      personasTotales:  personasTotales  ?? this.personasTotales,
      hectareasTotales: hectareasTotales ?? this.hectareasTotales,
      syncStatus:       syncStatus       ?? this.syncStatus,
    );
  }

  @override
  String toString() =>
      'EventoModel($codigoEvento | ${municipioNombre} | ${estado.label} | ${syncStatus.name})';
}