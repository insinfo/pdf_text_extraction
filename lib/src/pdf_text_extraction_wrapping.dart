import 'dart:io' show Platform, Directory;

import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as path;
import 'package:pdf_text_extraction/src/pdf_text_extraction_bindings.dart';
import 'dart:ffi' as ffi;

import 'package:pdf_text_extraction/src/utils.dart';

class PDFTextExtractionWrapping {
  PDFTextExtractionBindings? pdfTextExtractionBindings;
  static const except = -1;
  static String _lastError = '';
  static int _logCallback(ffi.Pointer<ffi.Int8> msg) {
    _lastError = nativeInt8ToString(msg);
    print('PDFTextExtractionWrapping log: $_lastError');
    return 0;
  }

  PDFTextExtractionWrapping() {
    var libraryPath = 'TextExtraction.dll';
    if (Platform.isLinux) {
      libraryPath = path.join(Directory.current.path, 'libTextExtraction.so');
    }
    final dylib = ffi.DynamicLibrary.open(libraryPath);
    pdfTextExtractionBindings = PDFTextExtractionBindings(dylib);
  }

  String extractTextAsXML(String inputPdfFilePath,
      {int startPage = 0, int endPage = -1, ffi.Allocator allocator = calloc}) {
    var uriPointer = stringToNativeInt8(inputPdfFilePath, allocator: allocator);
    try {
      var result = pdfTextExtractionBindings!.extractTextAsXML(
          uriPointer,
          startPage,
          endPage,
          ffi.Pointer.fromFunction<
              ffi.Int32 Function(
            ffi.Pointer<ffi.Int8>,
          )>(_logCallback, except));

      var text = nativeInt8ToString(result);
      if (text != '-1') {
        return text;
      } else {
        throw Exception('Error extracting text from PDF: $_lastError');
      }
    } catch (e) {
      rethrow;
    } finally {
      allocator.free(uriPointer);
    }
  }

  String extractText(String inputPdfFilePath,
      {int startPage = 0, int endPage = -1, ffi.Allocator allocator = calloc}) {
    var uriPointer = stringToNativeInt8(inputPdfFilePath, allocator: allocator);
    try {
      var result = pdfTextExtractionBindings!.extractText(
          uriPointer,
          startPage,
          endPage,
          ffi.Pointer.fromFunction<
              ffi.Int32 Function(
            ffi.Pointer<ffi.Int8>,
          )>(_logCallback, except));

      var text = nativeInt8ToString(result);
      if (text != '-1') {
        return text;
      } else {
        throw Exception('Error extracting text from PDF: $_lastError');
      }
    } catch (e) {
      rethrow;
    } finally {
      allocator.free(uriPointer);
    }
  }

  int getPagesCount(String inputPdfFilePath,
      {ffi.Allocator allocator = calloc}) {
    var uriPointer = stringToNativeInt8(inputPdfFilePath, allocator: allocator);
    try {
      var result = pdfTextExtractionBindings!.getPagesCount(
          uriPointer,
          ffi.Pointer.fromFunction<
              ffi.Int32 Function(
            ffi.Pointer<ffi.Int8>,
          )>(_logCallback, except));

      if (result != -1) {
        return result;
      } else {
        throw Exception('Error on PDF pages count: $_lastError');
      }
    } catch (e) {
      rethrow;
    } finally {
      allocator.free(uriPointer);
    }
  }
}
