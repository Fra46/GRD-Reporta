import 'package:cloud_firestore/cloud_firestore.dart';
import 'enums.dart';

class EvidenciaModel {
  final String id;
  final String eventoId;
  final TipoEvidencia tipo;

  // Ruta local mientras está pendiente de subir
  final String? rutaLocal;
  // URL en Firebase Storage / Cloudinary post-sync
  final String? storageUrl;
  final String? thumbnailUrl;

  final double? latitud;
  final double? longitud;
  final DateTime timestampCaptura;
  final String subidoPorId;
  final String subidoPorNombre;
  final int tamanioKb; // post-compresión
  final String? descripcion;

  SyncStatus syncStatus;

  EvidenciaModel({
    required this.id,
    required this.eventoId,
    required this.tipo,
    this.rutaLocal,
    this.storageUrl,
    this.thumbnailUrl,
    this.latitud,
    this.longitud,
    required this.timestampCaptura,
    required this.subidoPorId,
    required this.subidoPorNombre,
    this.tamanioKb = 0,
    this.descripcion,
    this.syncStatus = SyncStatus.local,
  });

  bool get estaEnNube      => storageUrl != null;
  bool get tieneGps        => latitud != null && longitud != null;
  String? get urlParaMostrar => storageUrl ?? rutaLocal;

  factory EvidenciaModel.fromFirestore(DocumentSnapshot doc) {
    final d   = doc.data() as Map<String, dynamic>;
    final geo = d['geolocalizacion'] as GeoPoint?;
    return EvidenciaModel(
      id: doc.id, eventoId: d['eventoId'] ?? '',
      tipo: TipoEvidencia.values.firstWhere(
          (t) => t.name == d['tipo'], orElse: () => TipoEvidencia.foto),
      storageUrl:   d['storageUrl'],
      thumbnailUrl: d['thumbnailUrl'],
      latitud:  geo?.latitude,
      longitud: geo?.longitude,
      timestampCaptura: (d['timestampCaptura'] as Timestamp).toDate(),
      subidoPorId:     d['subidoPorId']     ?? '',
      subidoPorNombre: d['subidoPorNombre'] ?? '',
      tamanioKb:       (d['tamanioKb'] as num?)?.toInt() ?? 0,
      descripcion:     d['descripcion'],
      syncStatus:      SyncStatus.synced,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'eventoId': eventoId, 'tipo': tipo.name,
    if (storageUrl   != null) 'storageUrl':   storageUrl,
    if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
    if (latitud  != null && longitud != null)
      'geolocalizacion': GeoPoint(latitud!, longitud!),
    'timestampCaptura': Timestamp.fromDate(timestampCaptura),
    'subidoPorId':     subidoPorId,
    'subidoPorNombre': subidoPorNombre,
    'tamanioKb':       tamanioKb,
    if (descripcion != null) 'descripcion': descripcion,
  };

  factory EvidenciaModel.fromMap(Map<String, dynamic> m) => EvidenciaModel(
    id: m['id'], eventoId: m['eventoId'],
    tipo: TipoEvidencia.values.firstWhere(
        (t) => t.name == m['tipo'], orElse: () => TipoEvidencia.foto),
    rutaLocal:    m['rutaLocal'],
    storageUrl:   m['storageUrl'],
    thumbnailUrl: m['thumbnailUrl'],
    latitud:  (m['latitud']  as num?)?.toDouble(),
    longitud: (m['longitud'] as num?)?.toDouble(),
    timestampCaptura: DateTime.parse(m['timestampCaptura']),
    subidoPorId:     m['subidoPorId'],
    subidoPorNombre: m['subidoPorNombre'],
    tamanioKb:       (m['tamanioKb'] as num?)?.toInt() ?? 0,
    descripcion:     m['descripcion'],
    syncStatus: SyncStatus.values.firstWhere((s) => s.name == m['syncStatus'],
        orElse: () => SyncStatus.local),
  );

  Map<String, dynamic> toMap() => {
    'id': id, 'eventoId': eventoId, 'tipo': tipo.name,
    if (rutaLocal    != null) 'rutaLocal':    rutaLocal,
    if (storageUrl   != null) 'storageUrl':   storageUrl,
    if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
    if (latitud  != null) 'latitud':  latitud,
    if (longitud != null) 'longitud': longitud,
    'timestampCaptura': timestampCaptura.toIso8601String(),
    'subidoPorId': subidoPorId, 'subidoPorNombre': subidoPorNombre,
    'tamanioKb': tamanioKb,
    if (descripcion != null) 'descripcion': descripcion,
    'syncStatus': syncStatus.name,
  };

  EvidenciaModel copyWith({String? storageUrl, String? thumbnailUrl, SyncStatus? syncStatus}) =>
    EvidenciaModel(
      id: id, eventoId: eventoId, tipo: tipo,
      rutaLocal: rutaLocal,
      storageUrl:   storageUrl   ?? this.storageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      latitud: latitud, longitud: longitud,
      timestampCaptura: timestampCaptura,
      subidoPorId: subidoPorId, subidoPorNombre: subidoPorNombre,
      tamanioKb: tamanioKb, descripcion: descripcion,
      syncStatus: syncStatus ?? this.syncStatus,
    );
}