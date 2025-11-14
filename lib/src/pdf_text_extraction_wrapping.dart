import 'dart:ffi' as ffi;
import 'dart:io' show Directory, Platform, stdout;

import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as path;
import 'package:pdf_text_extraction/src/pdf_text_extraction_bindings.dart';
import 'package:pdf_text_extraction/src/utils/utils.dart';

class PDFTextExtractionWrapping {
  PDFTextExtractionWrapping() : _bindings = _createBindings();

  static const _fallbackCode = -1;
  static String _lastError = '';

  final PDFTextExtractionBindings _bindings;

  static PDFTextExtractionBindings _createBindings() {
    final libraryPath = Platform.isLinux
        ? path.join(Directory.current.path, 'libTextExtraction.so')
        : 'TextExtraction.dll';
    final dylib = ffi.DynamicLibrary.open(libraryPath);
    return PDFTextExtractionBindings(dylib);
  }

  static int _logCallback(ffi.Pointer<ffi.Int8> msg) {
    _lastError = nativeInt8ToString(msg);
    stdout.writeln('PDFTextExtractionWrapping log: $_lastError');
    return 0;
  }

  String extractTextAsXML(
    String inputPdfFilePath, {
    int startPage = 0,
    int endPage = -1,
    ffi.Allocator allocator = calloc,
  }) {
    final uriPointer =
        stringToNativeInt8(inputPdfFilePath, allocator: allocator);
    try {
      final result = _bindings.extractTextAsXML(
        uriPointer,
        startPage,
        endPage,
        ffi.Pointer.fromFunction<
            ffi.Int32 Function(
              ffi.Pointer<ffi.Int8>,
            )>(_logCallback, _fallbackCode),
      );

      final text = nativeInt8ToString(result);
      if (text != '-1') {
        return text;
      }
      throw Exception('Error extracting text from PDF: $_lastError');
    } finally {
      allocator.free(uriPointer);
    }
  }

  String extractText(
    String inputPdfFilePath, {
    int startPage = 0,
    int endPage = -1,
    ffi.Allocator allocator = calloc,
  }) {
    final uriPointer =
        stringToNativeInt8(inputPdfFilePath, allocator: allocator);
    try {
      final result = _bindings.extractText(
        uriPointer,
        startPage,
        endPage,
        ffi.Pointer.fromFunction<
            ffi.Int32 Function(
              ffi.Pointer<ffi.Int8>,
            )>(_logCallback, _fallbackCode),
      );

      final text = nativeInt8ToString(result);
      if (text != '-1') {
        return text;
      }
      throw Exception('Error extracting text from PDF: $_lastError');
    } finally {
      allocator.free(uriPointer);
    }
  }

  int getPagesCount(
    String inputPdfFilePath, {
    ffi.Allocator allocator = calloc,
  }) {
    final uriPointer =
        stringToNativeInt8(inputPdfFilePath, allocator: allocator);
    try {
      final result = _bindings.getPagesCount(
        uriPointer,
        ffi.Pointer.fromFunction<
            ffi.Int32 Function(
              ffi.Pointer<ffi.Int8>,
            )>(_logCallback, _fallbackCode),
      );

      if (result != -1) {
        return result;
      }
      throw Exception('Error on PDF pages count: $_lastError');
    } finally {
      allocator.free(uriPointer);
    }
  }
}
