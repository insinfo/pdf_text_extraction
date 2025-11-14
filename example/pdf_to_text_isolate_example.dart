import 'dart:async';
import 'dart:isolate';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pdf_text_extraction/pdf_text_extraction.dart';

Future<void> main() async {
  final pdfPath = p.join(Directory.current.path, '1417.pdf');

  if (!File(pdfPath).existsSync()) {
    stderr.writeln('PDF not found at $pdfPath');
    return;
  }

  final futures = List.generate(4, (index) {
    return Isolate.run(() async {
      final service = PDFToTextWrappingService();
      await service.run((wrapper) {
        final pageCount = wrapper.getPagesCount(pdfPath);
        final snippet = wrapper.extractText(
          pdfPath,
          endPage: pageCount > 0 ? 1 : 0,
        );
        stdout.writeln(
          'Isolate $index extracted ${snippet.length} characters from the PDF.',
        );
        return null;
      });
    });
  });

  await Future.wait(futures);
  stdout.writeln('All isolates finished without fatal contention.');
}
