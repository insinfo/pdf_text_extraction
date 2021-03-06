// AUTO GENERATED FILE, DO NOT EDIT.
//
// Generated by `package:ffigen`.
import 'dart:ffi' as ffi;

/// Bindings to PDFTextExtraction
class PDFTextExtractionBindings {
  /// Holds the symbol lookup function.
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
      _lookup;

  /// The symbols are looked up in [dynamicLibrary].
  PDFTextExtractionBindings(ffi.DynamicLibrary dynamicLibrary)
      : _lookup = dynamicLibrary.lookup;

  /// The symbols are looked up with [lookup].
  PDFTextExtractionBindings.fromLookup(
      ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
          lookup)
      : _lookup = lookup;

  ffi.Pointer<ffi.Int8> extractTextAsXML(
    ffi.Pointer<ffi.Int8> inFilePath,
    int startPage,
    int endPage,
    ffi.Pointer<ffi.NativeFunction<_typedefC_1>> callback,
  ) {
    return _extractTextAsXML(
      inFilePath,
      startPage,
      endPage,
      callback,
    );
  }

  late final _extractTextAsXML_ptr =
      _lookup<ffi.NativeFunction<_c_extractTextAsXML>>('extractTextAsXML');
  late final _dart_extractTextAsXML _extractTextAsXML =
      _extractTextAsXML_ptr.asFunction<_dart_extractTextAsXML>();

  ffi.Pointer<ffi.Int8> extractText(
    ffi.Pointer<ffi.Int8> inFilePath,
    int startPage,
    int endPage,
    ffi.Pointer<ffi.NativeFunction<_typedefC_2>> callback,
  ) {
    return _extractText(
      inFilePath,
      startPage,
      endPage,
      callback,
    );
  }

  late final _extractText_ptr =
      _lookup<ffi.NativeFunction<_c_extractText>>('extractText');
  late final _dart_extractText _extractText =
      _extractText_ptr.asFunction<_dart_extractText>();

  int getPagesCount(
    ffi.Pointer<ffi.Int8> inFilePath,
    ffi.Pointer<ffi.NativeFunction<_typedefC_3>> callback,
  ) {
    return _getPagesCount(
      inFilePath,
      callback,
    );
  }

  late final _getPagesCount_ptr =
      _lookup<ffi.NativeFunction<_c_getPagesCount>>('getPagesCount');
  late final _dart_getPagesCount _getPagesCount =
      _getPagesCount_ptr.asFunction<_dart_getPagesCount>();
}

typedef _typedefC_1 = ffi.Int32 Function(
  ffi.Pointer<ffi.Int8>,
);

typedef _c_extractTextAsXML = ffi.Pointer<ffi.Int8> Function(
  ffi.Pointer<ffi.Int8> inFilePath,
  ffi.Int32 startPage,
  ffi.Int32 endPage,
  ffi.Pointer<ffi.NativeFunction<_typedefC_1>> callback,
);

typedef _dart_extractTextAsXML = ffi.Pointer<ffi.Int8> Function(
  ffi.Pointer<ffi.Int8> inFilePath,
  int startPage,
  int endPage,
  ffi.Pointer<ffi.NativeFunction<_typedefC_1>> callback,
);

typedef _typedefC_2 = ffi.Int32 Function(
  ffi.Pointer<ffi.Int8>,
);

typedef _c_extractText = ffi.Pointer<ffi.Int8> Function(
  ffi.Pointer<ffi.Int8> inFilePath,
  ffi.Int32 startPage,
  ffi.Int32 endPage,
  ffi.Pointer<ffi.NativeFunction<_typedefC_2>> callback,
);

typedef _dart_extractText = ffi.Pointer<ffi.Int8> Function(
  ffi.Pointer<ffi.Int8> inFilePath,
  int startPage,
  int endPage,
  ffi.Pointer<ffi.NativeFunction<_typedefC_2>> callback,
);

typedef _typedefC_3 = ffi.Int32 Function(
  ffi.Pointer<ffi.Int8>,
);

typedef _c_getPagesCount = ffi.Int32 Function(
  ffi.Pointer<ffi.Int8> inFilePath,
  ffi.Pointer<ffi.NativeFunction<_typedefC_3>> callback,
);

typedef _dart_getPagesCount = int Function(
  ffi.Pointer<ffi.Int8> inFilePath,
  ffi.Pointer<ffi.NativeFunction<_typedefC_3>> callback,
);
