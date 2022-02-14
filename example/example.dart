// ignore: unused_shown_name
import 'dart:io' show Platform, Directory;
// ignore: unused_import
import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as path;
import 'dart:ffi' as ffi;
import 'package:pdf_text_extraction/pdf_text_extraction.dart';

int callback(ffi.Pointer<ffi.Int8> msg) {
  print(nativeInt8ToString(msg));
  return 0;
}

const except = -1;
typedef dart_callback = int Function(ffi.Pointer<ffi.Int8>);
void main() {
  //if (Platform.isWindows) {
  var libraryPath = path.join(Directory.current.path, 'TextExtraction.so');
  final dylib = ffi.DynamicLibrary.open(libraryPath);

  var pdf = PDFTextExtractionBindings(dylib);
  var allocator = malloc;
  var uriPointer = stringToNativeInt8(
      '1417.pdf',
      allocator: malloc);

  var result = pdf.extractText(
      uriPointer,
      0,
      -1,
      ffi.Pointer.fromFunction<
          ffi.Int32 Function(
        ffi.Pointer<ffi.Int8>,
      )>(callback, except));

  allocator.free(uriPointer);
  var text = nativeInt8ToString(result);
  if (text != '-1') {
    print('text: $text');
  } else {
    print('erro ao extrair testo');
  }
}
