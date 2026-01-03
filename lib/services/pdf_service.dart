
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  Future<void> createAndSharePdf(
      List<XFile> images, String filename, BuildContext context) async {
    try {
      if (images.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No images selected to create a PDF.')),
          );
        }
        return;
      }

      final doc = pw.Document();

      for (var imageFile in images) {
        try {
          final imageBytes = await imageFile.readAsBytes();
          final image = pw.MemoryImage(imageBytes);

          doc.addPage(pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Image(image),
              );
            },
          ));
        } catch (e, s) {
          developer.log(
            'Error processing a single image',
            name: 'pdf_service.image_loop',
            error: e,
            stackTrace: s,
          );
          // Optionally, show a user-friendly error for the specific image
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not process image: ${imageFile.name}')),
            );
          }
          // Continue to the next image instead of failing the whole process
          continue;
        }
      }

      final String finalFilename = '${filename.isNotEmpty ? filename.trim() : "pdf_genius_doc"}.pdf';

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save(),
        name: finalFilename,
      );
    } catch (e, s) {
      developer.log(
        'Failed to create or share PDF',
        name: 'pdf_service.createAndSharePdf',
        error: e,
        stackTrace: s,
        level: 1000, // SEVERE
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('An unexpected error occurred while creating the PDF.')),
        );
      }
    }
  }
}
