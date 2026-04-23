import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ExcelExportService {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<void> exportByDateRange({
    required DateTime start,
    required DateTime end,
  }) async {
    final snapshot = await db
        .collection('events')
        .where('fechaRegistro', isGreaterThanOrEqualTo: start.toIso8601String())
        .where('fechaRegistro', isLessThanOrEqualTo: end.toIso8601String())
        .orderBy('fechaRegistro')
        .get();

    final excel = Excel.createExcel();

    final sheet = excel['REPORTE'];

    // eliminar hoja default
    excel.delete('Sheet1');

    // anchos columnas
    sheet.setColumnWidth(0, 18);
    sheet.setColumnWidth(1, 18);
    sheet.setColumnWidth(2, 22);
    sheet.setColumnWidth(3, 28);
    sheet.setColumnWidth(4, 14);
    sheet.setColumnWidth(5, 14);
    sheet.setColumnWidth(6, 16);
    sheet.setColumnWidth(7, 32);

    // estilos
    final titleStyle = CellStyle(
      bold: true,
      fontSize: 16,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );

    final headerStyle = CellStyle(
      bold: true,
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      backgroundColorHex: ExcelColor.fromHexString('#1E88E5'),
      horizontalAlign: HorizontalAlign.Center,
    );

    final borderStyle = CellStyle(
      leftBorder: Border(borderStyle: BorderStyle.Thin),
      rightBorder: Border(borderStyle: BorderStyle.Thin),
      topBorder: Border(borderStyle: BorderStyle.Thin),
      bottomBorder: Border(borderStyle: BorderStyle.Thin),
    );

    // título
    sheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('H1'));

    final titleCell = sheet.cell(CellIndex.indexByString('A1'));

    titleCell.value = TextCellValue('REPORTE OFICIAL DE EMERGENCIAS - CESAR');

    titleCell.cellStyle = titleStyle;

    // fechas
    sheet.merge(CellIndex.indexByString('A2'), CellIndex.indexByString('H2'));

    sheet.cell(CellIndex.indexByString('A2')).value = TextCellValue(
      'Desde ${_f(start)} hasta ${_f(end)}',
    );

    // encabezado tabla
    sheet.appendRow([
      TextCellValue('FECHA'),
      TextCellValue('DEPTO'),
      TextCellValue('MUNICIPIO'),
      TextCellValue('EVENTO'),
      TextCellValue('PERSONAS'),
      TextCellValue('FAMILIAS'),
      TextCellValue('ESTADO'),
      TextCellValue('OBSERVACIÓN'),
    ]);

    for (int i = 0; i < 8; i++) {
      sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 2))
              .cellStyle =
          headerStyle;
    }

    // data
    for (final doc in snapshot.docs) {
      final d = doc.data();

      sheet.appendRow([
        TextCellValue(d['fechaEvento']?.toString().substring(0, 10) ?? ''),
        TextCellValue('CESAR'),
        TextCellValue(d['municipio'] ?? ''),
        TextCellValue(d['tipoEvento'] ?? ''),
        IntCellValue(d['personasAfectadas'] ?? 0),
        IntCellValue(d['familiasAfectadas'] ?? 0),
        TextCellValue(d['estado'] ?? ''),
        TextCellValue(d['observacion'] ?? ''),
      ]);
    }

    // bordes
    for (int row = 2; row <= snapshot.docs.length + 2; row++) {
      for (int col = 0; col < 8; col++) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row))
            .cellStyle = row == 2
            ? headerStyle
            : borderStyle;
      }
    }

    final bytes = excel.save();

    final dir = await getTemporaryDirectory();

    final file = File(
      '${dir.path}/Reporte_${DateTime.now().millisecondsSinceEpoch}.xlsx',
    );

    await file.writeAsBytes(bytes!);

    await Share.shareXFiles([XFile(file.path)]);
  }

  String _f(DateTime d) {
    return '${d.day}/${d.month}/${d.year}';
  }
}
