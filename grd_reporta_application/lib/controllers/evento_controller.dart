import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart'; // ChangeNotifier
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/evento_model.dart';
import '../models/afectacion_model.dart';
import '../models/edan_model.dart';
import '../models/enums.dart';

class EventoController extends ChangeNotifier {
  // ── Firestore ──
  final _db = FirebaseFirestore.instance;
  CollectionReference get _col => _db.collection('eventos');

  late Box<String> _eventosBox;
  late Box<String> _colaPendienteBox;

  List<EventoModel> eventos     = [];
  bool cargando                 = false;
  String? error;
  int get pendientesSinc        => _colaPendienteBox.length;

  Future<void> init() async {
    _eventosBox       = await Hive.openBox<String>('eventos_cache');
    _colaPendienteBox = await Hive.openBox<String>('cola_pendiente');

    _cargarDesdeCache();

    Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        sincronizarPendientes();
      }
    });
  }

  Future<void> crearEvento(EventoModel evento) async {
    cargando = true;
    error    = null;
    notifyListeners();

    final hayRed = await _tieneConexion();

    if (hayRed) {
      try {
        await _col.doc(evento.id).set(evento.toFirestore());
        evento.syncStatus = SyncStatus.synced;
      } catch (e) {
        _encolarOperacion('crear', evento.id, 'eventos', evento.toMap());
        evento.syncStatus = SyncStatus.local;
        error = 'Error al guardar. Se sincronizará cuando haya red.';
      }
    } else {
      _encolarOperacion('crear', evento.id, 'eventos', evento.toMap());
      evento.syncStatus = SyncStatus.local;
    }

    _eventosBox.put(evento.id, jsonEncode(evento.toMap()));
    eventos.insert(0, evento);

    cargando = false;
    notifyListeners();
  }

  Stream<List<EventoModel>> escucharEventos({
    String? municipioId,
    EstadoEvento? estado,
    NivelAlerta? nivelAlerta,
  }) {
    Query query = _col.orderBy('fechaReporte', descending: true);

    if (municipioId != null) query = query.where('municipioId', isEqualTo: municipioId);
    if (estado      != null) query = query.where('estado', isEqualTo: estado.firestoreKey);
    if (nivelAlerta != null) query = query.where('nivelAlerta', isEqualTo: nivelAlerta.name);

    return query.snapshots().map((snap) {
      final remotos = snap.docs
          .map((d) => EventoModel.fromFirestore(d))
          .toList();

      final localesPendientes = eventos
          .where((e) => e.syncStatus == SyncStatus.local)
          .toList();

      eventos = [...localesPendientes, ...remotos];
      notifyListeners();
      return eventos;
    });
  }

  Future<void> cambiarEstado({
    required String eventoId,
    required EstadoEvento nuevoEstado,
    required String usuarioId,
    required String usuarioNombre,
    String? notas,
  }) async {
    final hayRed = await _tieneConexion();
    final batch  = _db.batch();

    // Actualiza el evento
    final refEvento = _col.doc(eventoId);
    batch.update(refEvento, {
      'estado':       nuevoEstado.firestoreKey,
      'actualizadoEn': FieldValue.serverTimestamp(),
    });

    final refBitacora = refEvento.collection('bitacora').doc(const Uuid().v4());
    batch.set(refBitacora, {
      'accionRealizada': 'Cambio de estado a ${nuevoEstado.label}',
      'estadoNuevo':     nuevoEstado.firestoreKey,
      'usuarioId':       usuarioId,
      'usuarioNombre':   usuarioNombre,
      'timestamp':       FieldValue.serverTimestamp(),
      if (notas != null) 'notas': notas,
    });

    if (hayRed) {
      await batch.commit();
    } else {
      _encolarOperacion('cambiarEstado', eventoId, 'eventos', {
        'estado':        nuevoEstado.firestoreKey,
        'usuarioId':     usuarioId,
        'usuarioNombre': usuarioNombre,
        if (notas != null) 'notas': notas,
      });
    }

    final idx = eventos.indexWhere((e) => e.id == eventoId);
    if (idx != -1) {
      eventos[idx] = eventos[idx].copyWith(estado: nuevoEstado);
      notifyListeners();
    }
  }

  Future<void> guardarAfectacion(AfectacionModel afectacion) async {
    final hayRed = await _tieneConexion();
    final ref    = _col.doc(afectacion.eventoId)
                       .collection('afectacion')
                       .doc(afectacion.id);

    if (hayRed) {
      final batch = _db.batch();
      batch.set(ref, afectacion.toFirestore());

      batch.update(_col.doc(afectacion.eventoId), {
        'familiasTotales':  afectacion.totalFamilias,
        'personasTotales':  afectacion.personasDamnificadas,
        'actualizadoEn':    FieldValue.serverTimestamp(),
      });
      await batch.commit();
    } else {
      _encolarOperacion(
        'guardarAfectacion', afectacion.id,
        'eventos/${afectacion.eventoId}/afectacion',
        afectacion.toMap(),
      );
    }
  }

  Future<void> sincronizarPendientes() async {
    if (_colaPendienteBox.isEmpty) return;
    if (!(await _tieneConexion())) return;

    final keys = _colaPendienteBox.keys.toList();

    for (final key in keys) {
      final raw = _colaPendienteBox.get(key);
      if (raw == null) continue;

      try {
        final op = jsonDecode(raw) as Map<String, dynamic>;
        await _ejecutarOperacion(op);
        await _colaPendienteBox.delete(key);
      } catch (e) {
        debugPrint('Error sincronizando $key: $e');
      }
    }
    notifyListeners();
  }

  void _cargarDesdeCache() {
    eventos = _eventosBox.values
        .map((json) => EventoModel.fromMap(jsonDecode(json)))
        .toList()
      ..sort((a, b) => b.fechaReporte.compareTo(a.fechaReporte));
    notifyListeners();
  }

  void _encolarOperacion(
    String tipo, String docId, String colPath, Map<String, dynamic> payload) {
    final opId = const Uuid().v4();
    _colaPendienteBox.put(opId, jsonEncode({
      'tipo':     tipo,
      'docId':    docId,
      'colPath':  colPath,
      'payload':  payload,
      'creadoEn': DateTime.now().toIso8601String(),
      'intentos': 0,
    }));
  }

  Future<void> _ejecutarOperacion(Map<String, dynamic> op) async {
    final tipo    = op['tipo']    as String;
    final docId   = op['docId']   as String;
    final colPath = op['colPath'] as String;
    final payload = op['payload'] as Map<String, dynamic>;

    final ref = _db.doc('$colPath/$docId');

    switch (tipo) {
      case 'crear':
        await ref.set(payload);
      case 'actualizar':
      case 'cambiarEstado':
        await ref.update(payload);
      case 'guardarAfectacion':
        await ref.set(payload);
      default:
        debugPrint('Tipo de operación desconocido: $tipo');
    }
  }

  Future<bool> _tieneConexion() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }
}