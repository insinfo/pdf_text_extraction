import 'dart:ffi' as ffi;
import 'dart:io' show Directory, Platform, stdout;

import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as path;
import 'package:pdf_text_extraction/pdf_text_extraction.dart';

int logCallback(ffi.Pointer<ffi.Int8> msg) {
  stdout.writeln(nativeInt8ToString(msg));
  return 0;
}

const _fallbackResult = -1;
void main() {
  final libraryName =
      Platform.isLinux ? 'TextExtraction.so' : 'TextExtraction.dll';
  final libraryPath = path.join(Directory.current.path, libraryName);
  final dylib = ffi.DynamicLibrary.open(libraryPath);

  final bindings = PDFTextExtractionBindings(dylib);
  final uriPointer = stringToNativeInt8('1417.pdf', allocator: malloc);
  final pages = bindings.getPagesCount(uriPointer, ffi.nullptr);
  stdout.writeln('pages $pages');

  final result = bindings.extractText(
    uriPointer,
    0,
    -1,
    ffi.Pointer.fromFunction<
        ffi.Int32 Function(
      ffi.Pointer<ffi.Int8>,
    )>(logCallback, _fallbackResult),
  );

  malloc.free(uriPointer);
  final text = nativeInt8ToString(result);
  if (text != '-1') {
    stdout.writeln('text: $text');
  } else {
    stdout.writeln('erro ao extrair texto');
  }
}
