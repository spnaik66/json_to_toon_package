import 'dart:convert';

/// Decodes TOON (Token-Oriented Object Notation) format into JSON data.
///
/// TOON decoder parses the compact TOON format and converts it back to
/// standard Dart objects (Map, List, primitives).
class ToonDecoder {
  /// Creates a new TOON decoder.
  ToonDecoder();

  /// Decodes a TOON string into a Dart object.
  ///
  /// Returns a Map, List, or primitive value depending on the TOON content.
  ///
  /// Example:
  /// ```dart
  /// final decoder = ToonDecoder();
  /// final data = decoder.decode('name: Alice\nage: 30');
  /// print(data); // {name: Alice, age: 30}
  /// ```
  dynamic decode(String toon) {
    final lines = toon.split('\n');
    final result = _parseLines(lines, 0);
    return result.value;
  }

  /// Decodes TOON and returns as JSON string.
  String decodeToJson(String toon) {
    final data = decode(toon);
    return jsonEncode(data);
  }

  _ParseResult _parseLines(List<String> lines, int startIndex) {
    final obj = <String, dynamic>{};
    var i = startIndex;

    while (i < lines.length) {
      final line = lines[i];

      // Skip empty lines
      if (line.trim().isEmpty) {
        i++;
        continue;
      }

      final indent = _getIndentLevel(line);

      // If indent decreased, we're done with this object
      if (i > startIndex && indent < _getIndentLevel(lines[startIndex])) {
        break;
      }

      final trimmed = line.trim();

      // Check if this is an array declaration: key[count]... or key[count]{...}:
      final arrayKeyMatch = RegExp(r'^([^\[]+)(\[.+)$').firstMatch(trimmed);

      if (arrayKeyMatch != null) {
        // This is an array
        final key = _unquoteString(arrayKeyMatch.group(1)!.trim());
        final arrayPart = arrayKeyMatch.group(2)!;
        final arrayResult = _parseArray(lines, i, arrayPart);
        obj[key] = arrayResult.value;
        i = arrayResult.nextIndex;
        continue;
      }

      // Parse key-value pair
      final colonIndex = _findUnquotedColon(trimmed);
      if (colonIndex == -1) {
        i++;
        continue;
      }

      final key = _unquoteString(trimmed.substring(0, colonIndex).trim());
      final valueStr = trimmed.substring(colonIndex + 1).trim();

      if (valueStr.isEmpty) {
        // Nested object on next line
        i++;
        final nestedResult = _parseLines(lines, i);
        obj[key] = nestedResult.value;
        i = nestedResult.nextIndex;
      } else {
        // Simple value
        obj[key] = _parseValue(valueStr);
        i++;
      }
    }

    return _ParseResult(obj, i);
  }

