// file: pdf_to_text_wrapping_service.dart
import 'dart:async';

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pdf_text_extraction/pdf_text_extraction.dart';

/// Service that serializes [PDFToTextWrapping] access across isolates (and
/// even processes) by coordinating through a filesystem mutex.
///
/// This flavour follows the "Managing isolate contention" recommendation: it is
/// `await`-friendly and cross-process, albeit slower than an in-process lock.
class PDFToTextWrappingService {
  // Process-wide singleton: within a Dart isolate this resolves to the same
  // instance; the named mutex keeps multiple isolates in sync.
  static final PDFToTextWrappingService _instance =
      PDFToTextWrappingService._internal();
  factory PDFToTextWrappingService() => _instance;

  PDFToTextWrappingService._internal();

  final _FileMutex _mutex = _FileMutex('pdftotext_bindings_global.lock');

  PDFToTextWrapping? _wrapper;

  /// Runs [action] with exclusive access to the native wrapper.
  ///
  /// Use this anywhere you need the wrapper. Example:
  ///
  ///   await PDFToTextWrappingService().run((pdf) {
  ///     final text = pdf.extractText('document.pdf');
  ///     stdout.writeln(text);
  ///   });
  ///
  /// (Requires `dart:io` to access `stdout`.)
  ///
  Future<T> run<T>(FutureOr<T> Function(PDFToTextWrapping pdf) action) {
    // Ensures mutual exclusion across isolates and threads.
    return _mutex.runExclusive(() async {
      _wrapper ??= _createWrapper();
      return await Future.sync(() => action(_wrapper!));
    });
  }

  /// Disposes the cached wrapper when you want to tear it down.
  ///
  /// Useful in tests or when you need to release the handle to load the
  /// library from a different path later.
  Future<void> dispose() {
    return _mutex.runExclusive(() async {
      _wrapper = null;
    });
  }

  /// Creates a fresh [PDFToTextWrapping] backed by dedicated bindings.
  PDFToTextWrapping _createWrapper({PDFToTextBindings? bindings}) {
    return PDFToTextWrapping(bindings: bindings);
  }
}

/// Named mutex implemented via [File.lock] so multiple isolates coordinate.
class _FileMutex {
  /// Simple cross-process mutex built around a named temporary file.
  _FileMutex(String name)
      : _lockFile = File(p.join(Directory.systemTemp.path, name));

  final File _lockFile;

  /// Runs [action] while holding an exclusive [File.lock].
  Future<T> runExclusive<T>(FutureOr<T> Function() action) async {
    _lockFile.createSync(recursive: true);
    final handle = await _lockFile.open(mode: FileMode.write);
    try {
      await handle.lock(FileLock.blockingExclusive);
      try {
        return await Future.sync(action);
      } finally {
        await handle.unlock();
      }
    } finally {
      await handle.close();
    }
  }
}

class MissingLibraryException implements Exception {
  /// Thrown when none of the expected native libraries can be located on disk.
  MissingLibraryException({required this.path});

  final String path;

  @override
  String toString() =>
      'MissingLibraryException: Unable to locate native library starting at "$path".';
}
