// ignore: unused_shown_name
import 'dart:io' show Platform, Directory;
// ignore: unused_import
import 'package:ffi/ffi.dart';
import 'dart:ffi';
import 'package:path/path.dart' as path;
import 'package:pdf_text_extraction/pdf_text_extraction.dart';
import 'package:pdf_text_extraction/src/pdf_to_text_bindings.dart';

class PDFToTextWrapping {
  PDFToTextBindings? pdfToTextBindings;
  static String _lastError = '';

  static void _logCallbackExtractText(Pointer<Int8> msg) {
    _lastError = nativeInt8ToString(msg);
    print('PDFToTextWrapping@ExtractText log: $_lastError');
  }

  static void _logCallbackGetPagesCount(Pointer<Int8> msg) {
    _lastError = nativeInt8ToString(msg);
    print('PDFToTextWrapping@GetPagesCount log: $_lastError');
  }

  PDFToTextWrapping() {
    var libraryPath = 'pdftotext.dll';
    if (Platform.isLinux) {
      libraryPath = path.join(Directory.current.path, 'pdftotext.so');
    }
    final dylib = DynamicLibrary.open(libraryPath);
    pdfToTextBindings = PDFToTextBindings(dylib);
  }

  String extractText(String path,
      {int startPage = 1,
      int endPage = 0,
      String textOutEnc = 'UTF-8',
      String layout = 'rawOrder',
      String? ownerPassword,
      String? userPassword,
      Allocator allocator = calloc}) {
    var pathC = stringToNativeInt8(path, allocator: allocator);
    var textOutEncC = stringToNativeInt8(textOutEnc, allocator: allocator);
    var layoutC = stringToNativeInt8(layout, allocator: allocator);
    // ignore: omit_local_variable_types
    Pointer<Pointer<Int8>> textOut = allocator();

    var _ownerPassword = ownerPassword != null
        ? stringToNativeInt8(ownerPassword, allocator: allocator)
        : nullptr;

    var _userPassword = userPassword != null
        ? stringToNativeInt8(userPassword, allocator: allocator)
        : nullptr;
    try {
      var _logCallbackC = Pointer.fromFunction<Void Function(Pointer<Int8>)>(
          _logCallbackExtractText);

      var result = pdfToTextBindings!.extractText(
          pathC,
          startPage,
          endPage,
          textOutEncC,
          layoutC,
          textOut,
          _logCallbackC,
          _ownerPassword,
          _userPassword);

      var textResult = nativeInt8ToString(textOut.value);
      if (result == 0) {
        return textResult;
      } else {
        throw Exception('Error extracting text from PDF: $_lastError');
      }
    } catch (e) {
      rethrow;
    } finally {
      if (ownerPassword != null) {
        allocator.free(_ownerPassword);
      }
      if (userPassword != null) {
        allocator.free(_userPassword);
      }
      allocator.free(pathC);
      allocator.free(textOutEncC);
      allocator.free(textOut);
    }
  }

  int getPagesCount(String path,
      {String? ownerPassword,
      String? userPassword,
      Allocator allocator = calloc}) {
    var pathC = stringToNativeInt8(path, allocator: allocator);

    var _ownerPassword = ownerPassword != null
        ? stringToNativeInt8(ownerPassword, allocator: allocator)
        : nullptr;

    var _userPassword = userPassword != null
        ? stringToNativeInt8(userPassword, allocator: allocator)
        : nullptr;

    try {
      var _logCallbackC = Pointer.fromFunction<Void Function(Pointer<Int8>)>(
          _logCallbackGetPagesCount);

      var result = pdfToTextBindings!
          .getNumPages(pathC, _logCallbackC, _ownerPassword, _userPassword);

      if (result == -1) {
        throw Exception('Error get pages count from PDF: $_lastError');
      } else {
        return result;
      }
    } catch (e) {
      rethrow;
    } finally {
      if (ownerPassword != null) {
        allocator.free(_ownerPassword);
      }
      if (userPassword != null) {
        allocator.free(_userPassword);
      }
      allocator.free(pathC);
    }
  }
}
