import 'package:get/get.dart';
import '../models/event_model.dart';
import 'event_controller.dart';

enum RangoFecha { hoy, semana, mes, personalizado }

class AnalyticsController extends GetxController {
  EventController get _ec => Get.find<EventController>();

  final Rx<RangoFecha> rangoActual = RangoFecha.mes.obs;
  final Rx<DateTime?> fechaInicio = Rx<DateTime?>(null);
  final Rx<DateTime?> fechaFin = Rx<DateTime?>(null);

  List<EventModel> get eventosFiltrados {
    final now = DateTime.now();
    DateTime desde;
    DateTime hasta = DateTime(now.year, now.month, now.day, 23, 59, 59);

    switch (rangoActual.value) {
      case RangoFecha.hoy:
        desde = DateTime(now.year, now.month, now.day);
        break;
      case RangoFecha.semana:
        desde = now.subtract(const Duration(days: 7));
        break;
      case RangoFecha.mes:
        desde = DateTime(now.year, now.month, 1);
        break;
      case RangoFecha.personalizado:
        if (fechaInicio.value == null || fechaFin.value == null) {
          return _ec.events;
        }
        desde = fechaInicio.value!;
        hasta = DateTime(
          fechaFin.value!.year,
          fechaFin.value!.month,
          fechaFin.value!.day,
          23,
          59,
          59,
        );
    }

    return _ec.events
        .where(
          (e) =>
              e.fechaEvento.isAfter(desde.subtract(const Duration(seconds: 1))) &&
              e.fechaEvento.isBefore(hasta.add(const Duration(seconds: 1))),
        )
        .toList();
  }

  void setRango(RangoFecha rango) => rangoActual.value = rango;

  void setPersonalizado(DateTime inicio, DateTime fin) {
    fechaInicio.value = inicio;
    fechaFin.value = fin;
    rangoActual.value = RangoFecha.personalizado;
  }

  // ── KPIs ────────────────────────────────────────────────────────
  int get totalEventos => eventosFiltrados.length;
  int get totalCriticos =>
      eventosFiltrados.where((e) => e.criticidad == 'alta').length;
  int get totalConAfectacion =>
      eventosFiltrados.where((e) => e.hayAfectacion).length;
  int get totalPersonas =>
      eventosFiltrados.fold(0, (s, e) => s + e.personasAfectadas);
  int get totalFamilias =>
      eventosFiltrados.fold(0, (s, e) => s + e.familiasAfectadas);
  int get totalViviendas =>
      eventosFiltrados.fold(0, (s, e) => s + e.viviendasAfectadas);
  int get totalAbiertos =>
      eventosFiltrados.where((e) => e.estado == 'abierto').length;
  int get totalCerrados =>
      eventosFiltrados.where((e) => e.estado == 'cerrado').length;

  // ── Gráfica 1: Eventos por municipio (barras) ───────────────────
  Map<String, int> get eventosPorMunicipio {
    final mapa = <String, int>{};
    for (final e in eventosFiltrados) {
      mapa[e.municipio] = (mapa[e.municipio] ?? 0) + 1;
    }
    final sorted = Map.fromEntries(
      mapa.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );
    // Top 6
    return Map.fromEntries(sorted.entries.take(6));
  }

  // ── Gráfica 2: Tendencia por día / semana (líneas) ──────────────
  Map<String, int> get tendenciaTemporal {
    final mapa = <String, int>{};
    final now = DateTime.now();

    if (rangoActual.value == RangoFecha.hoy) {
      // Por hora
      for (int h = 0; h < 24; h++) {
        final label = '${h.toString().padLeft(2, '0')}h';
        mapa[label] = 0;
      }
      for (final e in eventosFiltrados) {
        final label = '${e.fechaEvento.hour.toString().padLeft(2, '0')}h';
        mapa[label] = (mapa[label] ?? 0) + 1;
      }
    } else if (rangoActual.value == RangoFecha.semana) {
      // Últimos 7 días
      for (int d = 6; d >= 0; d--) {
        final day = now.subtract(Duration(days: d));
        final label = '${day.day}/${day.month}';
        mapa[label] = 0;
      }
      for (final e in eventosFiltrados) {
        final label = '${e.fechaEvento.day}/${e.fechaEvento.month}';
        if (mapa.containsKey(label)) {
          mapa[label] = mapa[label]! + 1;
        }
      }
    } else {
      // Por semana del mes / mes
      for (int d = 1; d <= now.day; d++) {
        final day = DateTime(now.year, now.month, d);
        final label = '${day.day}/${day.month}';
        mapa[label] = 0;
      }
      for (final e in eventosFiltrados) {
        if (e.fechaEvento.month == now.month) {
          final label = '${e.fechaEvento.day}/${e.fechaEvento.month}';
          if (mapa.containsKey(label)) {
            mapa[label] = mapa[label]! + 1;
          }
        }
      }
    }
    return mapa;
  }

  // ── Gráfica 3: Por criticidad (circular / pie) ──────────────────
  Map<String, int> get eventosPorCriticidad {
    return {
      'Alta': eventosFiltrados.where((e) => e.criticidad == 'alta').length,
      'Media': eventosFiltrados.where((e) => e.criticidad == 'media').length,
      'Baja': eventosFiltrados.where((e) => e.criticidad == 'baja').length,
    };
  }

  // ── Gráfica 4: Por tipo de evento (barras horizontales) ─────────
  Map<String, int> get eventosPorTipo {
    final mapa = <String, int>{};
    for (final e in eventosFiltrados) {
      mapa[e.tipoEvento] = (mapa[e.tipoEvento] ?? 0) + 1;
    }
    final sorted = Map.fromEntries(
      mapa.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );
    return Map.fromEntries(sorted.entries.take(7));
  }

  // ── Gráfica 5: Estados (dona) ────────────────────────────────────
  Map<String, int> get eventosPorEstado {
    return {
      'Abierto': eventosFiltrados.where((e) => e.estado == 'abierto').length,
      'En proceso':
          eventosFiltrados.where((e) => e.estado == 'en_proceso').length,
      'En validación':
          eventosFiltrados.where((e) => e.estado == 'en_validacion').length,
      'Cerrado': eventosFiltrados.where((e) => e.estado == 'cerrado').length,
    };
  }
}