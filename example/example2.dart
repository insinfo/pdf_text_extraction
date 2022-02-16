// ignore: unused_shown_name
import 'dart:io' show Platform, Directory;
// ignore: unused_import
import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as path;
import 'dart:ffi' as ffi;
import 'package:pdf_text_extraction/pdf_text_extraction.dart';
import 'package:pdf_text_extraction/src/pdf_to_text_bindings.dart';

void logCallback(ffi.Pointer<ffi.Int8> msg) {
  print(nativeInt8ToString(msg));
}

void textOutputFunc(
    ffi.Pointer<ffi.Void> stream, ffi.Pointer<ffi.Int8> text, int len) {
  print(nativeInt8ToString(text));
}

const except = -1;
typedef dart_callback = int Function(ffi.Pointer<ffi.Int8>);
void main() {
  // 'C:/MyCppProjects/xpdf-4.03/build/xpdf/Release/pdftotext.dll';
  var libraryPath = path.join(Directory.current.path, 'pdftotext.dll');
  final dylib = ffi.DynamicLibrary.open(libraryPath);

  var pdf = PDFToTextBindings(dylib);
  var allocator = malloc;
  var uriPointer = stringToNativeInt8('1417.pdf', allocator: malloc);
  var textOutEnc = stringToNativeInt8('UTF-8', allocator: malloc);
  var layout = stringToNativeInt8('rawOrder', allocator: malloc);

  var lgf = ffi.Pointer.fromFunction<ffi.Void Function(ffi.Pointer<ffi.Int8>)>(
      logCallback);

  var tof = ffi.Pointer.fromFunction<
      ffi.Void Function(ffi.Pointer<ffi.Void>, ffi.Pointer<ffi.Int8>,
          ffi.Int32)>(textOutputFunc);

  var result = pdf.extractText(uriPointer, 1, 1, textOutEnc, layout, tof, lgf);

  allocator.free(uriPointer);
  allocator.free(textOutEnc);

  if (result == 0) {
    print('result ok');
  } else {
    print('erro ao extrair testo');
  }
}
