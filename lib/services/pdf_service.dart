
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfService {
  Future<String> createAndSavePdf(
      List<Uint8List> imageBytes, String filename) async {
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
    final dir = await _getAppDir();
    final files = dir.listSync();
    return files
        .where((file) => file.path.endsWith('.pdf'))
        .map((file) => File(file.path))
        .toList();
  }

  Future<void> deletePdfFile(File pdfFile) async {
    if (await pdfFile.exists()) {
      await pdfFile.delete();
    }
  }

  Future<Directory> _getAppDir() async {
    return await getApplicationDocumentsDirectory();
  }
}
