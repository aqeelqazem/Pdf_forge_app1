
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/business_logic/pdf_library_state.dart';
import 'package:myapp/services/pdf_service.dart';
import 'package:share_plus/share_plus.dart';

class PdfLibraryCubit extends Cubit<PdfLibraryState> {
  final PdfService _pdfService;

  PdfLibraryCubit(this._pdfService) : super(const PdfLibraryState());

  Future<void> loadPdfs() async {
    emit(state.copyWith(status: PdfLibraryStatus.loading));
    try {
      final pdfs = await _pdfService.getSavedPdfs();
      // Sort by most recently modified
      pdfs.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      emit(state.copyWith(status: PdfLibraryStatus.success, pdfs: pdfs));
    } catch (e) {
      emit(state.copyWith(status: PdfLibraryStatus.failure, error: e.toString()));
    }
  }

  Future<void> deletePdf(File pdfFile) async {
    try {
      await _pdfService.deletePdfFile(pdfFile);
      // Refresh the list after deletion
      await loadPdfs();
    } catch (e) {
      // Optionally, handle error state specifically for deletion
      emit(state.copyWith(status: PdfLibraryStatus.failure, error: "Failed to delete: ${e.toString()}"));
    }
  }

  Future<void> sharePdf(File pdfFile) async {
    try {
      await Share.shareXFiles([XFile(pdfFile.path)], text: 'Here is my PDF file.');
    } catch (e) {
      // Handle sharing error if needed
    }
  }
}
