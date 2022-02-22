# A library to extract text from PDF 
## This lib only works on Linux and Windows at the moment as it depends on compiling forked xpdf for the proper platform.
https://github.com/insinfo/xpdf


### on linux this is the GNU v3 Standard C++ Library:
 sudo apt-get install libstdc++6

### example 1 low level

```dart
import 'dart:io' show Platform, Directory;
import 'package:ffi/ffi.dart';
import 'dart:ffi';
import 'package:path/path.dart' as path;
import 'package:pdf_text_extraction/pdf_text_extraction.dart';
import 'package:pdf_text_extraction/src/pdf_to_text_bindings.dart';

void logCallback(Pointer<Int8> msg) {
  print(nativeInt8ToString(msg));
}

void main() {
  var libraryPath = path.join(Directory.current.path, 'pdftotext.dll');
  if (Platform.isLinux) {
    libraryPath = path.join(Directory.current.path, 'pdftotext.so');
  }

  final dylib = DynamicLibrary.open(libraryPath);
  var pdfLib = PDFToTextBindings(dylib);
  //input pdf file
  var uriPointer = stringToNativeInt8('pdf_file.pdf', allocator: calloc);
  // output text character encoding 
  var textOutEnc = stringToNativeInt8('UTF-8', allocator: calloc);
  var layout = stringToNativeInt8('rawOrder', allocator: calloc);
  //function for print log info
  var lgf = Pointer.fromFunction<Void Function(Pointer<Int8>)>(logCallback);

  Pointer<Pointer<Int8>> textOut = calloc();

  var result = pdfLib.extractText(
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
```


### example 2 hi level

```dart
void main() {
    var pdfLib = PDFToTextWrapping();
    var textResult = pdfLib.extractText('pdf_file.pdf', startPage: 1, endPage: 0);
    print('result: $textResult');
}
```

<!--
# comando para eliminar as exportacoes da dll menos o metodo  extractText
strip --keep-symbol=extractText ./libTextExtraction.so -o libout.so
strip --keep-symbol=extractText /home/insinfo/Documents/pdf-text-extraction/linux/TextExtraction/libTextExtraction.so -o libout.so

-->