import 'package:cloud_firestore/cloud_firestore.dart';
import 'enums.dart';

class EdanModel {
  final String id;
  final String eventoId;
  final String codigoEdan;

  // Infraestructura vial
  final double kmViasObstruidas;
  final double kmViasDestruidas;
  final String tipoVia;
  final String descripcionDanioVias;

  final int puentesAfectados;
  final int puentesDestruidos;
  final List<String> detallePuentes;

  final double hectareasCultivos;
  final String tipoCultivo;
  final EspecieAnimal? especieAnimal;
  final int cantidadAnimales;
  final double valorEstimadoDaniosAgroCOP;

  final double valorEstimadoDaniosCOP;
  final double? fondoDisponibleCOP;

  final String observacionesTecnicas;
  final String? recomendaciones;
  final String tecnicoId;
  final String tecnicoNombre;

  final DateTime fechaRegistro;
  final DateTime? fechaValidacion;

  SyncStatus syncStatus;

  EdanModel({
    required this.id,
    required this.eventoId,
    required this.codigoEdan,
    this.kmViasObstruidas = 0,
    this.kmViasDestruidas = 0,
    this.tipoVia = '',
    this.descripcionDanioVias = '',
    this.puentesAfectados = 0,
    this.puentesDestruidos = 0,
    this.detallePuentes = const [],
    this.hectareasCultivos = 0,
    this.tipoCultivo = '',
    this.especieAnimal,
    this.cantidadAnimales = 0,
    this.valorEstimadoDaniosAgroCOP = 0,
    this.valorEstimadoDaniosCOP = 0,
    this.fondoDisponibleCOP,
    this.observacionesTecnicas = '',
    this.recomendaciones,
    required this.tecnicoId,
    required this.tecnicoNombre,
    required this.fechaRegistro,
    this.fechaValidacion,
    this.syncStatus = SyncStatus.local,
  });

  double? get brechaFinanciera {
    if (fondoDisponibleCOP == null) return null;
    return valorEstimadoDaniosCOP - fondoDisponibleCOP!;
  }

  bool get esValido {
    if (cantidadAnimales > 0 && especieAnimal == null) return false;
    if (observacionesTecnicas.isEmpty) return false;
    return true;
  }

