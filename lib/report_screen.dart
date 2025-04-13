import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'gradient.dart';

class ReportScreen extends StatefulWidget {
  final int accountId, userId;

  const ReportScreen({super.key, required this.accountId, required this.userId});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  DateTimeRange? selectedDateRange;
  String reportType = 'Expense';
  bool isLoading = false;
  Map<String, double> categoryTotals = {};

  Future<void> fetchReport() async {
    if (selectedDateRange == null) return;

    setState(() => isLoading = true);

    final url = Uri.parse("http://10.0.2.2:4000/api/reports/generate");
    final body = {
      "user_id": widget.userId,
      "account_id": widget.accountId,
      "report_type": reportType,
      "date_range_start": selectedDateRange!.start.toIso8601String(),
      "date_range_end": selectedDateRange!.end.toIso8601String(),
    };

    try {
      final response = await http.post(url, headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'] as List?;
        setState(() {
          categoryTotals = data != null
              ? Map.fromEntries(data.map((item) => MapEntry(
                  item['category'], 
                  (item['total_amount'] is String ? double.tryParse(item['total_amount']) : item['total_amount']).toDouble(),
                )))
              : {};
        });
      } else {
        print("Error: ${response.statusCode}, ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => selectedDateRange = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Report")),
      body: GradientBackground(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: pickDateRange,
                      child: Text(selectedDateRange == null
                          ? "Select Date Range"
                          : "${DateFormat('MMM dd').format(selectedDateRange!.start)} - ${DateFormat('MMM dd').format(selectedDateRange!.end)}"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  DropdownButton<String>(
                    value: reportType,
                    items: ['Income', 'Expense'].map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                    onChanged: (val) => setState(() => reportType = val!),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: fetchReport, child: const Text("Generate Report")),
              const SizedBox(height: 20),
              if (isLoading)
                const CircularProgressIndicator()
              else if (categoryTotals.isEmpty)
                const Text("No data")
              else
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sections: categoryTotals.entries.map((entry) {
                        return PieChartSectionData(
                          color: Colors.primaries[categoryTotals.keys.toList().indexOf(entry.key) % Colors.primaries.length],
                          value: entry.value,
                          title: entry.key,
                          radius: 80,
                          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        );
                      }).toList(),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
