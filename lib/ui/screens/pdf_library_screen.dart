
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:myapp/business_logic/pdf_library_cubit.dart';
import 'package:myapp/business_logic/pdf_library_state.dart';
import 'package:open_filex/open_filex.dart';

class PdfLibraryScreen extends StatefulWidget {
  const PdfLibraryScreen({super.key});

  @override
  State<PdfLibraryScreen> createState() => _PdfLibraryScreenState();
}

class _PdfLibraryScreenState extends State<PdfLibraryScreen> {
  @override
  void initState() {
    super.initState();
    // Load PDFs when the screen is first displayed
    context.read<PdfLibraryCubit>().loadPdfs();
  }

  void _showDeleteConfirmation(BuildContext context, File pdfFile) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete "${pdfFile.path.split('/').last}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<PdfLibraryCubit>().deletePdf(pdfFile);
              Navigator.of(ctx).pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/')),
        title: const Text('PDF Library'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh List',
            onPressed: () => context.read<PdfLibraryCubit>().loadPdfs(),
          ),
        ],
      ),
      body: BlocBuilder<PdfLibraryCubit, PdfLibraryState>(
        builder: (context, state) {
          if (state.status == PdfLibraryStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == PdfLibraryStatus.failure) {
            return Center(
              child: Text('Error loading PDFs: ${state.error}'),
            );
          }
          if (state.pdfs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_off_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Your PDF library is empty.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Display the list of PDFs
          return ListView.builder(
            itemCount: state.pdfs.length,
            itemBuilder: (context, index) {
              final pdfFile = state.pdfs[index];
              final fileName = pdfFile.path.split('/').last;
              final fileStat = pdfFile.statSync();
              final modifiedDate = DateFormat.yMMMd().add_jm().format(fileStat.modified);
              final fileSize = (fileStat.size / (1024 * 1024)).toStringAsFixed(2); // in MB

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 40),
                  title: Text(fileName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Modified: $modifiedDate\nSize: ${fileSize}MB'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.share, color: Colors.blue),
                        tooltip: 'Share',
                        onPressed: () => context.read<PdfLibraryCubit>().sharePdf(pdfFile),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                        tooltip: 'Delete',
                        onPressed: () => _showDeleteConfirmation(context, pdfFile),
                      ),
                    ],
                  ),
                  onTap: () => OpenFilex.open(pdfFile.path),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
