
import 'dart:typed_data';

import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  Future<void> createAndSharePdf(List<Uint8List> imageBytes) async {
    final pdf = pw.Document();

    for (final bytes in imageBytes) {
      final image = pw.MemoryImage(bytes);
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(image),
            );
          },
        ),
      );
    }

    await Printing.sharePdf(
        bytes: await pdf.save(), filename: 'image_gallery.pdf');
  }
}
