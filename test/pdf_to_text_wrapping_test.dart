import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart';
import 'package:pdf_text_extraction/pdf_text_extraction.dart';
import 'package:test/test.dart';

class _FakePdfToTextBindings implements PDFToTextBindings {
  _FakePdfToTextBindings({
    this.extractTextStatus = 0,
    this.extractTextResult = 'extracted',
    this.getNumPagesResult = 3,
    this.extractTextErrorMessage,
    this.getNumPagesErrorMessage,
  });

  final int extractTextStatus;
  final String extractTextResult;
  final int getNumPagesResult;
  final String? extractTextErrorMessage;
  final String? getNumPagesErrorMessage;

  final allocations = <ffi.Pointer<ffi.Int8>>[];

  String? lastFileName;
  int? lastFirstPage;
  int? lastLastPage;
  String? lastTextEncoding;
  String? lastLayout;
  String? lastOwnerPassword;
  String? lastUserPassword;

  void dispose() {
    for (final ptr in allocations) {
      calloc.free(ptr);
    }
    allocations.clear();
  }

  @override
  int extractText(
    ffi.Pointer<ffi.Int8> fileName,
    int firstPage,
    int lastPage,
    ffi.Pointer<ffi.Int8> textOutEnc,
    ffi.Pointer<ffi.Int8> layout,
    ffi.Pointer<ffi.Pointer<ffi.Int8>> textOutput,
    ffi.Pointer<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Int8>)>>
        logCallback,
    ffi.Pointer<ffi.Int8> ownerPassword,
    ffi.Pointer<ffi.Int8> userPassword,
  ) {
    lastFileName = nativeInt8ToString(fileName);
    lastFirstPage = firstPage;
    lastLastPage = lastPage;
    lastTextEncoding = nativeInt8ToString(textOutEnc);
    lastLayout = nativeInt8ToString(layout);
    if (ownerPassword != ffi.nullptr) {
      lastOwnerPassword = nativeInt8ToString(ownerPassword);
    }
    if (userPassword != ffi.nullptr) {
      lastUserPassword = nativeInt8ToString(userPassword);
    }

    if (extractTextStatus != 0 && extractTextErrorMessage != null) {
      final log =
          logCallback.asFunction<void Function(ffi.Pointer<ffi.Int8>)>();
      final msgPtr = stringToNativeInt8(extractTextErrorMessage!);
      log(msgPtr);
      calloc.free(msgPtr);
    }

    final textPtr = stringToNativeInt8(extractTextResult);
    allocations.add(textPtr);
    textOutput.value = textPtr;
    return extractTextStatus;
  }

  @override
  int getNumPages(
    ffi.Pointer<ffi.Int8> fileName,
    ffi.Pointer<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Int8>)>>
        logCallback,
    ffi.Pointer<ffi.Int8> ownerPassword,
    ffi.Pointer<ffi.Int8> userPassword,
  ) {
    lastFileName = nativeInt8ToString(fileName);
    if (ownerPassword != ffi.nullptr) {
      lastOwnerPassword = nativeInt8ToString(ownerPassword);
    }
    if (userPassword != ffi.nullptr) {
      lastUserPassword = nativeInt8ToString(userPassword);
    }

    if (getNumPagesResult == -1 && getNumPagesErrorMessage != null) {
      final log =
          logCallback.asFunction<void Function(ffi.Pointer<ffi.Int8>)>();
      final msgPtr = stringToNativeInt8(getNumPagesErrorMessage!);
      log(msgPtr);
      calloc.free(msgPtr);
    }

    return getNumPagesResult;
  }
}

void main() {
  group('PDFToTextWrapping', () {
    test('extractText returns text when native call succeeds', () {
      final bindings = _FakePdfToTextBindings(
        extractTextResult: 'Hello PDF',
      );
      addTearDown(bindings.dispose);
      PDFToTextWrapping.resetLastError();

      final wrapper = PDFToTextWrapping(bindings: bindings);
      final result = wrapper.extractText(
        'demo.pdf',
        startPage: 2,
        endPage: 4,
        ownerPassword: 'owner',
        userPassword: 'user',
      );

      expect(result, equals('Hello PDF'));
      expect(bindings.lastFileName, equals('demo.pdf'));
      expect(bindings.lastFirstPage, equals(2));
      expect(bindings.lastLastPage, equals(4));
      expect(bindings.lastTextEncoding, equals('UTF-8'));
      expect(bindings.lastLayout, equals('rawOrder'));
      expect(bindings.lastOwnerPassword, equals('owner'));
      expect(bindings.lastUserPassword, equals('user'));
      expect(PDFToTextWrapping.lastError, isEmpty);
    });

    test('extractText throws when native call fails', () {
      final bindings = _FakePdfToTextBindings(
        extractTextStatus: -1,
        extractTextResult: '',
        extractTextErrorMessage: 'Failed to extract',
      );
      addTearDown(bindings.dispose);
      PDFToTextWrapping.resetLastError();

      final wrapper = PDFToTextWrapping(bindings: bindings);

      expect(
        () => wrapper.extractText('broken.pdf'),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Failed to extract'),
        )),
      );
      expect(PDFToTextWrapping.lastError, equals('Failed to extract'));
    });

    test('extractText validates arguments', () {
      final wrapper = PDFToTextWrapping(bindings: _FakePdfToTextBindings());

      expect(() => wrapper.extractText(''), throwsArgumentError);
      expect(() => wrapper.extractText('demo.pdf', startPage: 0),
          throwsArgumentError);
      expect(() => wrapper.extractText('demo.pdf', endPage: -1),
          throwsArgumentError);
      expect(
        () => wrapper.extractText('demo.pdf', startPage: 5, endPage: 3),
        throwsArgumentError,
      );
    });

    test('getPagesCount returns value when native call succeeds', () {
      final bindings = _FakePdfToTextBindings(getNumPagesResult: 42);
      addTearDown(bindings.dispose);
      PDFToTextWrapping.resetLastError();

      final wrapper = PDFToTextWrapping(bindings: bindings);
      final result = wrapper.getPagesCount(
        'demo.pdf',
        ownerPassword: 'owner',
        userPassword: 'user',
      );

      expect(result, equals(42));
      expect(bindings.lastFileName, equals('demo.pdf'));
      expect(bindings.lastOwnerPassword, equals('owner'));
      expect(bindings.lastUserPassword, equals('user'));
      expect(PDFToTextWrapping.lastError, isEmpty);
    });

    test('getPagesCount throws when native call fails', () {
      final bindings = _FakePdfToTextBindings(
        getNumPagesResult: -1,
        getNumPagesErrorMessage: 'Unable to load PDF',
      );
      addTearDown(bindings.dispose);
      PDFToTextWrapping.resetLastError();

      final wrapper = PDFToTextWrapping(bindings: bindings);

      expect(
        () => wrapper.getPagesCount('broken.pdf'),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Unable to load PDF'),
        )),
      );
      expect(PDFToTextWrapping.lastError, equals('Unable to load PDF'));
    });
  });
}
