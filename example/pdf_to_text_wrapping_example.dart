// ignore_for_file: avoid_print

import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:pdf_text_extraction/pdf_text_extraction.dart';

void main() {
  final root = Directory.current.path;
  final libraryName = Platform.isLinux ? 'libpdftotext.so' : 'pdftotext.dll';
  final libraryPath = path.join(root, libraryName);
  final pdfPath = path.join(root, 'jornal.pdf');

  if (!File(libraryPath).existsSync()) {
    stderr.writeln('Missing $libraryName at $libraryPath');
    exit(1);
  }
  if (!File(pdfPath).existsSync()) {
    stderr.writeln('Missing jornal.pdf at $pdfPath');
    exit(1);
  }

  final wrapper = PDFToTextWrapping();

  try {
    final text = wrapper.extractText(
      pdfPath,
      startPage: 1,
      endPage: 1,
    );

    if (text.trim().isEmpty) {
      print('No text found on page 1.');
    } else {
      print('Text from page 1:\n$text');
    }
  } on Exception catch (error) {
    stderr.writeln('Failed to extract text: $error');
    if (PDFToTextWrapping.lastError.isNotEmpty) {
      stderr.writeln('Native error: ${PDFToTextWrapping.lastError}');
    }
    exit(1);
  }
}
