// lib/screens/reports/global_report_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/teacher_model.dart';

class GlobalReportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final teachers = Provider.of<List<Teacher>>(context);

    // Group teachers by name and sum their impressions
    final Map<String, int> teacherImpressions = {};
    for (var teacher in teachers) {
      teacherImpressions.update(
        teacher.name,
        (value) => value + teacher.totalImpressions,
        ifAbsent: () => teacher.totalImpressions,
      );
    }

    final totalImpressions = teacherImpressions.values.fold(
      0,
      (sum, item) => sum + item,
    );
    final uniqueTeachers = teacherImpressions.entries.toList();

    // Generate Pie Chart sections
    List<PieChartSectionData> showingSections() {
      return uniqueTeachers.map((entry) {
        final double percentage = (entry.value / totalImpressions) * 100;
        return PieChartSectionData(
          color:
              Colors.primaries[uniqueTeachers.indexOf(entry) %
                  Colors.primaries.length],
          value: entry.value.toDouble(),
          title: '${percentage.toStringAsFixed(1)}%',
          radius: 120,
          titleStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xffffffff),
            shadows: [Shadow(color: Colors.black, blurRadius: 2)],
          ),
        );
      }).toList();
    }

    return Scaffold(
      appBar: AppBar(title: Text('Rapport Global')),
      body: totalImpressions == 0
          ? Center(child: Text('Aucune donnée à afficher.'))
          : SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Text(
                    'Répartition des Impressions par Enseignant',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 300,
                    child: PieChart(
                      PieChartData(
                        sections: showingSections(),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: uniqueTeachers.map((entry) {
                        return Chip(
                          backgroundColor:
                              Colors.primaries[uniqueTeachers.indexOf(entry) %
                                  Colors.primaries.length],
                          label: Text(entry.key),
                          labelStyle: TextStyle(color: Colors.white),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
