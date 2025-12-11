import 'dart:convert';

/// Encodes JSON data into TOON (Token-Oriented Object Notation) format.
///
/// TOON is a compact format that uses:
/// - Indentation for nested objects (like YAML)
/// - Tabular format for uniform arrays (like CSV)
/// - Minimal punctuation to reduce token count
class ToonEncoder {
  /// The indentation string to use (default: 2 spaces)
  final String indent;

  /// Creates a new TOON encoder.
  ///
  /// [indent] specifies the indentation string (default: '  ' - 2 spaces)
  ToonEncoder({this.indent = '  '});

  /// Encodes a JSON object/value into TOON format.
  ///
  /// [json] can be a Map, List, or primitive value (String, num, bool, null)
  ///
  /// Example:
  /// ```dart
  /// final encoder = ToonEncoder();
  /// final toon = encoder.encode({'name': 'Alice', 'age': 30});
  /// print(toon); // name: Alice\nage: 30
  /// ```
  String encode(dynamic json) {
    if (json is String) {
      return json;
    }

    if (json is Map) {
      return _encodeObject(json, 0);
    } else if (json is List) {
      return _encodeArray(json, '', 0);
    } else {
      return _encodePrimitive(json);
    }
  }

  /// Encodes a JSON string and returns TOON format.
  ///
  /// This is a convenience method that parses JSON string first.
  String encodeFromJson(String jsonString) {
    final json = jsonDecode(jsonString);
    return encode(json);
  }

  String _encodeObject(Map<dynamic, dynamic> obj, int level) {
    final buffer = StringBuffer();
    final entries = obj.entries.toList();

    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final key = entry.key.toString();
      final value = entry.value;

      if (i > 0) {
        buffer.writeln();
      }

      buffer.write(indent * level);
      buffer.write(_encodeKey(key));

      if (value is Map) {
        buffer.write(':');
        buffer.writeln();
        buffer.write(_encodeObject(value, level + 1));
      } else if (value is List) {
        buffer.write(_encodeArray(value, key, level));
      } else {
        buffer.write(': ');
        buffer.write(_encodeValue(value));
      }
    }

    return buffer.toString();
  }

  String _encodeArray(List list, String key, int level) {
    if (list.isEmpty) {
      return '[]';
    }

    // Check if all elements are primitives (not objects or arrays)
    final allPrimitives =
        list.every((e) => e == null || e is String || e is num || e is bool);

    if (allPrimitives) {
      // Inline primitive array: key[n]: val1,val2,val3
      final values = list.map((e) => _encodeValue(e)).join(',');
      return '[${list.length}]: $values';
    }

    // Check if all elements are objects with the same keys (uniform)
    final allObjects = list.every((e) => e is Map);

    if (allObjects && list.isNotEmpty) {
      final firstKeys = (list[0] as Map).keys.toSet();
      final allSameKeys = list.every((e) {
        final keys = (e as Map).keys.toSet();
        return keys.length == firstKeys.length && keys.containsAll(firstKeys);
      });

      if (allSameKeys) {
        // Tabular format for uniform objects
        return _encodeTabularArray(list.cast<Map>(), level);
      }
    }

    // Mixed or non-uniform array - use expanded list format
    return _encodeExpandedArray(list, level);
  }

  String _encodeTabularArray(List<Map> list, int level) {
    if (list.isEmpty) return '[0]{}:';

    final keys = list[0].keys.map((k) => k.toString()).toList();
    final buffer = StringBuffer();

    // Header: arrayName[count]{key1,key2,key3}:
    buffer.write(
        '[${list.length}]{${keys.map((k) => _encodeKey(k)).join(',')}}:');

    // Rows: one per line
    for (var obj in list) {
      buffer.writeln();
      buffer.write(indent * (level + 1));
      final values = keys.map((k) => _encodeValue(obj[k])).join(',');
      buffer.write(values);
    }

    return buffer.toString();
  }

  String _encodeExpandedArray(List list, int level) {
    final buffer = StringBuffer();
    buffer.write('[${list.length}]:');

    for (var item in list) {
      buffer.writeln();
      buffer.write(indent * (level + 1));

      if (item is Map) {
        buffer.write(_encodeObject(item, level + 1));
      } else if (item is List) {
        buffer.write(_encodeArray(item, '', level + 1));
      } else {
        buffer.write(_encodeValue(item));
      }
    }

    return buffer.toString();
  }

  String _encodeKey(String key) {
    // Keys need quoting if they contain special characters or look like literals
    if (_needsQuoting(key) || _looksLikeLiteral(key)) {
      return _quoteString(key);
    }
    return key;
  }

  String _encodeValue(dynamic value) {
    if (value == null) {
      return 'null';
    } else if (value is bool) {
      return value.toString();
    } else if (value is num) {
      return value.toString();
    } else if (value is String) {
      return _encodeStringValue(value);
    } else {
      return value.toString();
    }
  }

  String _encodePrimitive(dynamic value) {
    return _encodeValue(value);
  }

  String _encodeStringValue(String str) {
    if (_needsQuoting(str)) {
      return _quoteString(str);
    }
    return str;
  }

  bool _needsQuoting(String str) {
    if (str.isEmpty) return true;

    // Check for special characters that require quoting
    final specialChars = [',', ':', '{', '}', '[', ']', '\n', '\r', '\t'];
    if (specialChars.any((c) => str.contains(c))) {
      return true;
    }

    // Check for leading/trailing whitespace
    if (str.trim() != str) {
      return true;
    }

    return false;
  }

  bool _looksLikeLiteral(String str) {
    // Check if string looks like a boolean or null literal
    return str == 'true' || str == 'false' || str == 'null';
  }

  String _quoteString(String str) {
    // Escape special characters
    var escaped = str
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')
        .replaceAll('\t', '\\t');

    return '"$escaped"';
  }
}
