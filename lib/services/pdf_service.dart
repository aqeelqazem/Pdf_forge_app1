
import 'dart:io';
import 'package:flutter/foundation.dart'; // Import kIsWeb
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfService {
  Future<String> createAndSavePdf(
      List<Uint8List> imageBytes, String filename) async {
    // Web platform check: Direct file saving is not supported.
    if (kIsWeb) {
      throw UnsupportedError(
          'Saving files directly is not supported on the web platform.');
    }

    final pdf = pw.Document();
    const PdfPageFormat format = PdfPageFormat.a4;

    for (final bytes in imageBytes) {
      final image = pw.MemoryImage(bytes);
      pdf.addPage(
        pw.Page(
          pageFormat: format,
          build: (pw.Context context) {
            return pw.FullPage(
              ignoreMargins: true,
              child: pw.Image(image, fit: pw.BoxFit.contain),
            );
          },
        ),
      );
    }

    final dir = await _getAppDir();
    final file = File('${dir.path}/$filename.pdf');
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  Future<List<File>> getSavedPdfs() async {
    // Web platform check: Cannot access the documents directory.
    if (kIsWeb) {
      return []; // Return an empty list for web, preventing the crash.
    }
    final dir = await _getAppDir();
    // Defensive check in case the directory doesn't exist
    if (!await dir.exists()) {
        return [];
    }
    final files = dir.listSync();
    return files
        .where((file) => file.path.endsWith('.pdf'))
        .map((file) => File(file.path))
        .toList();
  }

  Future<void> deletePdfFile(File pdfFile) async {
    // Web platform check: No files to delete from the app directory.
    if (kIsWeb) {
      return;
    }
    if (await pdfFile.exists()) {
      await pdfFile.delete();
    }
  }

  Future<Directory> _getAppDir() async {
    // This function is now only called on non-web platforms.
    return await getApplicationDocumentsDirectory();
  }
}
