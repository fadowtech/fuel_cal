import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart' as ex;
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

import '../models/vehicle_model.dart';
import '../models/fuel_log_model.dart';
import '../models/expense_model.dart';
import '../models/service_model.dart';
import '../services/currency_service.dart';

class ReportService {
  static final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');

  static String get _currencySymbol {
    final sym = CurrencyService.currencySymbol;
    if (sym.contains('₹')) return 'Rs ';
    if (sym.contains('€')) return 'EUR ';
    // Fallback: strip any non-ASCII characters to avoid PDF font crashes
    return sym.replaceAll(RegExp(r'[^\x00-\x7F]'), '') + ' ';
  }

  static Future<void> _shareFile(List<int> bytes, String fileName, String mimeType) async {
    final xFile = XFile.fromData(
      Uint8List.fromList(bytes),
      mimeType: mimeType,
      name: fileName,
    );

    await Share.shareXFiles(
      [xFile],
      text: 'Here is your report from Fuel Cal.',
    );
  }

  static pw.Widget _buildPdfHeader(String title, String subtitle) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
        pw.SizedBox(height: 4),
        pw.Text(subtitle, style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
        pw.SizedBox(height: 20),
        pw.Divider(color: PdfColors.grey300),
        pw.SizedBox(height: 20),
      ],
    );
  }

  static Future<void> generateMonthlyPdfReport(List<FuelLog> fuelLogs, List<Expense> expenses) async {
    final pdf = pw.Document();

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return [
          _buildPdfHeader('Monthly Summary Report', 'Generated on ${_dateFormat.format(DateTime.now())}'),
          pw.Text('Fuel Logs Summary', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            headers: ['Date', 'Station', 'Liters', 'Cost'],
            data: fuelLogs.take(30).map((log) => [
              log.date != null ? _dateFormat.format(log.date!) : 'N/A',
              log.stationName ?? 'Unknown',
              '${log.fuelQuantity} L',
              '${_currencySymbol}${log.totalCost.toStringAsFixed(2)}'
            ]).toList(),
            border: pw.TableBorder.all(color: PdfColors.grey300),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
            cellPadding: const pw.EdgeInsets.all(6),
          ),
          pw.SizedBox(height: 20),
          pw.Text('Expenses Summary', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            headers: ['Date', 'Category', 'Amount', 'Notes'],
            data: expenses.take(30).map((exp) => [
              exp.date != null ? _dateFormat.format(exp.date!) : 'N/A',
              exp.category,
              '${_currencySymbol}${exp.amount.toStringAsFixed(2)}',
              exp.notes ?? ''
            ]).toList(),
            border: pw.TableBorder.all(color: PdfColors.grey300),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
            cellPadding: const pw.EdgeInsets.all(6),
          ),
        ];
      },
    ));

    await _shareFile(await pdf.save(), 'Monthly_Report.pdf', 'application/pdf');
  }

  static Future<void> generateExpenseSummaryPdf(List<Expense> expenses) async {
    final pdf = pw.Document();

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return [
          _buildPdfHeader('Expense Summary', 'Generated on ${_dateFormat.format(DateTime.now())}'),
          pw.TableHelper.fromTextArray(
            headers: ['Date', 'Category', 'Amount', 'Vehicle ID'],
            data: expenses.map((exp) => [
              exp.date != null ? _dateFormat.format(exp.date!) : 'N/A',
              exp.category,
              '${_currencySymbol}${exp.amount.toStringAsFixed(2)}',
              exp.vehicleId?.toString() ?? 'N/A'
            ]).toList(),
            border: pw.TableBorder.all(color: PdfColors.grey300),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.green700),
            cellPadding: const pw.EdgeInsets.all(6),
          ),
        ];
      },
    ));

    await _shareFile(await pdf.save(), 'Expense_Summary.pdf', 'application/pdf');
  }

  static Future<void> generateYearlySummaryPdf(List<FuelLog> fuelLogs, List<Expense> expenses) async {
    final pdf = pw.Document();

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return [
          _buildPdfHeader('Yearly Summary Overview', 'Generated on ${_dateFormat.format(DateTime.now())}'),
          pw.Text('Total Records: ${fuelLogs.length + expenses.length}'),
          pw.SizedBox(height: 10),
          pw.Text('Fuel Logs (${fuelLogs.length})'),
          pw.TableHelper.fromTextArray(
            headers: ['Date', 'Station', 'Liters', 'Cost'],
            data: fuelLogs.take(50).map((log) => [
              log.date != null ? _dateFormat.format(log.date!) : 'N/A',
              log.stationName ?? 'Unknown',
              '${log.fuelQuantity} L',
              '${_currencySymbol}${log.totalCost.toStringAsFixed(2)}'
            ]).toList(),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
            headerStyle: pw.TextStyle(color: PdfColors.white),
          ),
        ];
      },
    ));

    await _shareFile(await pdf.save(), 'Yearly_Summary.pdf', 'application/pdf');
  }

  static Future<void> generateVehicleReportPdf(Vehicle? vehicle, List<FuelLog> fuelLogs, List<Expense> expenses) async {
    final pdf = pw.Document();
    
    final vLogs = vehicle != null ? fuelLogs.where((l) => l.vehicleId == vehicle.id).toList() : fuelLogs;
    final vExp = vehicle != null ? expenses.where((e) => e.vehicleId == vehicle.id).toList() : expenses;

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return [
          _buildPdfHeader('Vehicle Report: ${vehicle?.make ?? 'All Vehicles'} ${vehicle?.model ?? ''}', 'Generated on ${_dateFormat.format(DateTime.now())}'),
          pw.Text('Fuel History', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headers: ['Date', 'Station', 'Cost'],
            data: vLogs.map((log) => [
              log.date != null ? _dateFormat.format(log.date!) : 'N/A', 
              log.stationName ?? 'Unknown', 
              '${_currencySymbol}${log.totalCost}'
            ]).toList(),
          ),
        ];
      },
    ));

    await _shareFile(await pdf.save(), 'Vehicle_Report.pdf', 'application/pdf');
  }

  static Future<void> generateServiceHistoryPdf(Vehicle? vehicle, List<Service> services) async {
    final pdf = pw.Document();

    final vServices = vehicle != null ? services.where((s) => s.vehicleId == vehicle.id).toList() : services;

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return [
          _buildPdfHeader('Service History Report', 'Generated on ${_dateFormat.format(DateTime.now())}'),
          if (vServices.isEmpty) pw.Text('No service history available.') else 
          pw.TableHelper.fromTextArray(
            headers: ['Date', 'Category', 'Title', 'Cost', 'Notes'],
            data: vServices.map((s) => [
              s.date != null ? _dateFormat.format(s.date!) : 'N/A',
              s.category,
              s.title,
              '${_currencySymbol}${s.amount}',
              s.notes ?? ''
            ]).toList(),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.deepOrange700),
            headerStyle: pw.TextStyle(color: PdfColors.white),
          ),
        ];
      },
    ));

    await _shareFile(await pdf.save(), 'Service_History.pdf', 'application/pdf');
  }

  static Future<void> exportExcelFuelEntries(List<FuelLog> fuelLogs) async {
    final excel = ex.Excel.createExcel();
    final sheet = excel['Fuel Entries'];
    excel.setDefaultSheet('Fuel Entries');

    sheet.appendRow([
      ex.TextCellValue('Date'),
      ex.TextCellValue('Station'),
      ex.TextCellValue('Location'),
      ex.TextCellValue('Liters'),
      ex.TextCellValue('Price per Liter'),
      ex.TextCellValue('Total Cost'),
      ex.TextCellValue('Odometer'),
      ex.TextCellValue('Vehicle ID'),
    ]);

    for (var log in fuelLogs) {
      sheet.appendRow([
        ex.TextCellValue(log.date != null ? _dateFormat.format(log.date!) : 'N/A'),
        ex.TextCellValue(log.stationName ?? ''),
        ex.TextCellValue(log.location ?? ''),
        ex.DoubleCellValue(log.fuelQuantity),
        ex.DoubleCellValue(log.fuelPrice ?? 0.0),
        ex.DoubleCellValue(log.totalCost),
        ex.DoubleCellValue(log.odometer),
        ex.TextCellValue(log.vehicleId?.toString() ?? ''),
      ]);
    }

    final bytes = excel.encode()!;
    await _shareFile(bytes, 'Fuel_Entries.xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
  }

  static Future<void> exportFuelDataExcel(List<FuelLog> fuelLogs) async {
    // Similar to above, could include extra metrics or formulas
    await exportExcelFuelEntries(fuelLogs);
  }
}
