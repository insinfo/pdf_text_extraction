// ignore: unused_shown_name
import 'dart:io' show Platform, Directory;
// ignore: unused_import
import 'package:ffi/ffi.dart';
import 'dart:ffi';
import 'package:path/path.dart' as path;

import 'package:pdf_text_extraction/pdf_text_extraction.dart';
import 'package:pdf_text_extraction/src/pdf_to_text_bindings.dart';

void logCallback(Pointer<Int8> msg) {
  print(nativeInt8ToString(msg));
}

void textOutputFunc(Pointer<Void> stream, Pointer<Int8> text, int len) {
  print(nativeInt8ToString(text));
}

const except = -1;
typedef dart_callback = int Function(Pointer<Int8>);
void main() {
  //
  var libraryPath =
      'C:/MyCppProjects/xpdf-4.03/build/xpdf/Release/pdftotext.dll';
  //path.join(Directory.current.path, 'pdftotext.dll');
  final dylib = DynamicLibrary.open(libraryPath);

  var pdf = PDFToTextBindings(dylib);

  var uriPointer = stringToNativeInt8('1417.pdf', allocator: calloc);
  var textOutEnc = stringToNativeInt8('UTF-8', allocator: calloc);
  var layout = stringToNativeInt8('rawOrder', allocator: calloc);

  var lgf = Pointer.fromFunction<Void Function(Pointer<Int8>)>(logCallback);

  /* var tof = ffi.Pointer.fromFunction<
      ffi.Void Function(ffi.Pointer<ffi.Void>, ffi.Pointer<ffi.Int8>,
          ffi.Int32)>(textOutputFunc);*/

  // ignore: omit_local_variable_types
  Pointer<Pointer<Int8>> textOut = calloc();

  var result = pdf.extractText(
      uriPointer, 1, 1, textOutEnc, layout, textOut, lgf, nullptr, nullptr);

  var textResult = nativeInt8ToString(textOut.value);

  calloc.free(uriPointer);
  calloc.free(textOutEnc);
  calloc.free(textOut);

  if (result == 0) {
    print('result ok: $textResult');
  } else {
    print('erro on text extraction');
  }
}
