
import 'dart:io';
import 'package:equatable/equatable.dart';

enum PdfLibraryStatus { initial, loading, success, failure }

class PdfLibraryState extends Equatable {
  const PdfLibraryState({
    this.status = PdfLibraryStatus.initial,
    this.pdfs = const <File>[],
    this.error = '',
  });

  final PdfLibraryStatus status;
  final List<File> pdfs;
  final String error;

  PdfLibraryState copyWith({
    PdfLibraryStatus? status,
    List<File>? pdfs,
    String? error,
  }) {
    return PdfLibraryState(
      status: status ?? this.status,
      pdfs: pdfs ?? this.pdfs,
      error: error ?? this.error,
    );
  }

  @override
  List<Object> get props => [status, pdfs, error];
}
