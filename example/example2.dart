import 'dart:ffi';
import 'dart:io' show Directory, Platform, stdout;

import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as path;
import 'package:pdf_text_extraction/pdf_text_extraction.dart';

void logCallback(Pointer<Int8> msg) {
  stdout.writeln(nativeInt8ToString(msg));
}

void main() {
  final libraryName = Platform.isLinux ? 'pdftotext.so' : 'pdftotext.dll';
  final libraryPath = path.join(Directory.current.path, libraryName);

  final dylib = DynamicLibrary.open(libraryPath);
  final pdf = PDFToTextBindings(dylib);
  final uriPointer = stringToNativeInt8('1417.pdf');
  final textOutEnc = stringToNativeInt8('UTF-8');
  final layout = stringToNativeInt8('rawOrder');
  final logFunction =
      Pointer.fromFunction<Void Function(Pointer<Int8>)>(logCallback);

  final textOut = calloc<Pointer<Int8>>();

  final result = pdf.extractText(
    uriPointer,
    1,
    1,
    textOutEnc,
    layout,
    textOut,
    logFunction,
    nullptr,
    nullptr,
  );

  final textResult = nativeInt8ToString(textOut.value);

  calloc.free(uriPointer);
  calloc.free(textOutEnc);
  calloc.free(layout);
  calloc.free(textOut);

  if (result == 0) {
    stdout.writeln('result ok: $textResult');
  } else {
    stdout.writeln('erro on text extraction');
  }
}