  factory EdanModel.fromFirestore(DocumentSnapshot doc) {
    final d    = doc.data() as Map<String, dynamic>;
    final vias = (d['vias']        as Map?) ?? {};
    final puen = (d['puentes']     as Map?) ?? {};
    final agro = (d['agropecuario'] as Map?) ?? {};
    return EdanModel(
      id: doc.id, eventoId: d['eventoId'] ?? '',
      codigoEdan: d['codigoEdan'] ?? '',
      kmViasObstruidas: (vias['kmObstruidos'] as num?)?.toDouble() ?? 0,
      kmViasDestruidas: (vias['kmDestruidos'] as num?)?.toDouble() ?? 0,
      tipoVia:           vias['tipo']        ?? '',
      descripcionDanioVias: vias['descripcion'] ?? '',
      puentesAfectados:  (puen['afectados']  as num?)?.toInt() ?? 0,
      puentesDestruidos: (puen['destruidos'] as num?)?.toInt() ?? 0,
      detallePuentes:    List<String>.from(puen['detalle'] ?? []),
      hectareasCultivos: (agro['hectareas']      as num?)?.toDouble() ?? 0,
      tipoCultivo:       agro['tipoCultivo']     ?? '',
      especieAnimal:     agro['especieAnimal'] != null
                          ? EspecieAnimal.fromString(agro['especieAnimal'])
                          : null,
      cantidadAnimales:  (agro['cantidadAnimales'] as num?)?.toInt() ?? 0,
      valorEstimadoDaniosAgroCOP: (agro['valorEstimado'] as num?)?.toDouble() ?? 0,
      valorEstimadoDaniosCOP: (d['valorEstimadoDaniosCOP'] as num?)?.toDouble() ?? 0,
      fondoDisponibleCOP:     (d['fondoDisponibleCOP']     as num?)?.toDouble(),
      observacionesTecnicas:  d['observacionesTecnicas']  ?? '',
      recomendaciones:        d['recomendaciones'],
      tecnicoId:              d['tecnicoId']     ?? '',
      tecnicoNombre:          d['tecnicoNombre'] ?? '',
      fechaRegistro:  (d['fechaRegistro']  as Timestamp).toDate(),
      fechaValidacion: (d['fechaValidacion'] as Timestamp?)?.toDate(),
      syncStatus: SyncStatus.synced,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'eventoId': eventoId, 'codigoEdan': codigoEdan,
    'vias': {
      'kmObstruidos': kmViasObstruidas,
      'kmDestruidos': kmViasDestruidas,
      'tipo': tipoVia,
      'descripcion': descripcionDanioVias,
    },
    'puentes': {
      'afectados': puentesAfectados,
      'destruidos': puentesDestruidos,
      'detalle': detallePuentes,
    },
    'agropecuario': {
      'hectareas': hectareasCultivos,
      'tipoCultivo': tipoCultivo,
      if (especieAnimal != null) 'especieAnimal': especieAnimal!.name,
      'cantidadAnimales': cantidadAnimales,
      'valorEstimado': valorEstimadoDaniosAgroCOP,
    },
    'valorEstimadoDaniosCOP': valorEstimadoDaniosCOP,
    if (fondoDisponibleCOP != null) 'fondoDisponibleCOP': fondoDisponibleCOP,
    'observacionesTecnicas': observacionesTecnicas,
    if (recomendaciones != null) 'recomendaciones': recomendaciones,
    'tecnicoId': tecnicoId, 'tecnicoNombre': tecnicoNombre,
    'fechaRegistro': Timestamp.fromDate(fechaRegistro),
    if (fechaValidacion != null)
      'fechaValidacion': Timestamp.fromDate(fechaValidacion!),
    'actualizadoEn': FieldValue.serverTimestamp(),
  };

  factory EdanModel.fromMap(Map<String, dynamic> m) => EdanModel(
    id: m['id'], eventoId: m['eventoId'], codigoEdan: m['codigoEdan'],
    kmViasObstruidas: (m['kmViasObstruidas'] as num?)?.toDouble() ?? 0,
    kmViasDestruidas: (m['kmViasDestruidas'] as num?)?.toDouble() ?? 0,
    tipoVia: m['tipoVia'] ?? '', descripcionDanioVias: m['descripcionDanioVias'] ?? '',
    puentesAfectados:  (m['puentesAfectados']  as num?)?.toInt() ?? 0,
    puentesDestruidos: (m['puentesDestruidos'] as num?)?.toInt() ?? 0,
    detallePuentes: List<String>.from(m['detallePuentes'] ?? []),
    hectareasCultivos: (m['hectareasCultivos'] as num?)?.toDouble() ?? 0,
    tipoCultivo: m['tipoCultivo'] ?? '',
    especieAnimal: m['especieAnimal'] != null
        ? EspecieAnimal.fromString(m['especieAnimal']) : null,
    cantidadAnimales: (m['cantidadAnimales'] as num?)?.toInt() ?? 0,
    valorEstimadoDaniosAgroCOP: (m['valorEstimadoDaniosAgroCOP'] as num?)?.toDouble() ?? 0,
    valorEstimadoDaniosCOP: (m['valorEstimadoDaniosCOP'] as num?)?.toDouble() ?? 0,
    fondoDisponibleCOP: (m['fondoDisponibleCOP'] as num?)?.toDouble(),
    observacionesTecnicas: m['observacionesTecnicas'] ?? '',
    recomendaciones: m['recomendaciones'],
    tecnicoId: m['tecnicoId'], tecnicoNombre: m['tecnicoNombre'],
    fechaRegistro:   DateTime.parse(m['fechaRegistro']),
    fechaValidacion: m['fechaValidacion'] != null
        ? DateTime.tryParse(m['fechaValidacion']) : null,
    syncStatus: SyncStatus.values.firstWhere((s) => s.name == m['syncStatus'],
        orElse: () => SyncStatus.local),
  );

  Map<String, dynamic> toMap() => {
    'id': id, 'eventoId': eventoId, 'codigoEdan': codigoEdan,
    'kmViasObstruidas': kmViasObstruidas, 'kmViasDestruidas': kmViasDestruidas,
    'tipoVia': tipoVia, 'descripcionDanioVias': descripcionDanioVias,
    'puentesAfectados': puentesAfectados, 'puentesDestruidos': puentesDestruidos,
    'detallePuentes': detallePuentes,
    'hectareasCultivos': hectareasCultivos, 'tipoCultivo': tipoCultivo,
    if (especieAnimal != null) 'especieAnimal': especieAnimal!.name,
    'cantidadAnimales': cantidadAnimales,
    'valorEstimadoDaniosAgroCOP': valorEstimadoDaniosAgroCOP,
    'valorEstimadoDaniosCOP': valorEstimadoDaniosCOP,
    if (fondoDisponibleCOP != null) 'fondoDisponibleCOP': fondoDisponibleCOP,
    'observacionesTecnicas': observacionesTecnicas,
    if (recomendaciones != null) 'recomendaciones': recomendaciones,
    'tecnicoId': tecnicoId, 'tecnicoNombre': tecnicoNombre,
    'fechaRegistro': fechaRegistro.toIso8601String(),
    if (fechaValidacion != null) 'fechaValidacion': fechaValidacion!.toIso8601String(),
    'syncStatus': syncStatus.name,
  };
}