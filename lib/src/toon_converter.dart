import 'toon_encoder.dart';
import 'toon_decoder.dart';

/// A convenience class that combines TOON encoding and decoding.
///
/// This class provides a simple API for converting between JSON and TOON formats.
class ToonConverter {
  final ToonEncoder _encoder;
  final ToonDecoder _decoder;

  /// Creates a new TOON converter.
  ///
  /// [indent] specifies the indentation string for encoding (default: '  ')
  ToonConverter({String indent = '  '})
      : _encoder = ToonEncoder(indent: indent),
        _decoder = ToonDecoder();

  /// Encodes a Dart object to TOON format.
  ///
  /// [data] can be a Map, List, or primitive value.
  ///
  /// Example:
  /// ```dart
  /// final converter = ToonConverter();
  /// final toon = converter.toToon({'name': 'Alice', 'age': 30});
  /// ```
  String toToon(dynamic data) {
    return _encoder.encode(data);
  }

  /// Encodes a JSON string to TOON format.
  ///
  /// Example:
  /// ```dart
  /// final converter = ToonConverter();
  /// final toon = converter.jsonToToon('{"name":"Alice","age":30}');
  /// ```
  String jsonToToon(String jsonString) {
    return _encoder.encodeFromJson(jsonString);
  }

  /// Decodes a TOON string to a Dart object.
  ///
  /// Returns a Map, List, or primitive value.
  ///
  /// Example:
  /// ```dart
  /// final converter = ToonConverter();
  /// final data = converter.fromToon('name: Alice\nage: 30');
  /// ```
  dynamic fromToon(String toonString) {
    return _decoder.decode(toonString);
  }

  /// Decodes a TOON string to JSON format.
  ///
  /// Example:
  /// ```dart
  /// final converter = ToonConverter();
  /// final json = converter.toonToJson('name: Alice\nage: 30');
  /// ```
  String toonToJson(String toonString) {
    return _decoder.decodeToJson(toonString);
  }

  /// Gets the encoder instance.
  ToonEncoder get encoder => _encoder;

  /// Gets the decoder instance.
  ToonDecoder get decoder => _decoder;
}
