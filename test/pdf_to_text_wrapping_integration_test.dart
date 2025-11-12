import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:pdf_text_extraction/pdf_text_extraction.dart';
import 'package:test/test.dart';

void main() {
  group('PDFToTextWrapping (integration)', () {
    final pdfPath = path.join(Directory.current.path, '1417.pdf');

    late PDFToTextWrapping wrapper;

    setUpAll(() {
      final pdfFile = File(pdfPath);
      if (!pdfFile.existsSync()) {
        fail('Expected fixture PDF at $pdfPath');
      }
      PDFToTextWrapping.resetLastError();
      wrapper = PDFToTextWrapping();
    });

    test('getPagesCount returns at least one page', () {
      final pageCount = wrapper.getPagesCount(pdfPath);

      expect(pageCount, greaterThan(0));
      expect(PDFToTextWrapping.lastError, isEmpty);
    });

    test('extractText returns non empty text for first page', () {
      final text = wrapper.extractText(
        pdfPath,
        startPage: 1,
        endPage: 1,
      );

      expect(text.trim(), isNotEmpty);
      expect(PDFToTextWrapping.lastError, isEmpty);
    });
  });
}
