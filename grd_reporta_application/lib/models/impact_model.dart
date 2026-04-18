import 'package:cloud_firestore/cloud_firestore.dart';
import 'enums.dart';

class AfectacionModel {
  final String id;
  final String eventoId;

  final int familiasDirectas;
  final int familiasIndirectas;
  final int personasDamnificadas;

  final int viviendasDestruidas;
  final int viviendasAveriadas;

  final int muertos;
  final int heridos;
  final int desaparecidos;

  final int escuelasAfectadas;
  final int puestosDeServidAfectados;

  SyncStatus syncStatus;

  AfectacionModel({
    required this.id,
    required this.eventoId,
    this.familiasDirectas = 0,
    this.familiasIndirectas = 0,
    this.personasDamnificadas = 0,
    this.viviendasDestruidas = 0,
    this.viviendasAveriadas = 0,
    this.muertos = 0,
    this.heridos = 0,
    this.desaparecidos = 0,
    this.escuelasAfectadas = 0,
    this.puestosDeServidAfectados = 0,
    this.syncStatus = SyncStatus.local,
  });

  int get totalFamilias => familiasDirectas + familiasIndirectas;

  factory AfectacionModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return AfectacionModel(
      id:                     doc.id,
      eventoId:               d['eventoId']               ?? '',
      familiasDirectas:       (d['familiasDirectas']       as num?)?.toInt() ?? 0,
      familiasIndirectas:     (d['familiasIndirectas']     as num?)?.toInt() ?? 0,
      personasDamnificadas:   (d['personasDamnificadas']   as num?)?.toInt() ?? 0,
      viviendasDestruidas:    (d['viviendasDestruidas']    as num?)?.toInt() ?? 0,
      viviendasAveriadas:     (d['viviendasAveriadas']     as num?)?.toInt() ?? 0,
      muertos:                (d['muertos']                as num?)?.toInt() ?? 0,
      heridos:                (d['heridos']                as num?)?.toInt() ?? 0,
      desaparecidos:          (d['desaparecidos']          as num?)?.toInt() ?? 0,
      escuelasAfectadas:      (d['escuelasAfectadas']      as num?)?.toInt() ?? 0,
      puestosDeServidAfectados: (d['puestosDeServidAfectados'] as num?)?.toInt() ?? 0,
      syncStatus: SyncStatus.synced,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'eventoId':               eventoId,
    'familiasDirectas':       familiasDirectas,
    'familiasIndirectas':     familiasIndirectas,
    'personasDamnificadas':   personasDamnificadas,
    'viviendasDestruidas':    viviendasDestruidas,
    'viviendasAveriadas':     viviendasAveriadas,
    'muertos':                muertos,
    'heridos':                heridos,
    'desaparecidos':          desaparecidos,
    'escuelasAfectadas':      escuelasAfectadas,
    'puestosDeServidAfectados': puestosDeServidAfectados,
    'actualizadoEn':          FieldValue.serverTimestamp(),
  };

  factory AfectacionModel.fromMap(Map<String, dynamic> m) => AfectacionModel(
    id:                     m['id'],
    eventoId:               m['eventoId'],
    familiasDirectas:       (m['familiasDirectas']       as num?)?.toInt() ?? 0,
    familiasIndirectas:     (m['familiasIndirectas']     as num?)?.toInt() ?? 0,
    personasDamnificadas:   (m['personasDamnificadas']   as num?)?.toInt() ?? 0,
    viviendasDestruidas:    (m['viviendasDestruidas']    as num?)?.toInt() ?? 0,
    viviendasAveriadas:     (m['viviendasAveriadas']     as num?)?.toInt() ?? 0,
    muertos:                (m['muertos']                as num?)?.toInt() ?? 0,
    heridos:                (m['heridos']                as num?)?.toInt() ?? 0,
    desaparecidos:          (m['desaparecidos']          as num?)?.toInt() ?? 0,
    escuelasAfectadas:      (m['escuelasAfectadas']      as num?)?.toInt() ?? 0,
    puestosDeServidAfectados: (m['puestosDeServidAfectados'] as num?)?.toInt() ?? 0,
    syncStatus: SyncStatus.values.firstWhere((s) => s.name == m['syncStatus'],
        orElse: () => SyncStatus.local),
  );

  Map<String, dynamic> toMap() => {
    'id': id, 'eventoId': eventoId,
    'familiasDirectas': familiasDirectas,
    'familiasIndirectas': familiasIndirectas,
    'personasDamnificadas': personasDamnificadas,
    'viviendasDestruidas': viviendasDestruidas,
    'viviendasAveriadas': viviendasAveriadas,
    'muertos': muertos, 'heridos': heridos, 'desaparecidos': desaparecidos,
    'escuelasAfectadas': escuelasAfectadas,
    'puestosDeServidAfectados': puestosDeServidAfectados,
    'syncStatus': syncStatus.name,
  };
}