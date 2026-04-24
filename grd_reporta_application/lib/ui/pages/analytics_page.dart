import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../controllers/analytics_controller.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ac = Get.find<AnalyticsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Analítico'),
        backgroundColor: const Color(0xFF1B2E6B),
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filtros de fecha
              _buildDateFilters(ac),
              const SizedBox(height: 20),

              // KPIs
              _buildKPIs(ac),
              const SizedBox(height: 30),

              // Gráficas
              _buildChart(
                'Eventos por Municipio',
                _buildBarChart(ac.eventosPorMunicipio),
              ),
              const SizedBox(height: 30),

              _buildChart(
                'Tendencia Temporal',
                _buildLineChart(ac.tendenciaTemporal),
              ),
              const SizedBox(height: 30),

              _buildChart(
                'Distribución por Criticidad',
                _buildPieChart(ac.eventosPorCriticidad),
              ),
              const SizedBox(height: 30),

              _buildChart(
                'Eventos por Tipo',
                _buildHorizontalBarChart(ac.eventosPorTipo),
              ),
              const SizedBox(height: 30),

              _buildChart(
                'Estados de Eventos',
                _buildDoughnutChart(ac.eventosPorEstado),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDateFilters(AnalyticsController ac) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => ac.setRango(RangoFecha.hoy),
            child: const Text('Hoy'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: () => ac.setRango(RangoFecha.semana),
            child: const Text('Semana'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: () => ac.setRango(RangoFecha.mes),
            child: const Text('Mes'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _selectCustomDate(ac),
            child: const Text('Personalizado'),
          ),
        ),
      ],
    );
  }

  void _selectCustomDate(AnalyticsController ac) async {
    final start = await showDatePicker(
      context: Get.context!,
      initialDate: ac.fechaInicio.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (start != null) {
      final end = await showDatePicker(
        context: Get.context!,
        initialDate: ac.fechaFin.value ?? DateTime.now(),
        firstDate: start,
        lastDate: DateTime.now(),
      );
      if (end != null) {
        ac.setPersonalizado(start, end);
      }
    }
  }

  Widget _buildKPIs(AnalyticsController ac) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _kpiCard('Total Eventos', ac.totalEventos.toString(), Colors.blue),
        _kpiCard('Críticos', ac.totalCriticos.toString(), Colors.red),
        _kpiCard(
          'Con Afectación',
          ac.totalConAfectacion.toString(),
          Colors.orange,
        ),
        _kpiCard(
          'Personas Afectadas',
          ac.totalPersonas.toString(),
          Colors.green,
        ),
        _kpiCard('Familias', ac.totalFamilias.toString(), Colors.purple),
        _kpiCard('Viviendas', ac.totalViviendas.toString(), Colors.teal),
        _kpiCard('Abiertos', ac.totalAbiertos.toString(), Colors.amber),
        _kpiCard('Cerrados', ac.totalCerrados.toString(), Colors.grey),
      ],
    );
  }

  Widget _kpiCard(String label, String value, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(String title, Widget chart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(height: 200, child: chart),
      ],
    );
  }

  Widget _buildBarChart(Map<String, int> data) {
    final entries = data.entries.toList();
    return BarChart(
      BarChartData(
        barGroups: entries.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value.value.toDouble(),
                color: Colors.blue,
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) =>
                  Text(entries[value.toInt()].key),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLineChart(Map<String, int> data) {
    final entries = data.entries.toList();
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: entries
                .asMap()
                .entries
                .map((e) => FlSpot(e.key.toDouble(), e.value.value.toDouble()))
                .toList(),
            isCurved: true,
            color: Colors.blue,
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) =>
                  Text(entries[value.toInt()].key),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart(Map<String, int> data) {
    final entries = data.entries.toList();
    return PieChart(
      PieChartData(
        sections: entries.asMap().entries.map((e) {
          return PieChartSectionData(
            value: e.value.value.toDouble(),
            title: '${e.value.key}\n${e.value.value}',
            color: [Colors.red, Colors.orange, Colors.green][e.key % 3],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHorizontalBarChart(Map<String, int> data) {
    final entries = data.entries.toList();
    return BarChart(
      BarChartData(
        barGroups: entries.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value.value.toDouble(),
                color: Colors.teal,
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => Text(
                entries
                    .firstWhere((element) => element.value == value.toInt())
                    .key,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDoughnutChart(Map<String, int> data) {
    final entries = data.entries.toList();
    return PieChart(
      PieChartData(
        sections: entries.asMap().entries.map((e) {
          return PieChartSectionData(
            value: e.value.value.toDouble(),
            title: '${e.value.key}\n${e.value.value}',
            color: [
              Colors.green,
              Colors.orange,
              Colors.blue,
              Colors.grey,
            ][e.key % 4],
          );
        }).toList(),
        centerSpaceRadius: 40,
      ),
    );
  }
}
