import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExportService {
  final _client = Supabase.instance.client;

  // ── Full Data Export (JSON) ──────────────────────────
  Future<void> exportAllData() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    final gardens = await _client.from('gardens').select().eq('user_id', userId);
    final gardenIds = (gardens as List).map((g) => g['id']).toList();

    final plants = gardenIds.isEmpty ? [] : await _client
        .from('garden_plants').select().inFilter('garden_id', gardenIds);
    final journal = gardenIds.isEmpty ? [] : await _client
        .from('journal_entries').select().inFilter('garden_id', gardenIds);

    final export = {
      'exported_at': DateTime.now().toIso8601String(),
      'gardens': gardens,
      'garden_plants': plants,
      'journal_entries': journal,
    };

    final json = const JsonEncoder.withIndent('  ').convert(export);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/omnigarden_export.json');
    await file.writeAsString(json);
    await Share.shareXFiles([XFile(file.path)], text: 'OmniGarden Data Export');
  }

  // ── Garden Plan PDF ──────────────────────────────────
  Future<void> exportGardenPlanPdf({
    required String gardenName,
    required List<List<String>> emojiGrid,
    required List<List<String>> labelGrid,
    required int rows,
    required int cols,
  }) async {
    final pdf = pw.Document();
    final cellSize = 28.0;

    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(gardenName, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.Text('Garden Layout Plan', style: const pw.TextStyle(fontSize: 14)),
          pw.SizedBox(height: 8),
          pw.Text('Generated: ${DateTime.now().toString().substring(0, 10)}',
              style: const pw.TextStyle(fontSize: 10)),
          pw.SizedBox(height: 20),
          pw.Text('⬆ NORTH', style: const pw.TextStyle(fontSize: 10)),
          pw.SizedBox(height: 4),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
            children: List.generate(rows, (r) => pw.TableRow(
              children: List.generate(cols, (c) => pw.Container(
                width: cellSize,
                height: cellSize,
                alignment: pw.Alignment.center,
                color: emojiGrid[r][c].isNotEmpty ? PdfColors.green100 : null,
                child: pw.Text(
                  labelGrid[r][c].isNotEmpty
                      ? labelGrid[r][c].substring(0, labelGrid[r][c].length.clamp(0, 3))
                      : '',
                  style: const pw.TextStyle(fontSize: 6),
                  textAlign: pw.TextAlign.center,
                ),
              )),
            )),
          ),
          pw.SizedBox(height: 16),
          pw.Text('Legend', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          // Unique plants legend
          ...(){
            final seen = <String>{};
            final items = <pw.Widget>[];
            for (int r = 0; r < rows; r++) {
              for (int c = 0; c < cols; c++) {
                final label = labelGrid[r][c];
                if (label.isNotEmpty && seen.add(label)) {
                  final abbr = label.substring(0, label.length.clamp(0, 3));
                  items.add(
                    pw.Row(children: [
                      pw.Container(
                        width: 20,
                        height: 20,
                        color: PdfColors.green100,
                        alignment: pw.Alignment.center,
                        child: pw.Text(abbr, style: const pw.TextStyle(fontSize: 7)),
                      ),
                      pw.SizedBox(width: 6),
                      pw.Text(label, style: const pw.TextStyle(fontSize: 11)),
                    ]),
                  );
                }
                items.add(pw.SizedBox(height: 4));
              }
            }
            return items;
          }(),
        ],
      ),
    ));

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: '${gardenName.replaceAll(' ', '_')}_plan.pdf',
    );
  }

  // ── Calendar PDF ─────────────────────────────────────
  Future<void> exportCalendarPdf({
    required String zone,
    required String location,
    required List<Map<String, dynamic>> plants,
  }) async {
    final pdf = pw.Document();
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4.landscape,
      build: (pw.Context context) => [
        pw.Text('Planting Calendar — $location ($zone)',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
        pw.Text('Generated: ${DateTime.now().toString().substring(0, 10)}',
            style: const pw.TextStyle(fontSize: 10)),
        pw.SizedBox(height: 16),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          columnWidths: {
            0: const pw.FixedColumnWidth(80),
            ...{for (int i = 1; i <= 12; i++) i: const pw.FixedColumnWidth(40)},
          },
          children: [
            // Header row
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                pw.Padding(padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('Plant', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9))),
                ...months.map((m) => pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(m, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                )),
              ],
            ),
            // Plant rows
            ...plants.map((plant) {
              final calendar = plant['calendar'] as Map<String, dynamic>? ?? {};
              final indoor = _parseMonths(calendar['indoor_start'] as String? ?? '');
              final transplant = _parseMonths(calendar['transplant'] as String? ?? '');
              final harvest = _parseMonths(calendar['harvest'] as String? ?? '');
              return pw.TableRow(children: [
                pw.Padding(padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('${plant['emoji'] ?? ''} ${plant['common_name'] ?? ''}',
                        style: const pw.TextStyle(fontSize: 8))),
                ...List.generate(12, (i) {
                  final month = i + 1;
                  PdfColor? color;
                  String label = '';
                  if (indoor.contains(month)) { color = PdfColors.lightBlue200; label = 'I'; }
                  else if (transplant.contains(month)) { color = PdfColors.orange200; label = 'T'; }
                  else if (harvest.contains(month)) { color = PdfColors.green200; label = 'H'; }
                  return pw.Container(
                    decoration: pw.BoxDecoration(color: color),
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(label, style: const pw.TextStyle(fontSize: 8)),
                  );
                }),
              ]);
            }),
          ],
        ),
        pw.SizedBox(height: 12),
        pw.Row(children: [
          _legendBox(PdfColors.lightBlue200, 'I = Start Indoors'),
          pw.SizedBox(width: 16),
          _legendBox(PdfColors.orange200, 'T = Transplant'),
          pw.SizedBox(width: 16),
          _legendBox(PdfColors.green200, 'H = Harvest'),
        ]),
      ],
    ));

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'planting_calendar_$zone.pdf',
    );
  }

  List<int> _parseMonths(String value) {
    if (value.isEmpty || value == 'N/A') return [];
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final result = <int>[];
    for (int i = 0; i < months.length; i++) {
      if (value.contains(months[i])) result.add(i + 1);
    }
    return result;
  }

  pw.Widget _legendBox(PdfColor color, String label) => pw.Row(children: [
    pw.Container(width: 12, height: 12, decoration: pw.BoxDecoration(color: color)),
    pw.SizedBox(width: 4),
    pw.Text(label, style: const pw.TextStyle(fontSize: 9)),
  ]);
}