  _ParseResult _parseArray(List<String> lines, int lineIndex, String header) {
    // Parse array header: [count] or [count]{keys}: or [count]:
    final countMatch = RegExp(r'\[(\d+)\]').firstMatch(header);
    if (countMatch == null) {
      return _ParseResult([], lineIndex + 1);
    }

    final count = int.parse(countMatch.group(1)!);

    // Check for tabular format: [count]{key1,key2}:
    final tabularMatch =
        RegExp(r'\[(\d+)\]\{([^}]+)\}:(.*)').firstMatch(header);

    if (tabularMatch != null) {
      // Tabular array of objects
      final keysStr = tabularMatch.group(2)!;
      final keys = keysStr.split(',').map((k) => k.trim()).toList();
      final remainingValues = tabularMatch.group(3)!.trim();

      final result = <Map<String, dynamic>>[];
      var currentLine = lineIndex;

      // If values are on the same line
      if (remainingValues.isNotEmpty) {
        final values = _parseDelimitedValues(remainingValues);
        if (values.length == keys.length) {
          final obj = <String, dynamic>{};
          for (var i = 0; i < keys.length; i++) {
            obj[_unquoteString(keys[i])] = values[i];
          }
          result.add(obj);
        }
      }

      // Parse remaining rows
      currentLine++;
      final baseIndent = _getIndentLevel(lines[lineIndex]);

      while (result.length < count && currentLine < lines.length) {
        final line = lines[currentLine];
        if (line.trim().isEmpty) {
          currentLine++;
          continue;
        }

        final lineIndent = _getIndentLevel(line);
        if (lineIndent <= baseIndent) {
          break;
        }

        final values = _parseDelimitedValues(line.trim());
        if (values.length == keys.length) {
          final obj = <String, dynamic>{};
          for (var i = 0; i < keys.length; i++) {
            obj[_unquoteString(keys[i])] = values[i];
          }
          result.add(obj);
        }

        currentLine++;
      }

      return _ParseResult(result, currentLine);
    }

    // Check for inline primitive array: [count]: val1,val2,val3
    final inlineMatch = RegExp(r'\[(\d+)\]:\s*(.+)').firstMatch(header);

    if (inlineMatch != null) {
      final valuesStr = inlineMatch.group(2)!;

      // Check if values are on same line
      if (!valuesStr.trim().isEmpty) {
        final values = _parseDelimitedValues(valuesStr);
        return _ParseResult(values, lineIndex + 1);
      }

      // Values on next lines (expanded list)
      final result = [];
      var currentLine = lineIndex + 1;
      final baseIndent = _getIndentLevel(lines[lineIndex]);

      while (result.length < count && currentLine < lines.length) {
        final line = lines[currentLine];
        if (line.trim().isEmpty) {
          currentLine++;
          continue;
        }

        final lineIndent = _getIndentLevel(line);
        if (lineIndent <= baseIndent) {
          break;
        }

        result.add(_parseValue(line.trim()));
        currentLine++;
      }

      return _ParseResult(result, currentLine);
    }

    return _ParseResult([], lineIndex + 1);
  }

  List<dynamic> _parseDelimitedValues(String str) {
    final values = <dynamic>[];
    var current = StringBuffer();
    var inQuotes = false;
    var escaped = false;

    for (var i = 0; i < str.length; i++) {
      final char = str[i];

      if (escaped) {
        current.write(char);
        escaped = false;
        continue;
      }

      if (char == '\\') {
        escaped = true;
        continue;
      }

      if (char == '"') {
        inQuotes = !inQuotes;
        current.write(char);
        continue;
      }

      if (char == ',' && !inQuotes) {
        values.add(_parseValue(current.toString().trim()));
        current = StringBuffer();
        continue;
      }

      current.write(char);
    }

    if (current.isNotEmpty) {
      values.add(_parseValue(current.toString().trim()));
    }

    return values;
  }

  dynamic _parseValue(String str) {
    final trimmed = str.trim();

    if (trimmed == 'null') {
      return null;
    }

    if (trimmed == 'true') {
      return true;
    }

    if (trimmed == 'false') {
      return false;
    }

    // Try to parse as number
    final num? number = num.tryParse(trimmed);
    if (number != null) {
      return number;
    }

    // String (possibly quoted)
    return _unquoteString(trimmed);
  }

  String _unquoteString(String str) {
    final trimmed = str.trim();

    if (trimmed.length >= 2 &&
        trimmed.startsWith('"') &&
        trimmed.endsWith('"')) {
      // Remove quotes and unescape
      var unescaped = trimmed.substring(1, trimmed.length - 1);
      unescaped = unescaped
          .replaceAll('\\n', '\n')
          .replaceAll('\\r', '\r')
          .replaceAll('\\t', '\t')
          .replaceAll('\\"', '"')
          .replaceAll('\\\\', '\\');
      return unescaped;
    }

    return trimmed;
  }

  int _getIndentLevel(String line) {
    var count = 0;
    for (var char in line.runes) {
      if (char == 32) {
        // space
        count++;
      } else if (char == 9) {
        // tab
        count += 2; // treat tab as 2 spaces
      } else {
        break;
      }
    }
    return count;
  }

  int _findUnquotedColon(String str) {
    var inQuotes = false;
    var escaped = false;

    for (var i = 0; i < str.length; i++) {
      final char = str[i];

      if (escaped) {
        escaped = false;
        continue;
      }

      if (char == '\\') {
        escaped = true;
        continue;
      }

      if (char == '"') {
        inQuotes = !inQuotes;
        continue;
      }

      if (char == ':' && !inQuotes) {
        return i;
      }
    }

    return -1;
  }
}

class _ParseResult {
  final dynamic value;
  final int nextIndex;

  _ParseResult(this.value, this.nextIndex);
}
