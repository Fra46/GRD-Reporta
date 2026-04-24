import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../controllers/analytics_controller.dart';

class PdfAnalyticsService {
  static Future<void> exportDashboard(AnalyticsController controller) async {
    final pdf = pw.Document();

    final now = DateTime.now();
    final fechaStr =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

    String rangoStr;
    switch (controller.rangoActual.value) {
      case RangoFecha.hoy:
        rangoStr = 'Hoy';
        break;
      case RangoFecha.semana:
        rangoStr = 'Última semana';
        break;
      case RangoFecha.mes:
        rangoStr = 'Este mes';
        break;
      case RangoFecha.personalizado:
        final ini = controller.fechaInicio.value;
        final fin = controller.fechaFin.value;
        rangoStr = ini != null && fin != null
            ? '${ini.day}/${ini.month}/${ini.year} – ${fin.day}/${fin.month}/${fin.year}'
            : 'Personalizado';
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'REPORTE ANALÍTICO GRD',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: const PdfColor.fromInt(0xFF1B2E6B),
                      ),
                    ),
                    pw.Text(
                      'Departamento del Cesar – ODGRD',
                      style: const pw.TextStyle(
                        fontSize: 11,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
                pw.Text(
                  fechaStr,
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey,
                  ),
                ),
              ],
            ),
            pw.Divider(color: const PdfColor.fromInt(0xFF1B2E6B), thickness: 2),
            pw.SizedBox(height: 4),
            pw.Text(
              'Período: $rangoStr',
              style: pw.TextStyle(
                fontSize: 10,
                fontStyle: pw.FontStyle.italic,
                color: PdfColors.grey700,
              ),
            ),
            pw.SizedBox(height: 8),
          ],
        ),
        build: (context) => [
          // ── KPIs ─────────────────────────────────────────────────
          _sectionTitle('Indicadores Clave'),
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              _kpiBox(
                'Total Eventos',
                '${controller.totalEventos}',
                PdfColors.blue800,
              ),
              pw.SizedBox(width: 8),
              _kpiBox(
                'Críticos',
                '${controller.totalCriticos}',
                PdfColors.red700,
              ),
              pw.SizedBox(width: 8),
              _kpiBox(
                'Con Afectación',
                '${controller.totalConAfectacion}',
                PdfColors.orange700,
              ),
              pw.SizedBox(width: 8),
              _kpiBox(
                'Personas',
                '${controller.totalPersonas}',
                PdfColors.green700,
              ),
            ],
          ),
          pw.SizedBox(height: 6),
          pw.Row(
            children: [
              _kpiBox(
                'Familias',
                '${controller.totalFamilias}',
                PdfColors.purple700,
              ),
              pw.SizedBox(width: 8),
              _kpiBox(
                'Viviendas',
                '${controller.totalViviendas}',
                PdfColors.teal700,
              ),
              pw.SizedBox(width: 8),
              _kpiBox(
                'Abiertos',
                '${controller.totalAbiertos}',
                PdfColors.amber800,
              ),
              pw.SizedBox(width: 8),
              _kpiBox(
                'Cerrados',
                '${controller.totalCerrados}',
                PdfColors.grey600,
              ),
            ],
          ),
          pw.SizedBox(height: 20),

          // ── Eventos por municipio ─────────────────────────────────
          _sectionTitle('Eventos por Municipio'),
          pw.SizedBox(height: 8),
          ..._barChart(controller.eventosPorMunicipio, PdfColors.blue700),
          pw.SizedBox(height: 20),

          // ── Criticidad ────────────────────────────────────────────
          _sectionTitle('Distribución por Criticidad'),
          pw.SizedBox(height: 8),
          ..._barChart(
            controller.eventosPorCriticidad,
            PdfColors.orange700,
            colors: [PdfColors.red700, PdfColors.orange700, PdfColors.green700],
          ),
          pw.SizedBox(height: 20),

          // ── Tipo de evento ────────────────────────────────────────
          _sectionTitle('Eventos por Tipo'),
          pw.SizedBox(height: 8),
          ..._barChart(controller.eventosPorTipo, PdfColors.teal700),
          pw.SizedBox(height: 20),

          // ── Estado ────────────────────────────────────────────────
          _sectionTitle('Distribución por Estado'),
          pw.SizedBox(height: 8),
          ..._barChart(
            controller.eventosPorEstado,
            PdfColors.purple700,
            colors: [
              PdfColors.green700,
              PdfColors.orange700,
              PdfColors.blue700,
              PdfColors.grey700,
            ],
          ),
          pw.SizedBox(height: 20),

          // ── Listado top eventos ───────────────────────────────────
          _sectionTitle(
            'Eventos del Período (${controller.totalEventos} total)',
          ),
          pw.SizedBox(height: 8),
          if (controller.eventosFiltrados.isNotEmpty)
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFF1B2E6B),
                  ),
                  children: [
                    _tableHeader('Fecha'),
                    _tableHeader('Municipio'),
                    _tableHeader('Tipo'),
                    _tableHeader('Criticidad'),
                    _tableHeader('Estado'),
                  ],
                ),
                ...controller.eventosFiltrados
                    .take(20)
                    .map(
                      (e) => pw.TableRow(
                        children: [
                          _tableCell(
                            '${e.fechaEvento.day}/${e.fechaEvento.month}/${e.fechaEvento.year}',
                          ),
                          _tableCell(e.municipio),
                          _tableCell(e.tipoEvento),
                          _tableCell(e.criticidad.toUpperCase()),
                          _tableCell(e.estado),
                        ],
                      ),
                    ),
              ],
            )
          else
            pw.Text(
              'Sin eventos en el período seleccionado.',
              style: const pw.TextStyle(color: PdfColors.grey),
            ),

          pw.SizedBox(height: 20),
          pw.Divider(),
          pw.Text(
            'Generado automáticamente por GRD Reporta · ODGRD Cesar · $fechaStr',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/GRD_Analytics_${now.millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(await pdf.save());
    await Share.shareXFiles([
      XFile(file.path),
    ], subject: 'Reporte Analítico GRD – $rangoStr');
  }

  static pw.Widget _sectionTitle(String text) => pw.Text(
    text,
    style: pw.TextStyle(
      fontSize: 13,
      fontWeight: pw.FontWeight.bold,
      color: const PdfColor.fromInt(0xFF1B2E6B),
    ),
  );

  static pw.Widget _kpiBox(String label, String value, PdfColor color) =>
      pw.Expanded(
        child: pw.Container(
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            color: color,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                value,
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                label,
                style: const pw.TextStyle(color: PdfColors.white, fontSize: 8),
              ),
            ],
          ),
        ),
      );

  static List<pw.Widget> _barChart(
    Map<String, int> data,
    PdfColor defaultColor, {
    List<PdfColor>? colors,
  }) {
    if (data.isEmpty) {
      return [
        pw.Text(
          'Sin datos',
          style: const pw.TextStyle(color: PdfColors.grey, fontSize: 10),
        ),
      ];
    }
    final maxVal = data.values.reduce((a, b) => a > b ? a : b);
    return data.entries.toList().asMap().entries.map((entry) {
      final idx = entry.key;
      final e = entry.value;
      final ratio = maxVal > 0 ? e.value / maxVal : 0.0;
      final color = colors != null && idx < colors.length
          ? colors[idx]
          : defaultColor;
      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 5),
        child: pw.Row(
          children: [
            pw.SizedBox(
              width: 100,
              child: pw.Text(
                e.key,
                style: const pw.TextStyle(fontSize: 9),
                maxLines: 1,
              ),
            ),
            pw.Expanded(
              child: pw.Stack(
                children: [
                  pw.Container(
                    height: 14,
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey200,
                      borderRadius: const pw.BorderRadius.all(
                        pw.Radius.circular(4),
                      ),
                    ),
                  ),
                  pw.Container(
                    width: ratio * 200,
                    height: 14,
                    decoration: pw.BoxDecoration(
                      color: color,
                      borderRadius: const pw.BorderRadius.all(
                        pw.Radius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(width: 6),
            pw.Text(
              '${e.value}',
              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
      );
    }).toList();
  }

  static pw.Widget _tableHeader(String text) => pw.Padding(
    padding: const pw.EdgeInsets.all(5),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        color: PdfColors.white,
        fontSize: 8,
        fontWeight: pw.FontWeight.bold,
      ),
    ),
  );

  static pw.Widget _tableCell(String text) => pw.Padding(
    padding: const pw.EdgeInsets.all(4),
    child: pw.Text(text, style: const pw.TextStyle(fontSize: 8)),
  );
}
