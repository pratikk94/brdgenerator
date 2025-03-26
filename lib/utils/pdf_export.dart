import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class PdfExportUtil {
  static Future<void> exportDocument(
    String title,
    Map<String, dynamic> documentData,
  ) async {
    // Create PDF document
    final pdf = pw.Document();
    
    // Add title page
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Generated on ${DateTime.now().toString().split(' ')[0]}',
                  style: pw.TextStyle(fontSize: 14),
                ),
              ],
            ),
          );
        },
      ),
    );
    
    // Add content pages
    pdf.addPage(
      pw.MultiPage(
        header: (pw.Context context) {
          return pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          );
        },
        footer: (pw.Context context) {
          return pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Page ${context.pageNumber} of ${context.pagesCount}',
                style: pw.TextStyle(fontSize: 10),
              ),
              pw.Text(
                'Generated with Flutter',
                style: pw.TextStyle(fontSize: 10),
              ),
            ],
          );
        },
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text('Table of Contents'),
            ),
            ...documentData.keys.map((section) {
              return pw.Padding(
                padding: pw.EdgeInsets.only(bottom: 5),
                child: pw.Text(
                  '• $section',
                  style: pw.TextStyle(fontSize: 11),
                ),
              );
            }).toList(),
            pw.SizedBox(height: 20),
            ...documentData.entries.map((entry) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Header(
                    level: 1,
                    child: pw.Text(entry.key),
                  ),
                  _buildPdfContent(entry.value),
                  pw.SizedBox(height: 15),
                ],
              );
            }).toList(),
          ];
        },
      ),
    );
    
    // Save the PDF
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/$title.pdf');
    await file.writeAsBytes(await pdf.save());
    
    // Share the PDF
    await Share.shareFiles(
      [file.path],
      text: 'Sharing $title document',
    );
  }
  
  static pw.Widget _buildPdfContent(dynamic content) {
    if (content is String) {
      return pw.Text(content);
    } else if (content is List) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: content.map((item) {
          return pw.Padding(
            padding: pw.EdgeInsets.only(left: 10, bottom: 5),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('• '),
                pw.Expanded(child: pw.Text(item.toString())),
              ],
            ),
          );
        }).toList(),
      );
    } else if (content is Map) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: content.entries.map((item) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                item.key.toString(),
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 3),
              pw.Padding(
                padding: pw.EdgeInsets.only(left: 10),
                child: _buildPdfContent(item.value),
              ),
              pw.SizedBox(height: 10),
            ],
          );
        }).toList(),
      );
    }
    return pw.Container();
  }
} 