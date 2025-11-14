import 'dart:ffi' as ffi;
import 'dart:io' show Directory, Platform, stdout;

import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as path;
import 'package:pdf_text_extraction/pdf_text_extraction.dart';

/// High-level wrapper responsible for delegating calls to the native
/// `pdftotext` bindings while taking care of memory management and basic
/// validation.
class PDFToTextWrapping {
  PDFToTextWrapping({PDFToTextBindings? bindings})
      : _bindings = bindings ?? _createBindings();

  static String _lastError = '';

  /// Last diagnostic message sent from the native layer.
  static String get lastError => _lastError;

  /// Resets the diagnostics buffer. Useful for tests.
  static void resetLastError() => _lastError = '';

  final PDFToTextBindings _bindings;

  static PDFToTextBindings _createBindings() {
    final libraryPath = Platform.isLinux
        ? path.join(Directory.current.path, 'libpdftotext.so')
        : 'pdftotext.dll';
    final dylib = ffi.DynamicLibrary.open(libraryPath);
    return PDFToTextBindings(dylib);
  }

  static void _logCallbackExtractText(ffi.Pointer<ffi.Int8> msg) {
    _lastError = nativeInt8ToString(msg);
    stdout.writeln('PDFToTextWrapping@ExtractText log: $_lastError');
  }

  static void _logCallbackGetPagesCount(ffi.Pointer<ffi.Int8> msg) {
    _lastError = nativeInt8ToString(msg);
    stdout.writeln('PDFToTextWrapping@GetPagesCount log: $_lastError');
  }

  /// Extracts text for the given [path].
  ///
  /// Throws an [ArgumentError] if the provided parameters are invalid and a
  /// generic [Exception] when the native call fails.
  String extractText(
    String path, {
    int startPage = 1,
    int endPage = 0,
    String textOutEnc = 'UTF-8',
    String layout = 'rawOrder',
    String? ownerPassword,
    String? userPassword,
    ffi.Allocator allocator = calloc,
  }) {
    if (path.isEmpty) {
      throw ArgumentError.value(path, 'path', 'Path must not be empty.');
    }
    if (startPage < 1) {
      throw ArgumentError.value(
          startPage, 'startPage', 'Start page must be >= 1.');
    }
    if (endPage < 0) {
      throw ArgumentError.value(endPage, 'endPage', 'End page must be >= 0.');
    }
    if (endPage != 0 && endPage < startPage) {
      throw ArgumentError.value(
        endPage,
        'endPage',
        'End page must be >= start page when specified.',
      );
    }

    final pathPtr = stringToNativeInt8(path, allocator: allocator);
    final textOutEncPtr = stringToNativeInt8(textOutEnc, allocator: allocator);
    final layoutPtr = stringToNativeInt8(layout, allocator: allocator);
    final textOutPtr = allocator<ffi.Pointer<ffi.Int8>>();

    final ownerPasswordPtr = ownerPassword != null
        ? stringToNativeInt8(ownerPassword, allocator: allocator)
        : ffi.nullptr;
    final userPasswordPtr = userPassword != null
        ? stringToNativeInt8(userPassword, allocator: allocator)
        : ffi.nullptr;

    try {
      final logCallbackPtr =
          ffi.Pointer.fromFunction<ffi.Void Function(ffi.Pointer<ffi.Int8>)>(
        _logCallbackExtractText,
      );

      final result = _bindings.extractText(
        pathPtr,
        startPage,
        endPage,
        textOutEncPtr,
        layoutPtr,
        textOutPtr,
        logCallbackPtr,
        ownerPasswordPtr,
        userPasswordPtr,
      );

      final textResult = nativeInt8ToString(textOutPtr.value);
      if (result == 0) {
        return textResult;
      }
      throw Exception('Error extracting text from PDF: $_lastError');
    } finally {
      if (ownerPassword != null) {
        allocator.free(ownerPasswordPtr);
      }
      if (userPassword != null) {
        allocator.free(userPasswordPtr);
      }
      allocator.free(pathPtr);
      allocator.free(textOutEncPtr);
      allocator.free(layoutPtr);
      allocator.free(textOutPtr);
    }
  }

  /// Returns the number of pages for the document referenced by [path].
  int getPagesCount(
    String path, {
    String? ownerPassword,
    String? userPassword,
    ffi.Allocator allocator = calloc,
  }) {
    if (path.isEmpty) {
      throw ArgumentError.value(path, 'path', 'Path must not be empty.');
    }

    final pathPtr = stringToNativeInt8(path, allocator: allocator);
    final ownerPasswordPtr = ownerPassword != null
        ? stringToNativeInt8(ownerPassword, allocator: allocator)
        : ffi.nullptr;
    final userPasswordPtr = userPassword != null
        ? stringToNativeInt8(userPassword, allocator: allocator)
        : ffi.nullptr;

    try {
      final logCallbackPtr =
          ffi.Pointer.fromFunction<ffi.Void Function(ffi.Pointer<ffi.Int8>)>(
        _logCallbackGetPagesCount,
      );

      final result = _bindings.getNumPages(
          pathPtr, logCallbackPtr, ownerPasswordPtr, userPasswordPtr);

      if (result != -1) {
        return result;
      }
      throw Exception('Error get pages count from PDF: $_lastError');
    } finally {
      if (ownerPassword != null) {
        allocator.free(ownerPasswordPtr);
      }
      if (userPassword != null) {
        allocator.free(userPasswordPtr);
      }
      allocator.free(pathPtr);
    }
  }
}
