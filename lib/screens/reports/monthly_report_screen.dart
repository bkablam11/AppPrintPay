// lib/screens/reports/monthly_report_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../models/teacher_model.dart';
import '../../services/firebase_teacher_service.dart';

class MonthlyReportScreen extends StatefulWidget {
  @override
  _MonthlyReportScreenState createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
  DateTime _selectedDate = DateTime.now();

  void _pickMonth(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
    ).then((pickedDate) {
      if (pickedDate != null) {
        setState(() {
          _selectedDate = pickedDate;
        });
      }
    });
  }

  void _confirmResetMonth(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Réinitialiser le mois'),
        content: Text(
          'Voulez-vous vraiment supprimer toutes les impressions pour ${DateFormat.yMMMM().format(_selectedDate)} ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            child: Text('Annuler'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: Text('Réinitialiser', style: TextStyle(color: Colors.red)),
            onPressed: () {
              final teacherService = Provider.of<FirebaseTeacherService>(
                context,
                listen: false,
              );
              teacherService.clearImpressionsForMonth(
                _selectedDate.year,
                _selectedDate.month,
              );
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final teachers = Provider.of<List<Teacher>>(context);
    final allImpressions = teachers.expand((t) => t.impressions).toList();

    final monthlyImpressions = allImpressions.where((imp) {
      return imp.date.year == _selectedDate.year &&
          imp.date.month == _selectedDate.month;
    }).toList();

    final totalMonthlyImpressions = monthlyImpressions.fold(
      0,
      (sum, item) => sum + item.pageCount,
    );
    final totalMonthlyCost = monthlyImpressions.fold(
      0.0,
      (sum, item) => sum + item.totalCost,
    );

    final Map<int, double> dailyTotals = {};
    for (var impression in monthlyImpressions) {
      dailyTotals.update(
        impression.date.day,
        (value) => value + impression.pageCount,
        ifAbsent: () => impression.pageCount.toDouble(),
      );
    }

    final barGroups = dailyTotals.entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(toY: entry.value, color: Colors.lightBlue, width: 16),
        ],
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Rapport Mensuel'),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () => _pickMonth(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              DateFormat.yMMMM().format(_selectedDate),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 20),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          'Total Impressions',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        SizedBox(height: 4),
                        Text(
                          totalMonthlyImpressions.toString(),
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          'Coût Total',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${totalMonthlyCost.toStringAsFixed(2)} FCFA',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            if (monthlyImpressions.isEmpty)
              Expanded(
                child: Center(child: Text('Aucune impression pour ce mois.')),
              )
            else
              Expanded(
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    barGroups: barGroups,
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(show: true),
                  ),
                ),
              ),
            SizedBox(height: 10),
            if (monthlyImpressions.isNotEmpty)
              ElevatedButton.icon(
                onPressed: () => _confirmResetMonth(context),
                icon: Icon(Icons.delete_sweep),
                label: Text('Réinitialiser le mois'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
