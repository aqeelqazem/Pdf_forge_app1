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
    context.read<PdfLibraryCubit>().loadPdfs();
  }

  void _showDeleteConfirmation(BuildContext context, File pdfFile) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to permanently delete this PDF?'),
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
        title: const Text('My PDF Library'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: BlocBuilder<PdfLibraryCubit, PdfLibraryState>(
        builder: (context, state) {
          if (state.status == PdfLibraryStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == PdfLibraryStatus.failure) {
            return Center(child: Text('Error: ${state.error}'));
          }
          if (state.pdfs.isEmpty) {
            return const Center(
              child: Text('No PDFs found.', style: TextStyle(fontSize: 18)),
            );
          }
          return ListView.builder(
            itemCount: state.pdfs.length,
            itemBuilder: (context, index) {
              final pdfFile = state.pdfs[index];
              final fileName = pdfFile.path.split('/').last;
              final fileStat = pdfFile.statSync();
              final modifiedDate =
                  DateFormat.yMMMd().add_jm().format(fileStat.modified);
              final fileSize =
                  (fileStat.size / (1024 * 1024)).toStringAsFixed(2);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.picture_as_pdf,
                      color: Colors.red, size: 40),
                  title: Text(fileName,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle:
                      Text('Modified: $modifiedDate\nSize: ${fileSize}MB'),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'open', child: Text('Open')),
                      const PopupMenuItem(value: 'share', child: Text('Share')),
                      const PopupMenuItem(
                          value: 'delete', child: Text('Delete')),
                    ],
                    onSelected: (value) {
                      if (value == 'open') {
                        OpenFilex.open(pdfFile.path);
                      } else if (value == 'share') {
                        context.read<PdfLibraryCubit>().sharePdf(pdfFile);
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(context, pdfFile);
                      }
                    },
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
