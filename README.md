# JSON to TOON Package

A Flutter/Dart package for converting between **JSON** and **TOON (Token-Oriented Object Notation)** formats.

## What is TOON?

TOON (Token-Oriented Object Notation) is a compact, human-readable encoding of the JSON data model specifically designed for LLM prompts. It provides:

- **30-60% fewer tokens** compared to JSON
- **Lossless conversion** - maintains all data integrity
- **Human-readable** format using YAML-like indentation
- **Tabular arrays** for uniform object arrays (CSV-style)
- **Minimal punctuation** to reduce token count

## Features

✅ Convert JSON to TOON format  
✅ Convert TOON to JSON format  
✅ Support for all JSON data types (objects, arrays, primitives)  
✅ Tabular format for uniform arrays  
✅ Proper string escaping and quoting  
✅ Comprehensive test coverage  

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  json_to_toon: ^1.0.0
```

Or install from local path:

```yaml
dependencies:
  json_to_toon:
    path: ../json_to_toon_package
```

Then run:

```bash
flutter pub get
```

## Usage

### Basic Usage

```dart
import 'package:json_to_toon/json_to_toon.dart';

void main() {
  final converter = ToonConverter();
  
  // JSON to TOON
  final jsonData = {
    'name': 'Alice',
    'age': 30,
    'active': true
  };
  
  final toon = converter.toToon(jsonData);
  print(toon);
  // Output:
  // name: Alice
  // age: 30
  // active: true
  
  // TOON to JSON
  final decoded = converter.fromToon(toon);
  print(decoded); // {name: Alice, age: 30, active: true}
}
```

### Converting from JSON String

```dart
final converter = ToonConverter();

// JSON string to TOON
final jsonString = '{"name":"Bob","age":25}';
final toon = converter.jsonToToon(jsonString);

// TOON to JSON string
final json = converter.toonToJson(toon);
```

### Working with Arrays

```dart
final data = {
  'colors': ['red', 'green', 'blue'],
  'users': [
    {'id': 1, 'name': 'Alice'},
    {'id': 2, 'name': 'Bob'}
  ]
};

final toon = converter.toToon(data);
print(toon);
// Output:
// colors[3]: red,green,blue
// users[2]{id,name}:
//   1,Alice
//   2,Bob
```

### Using Individual Encoder/Decoder

```dart
import 'package:json_to_toon/json_to_toon.dart';

// Using encoder only
final encoder = ToonEncoder();
final toon = encoder.encode({'key': 'value'});

// Using decoder only
final decoder = ToonDecoder();
final data = decoder.decode('key: value');
```

## TOON Format Examples

### Simple Object

**JSON:**
```json
{
  "name": "Alice",
  "age": 30,
  "active": true
}
```

**TOON:**
```
name: Alice
age: 30
active: true
```

### Nested Object

**JSON:**
```json
{
  "user": {
    "name": "Bob",
    "email": "bob@example.com"
  }
}
```

**TOON:**
```
user:
  name: Bob
  email: bob@example.com
```

### Array of Objects (Tabular)

**JSON:**
```json
{
  "hikes": [
    {"id": 1, "name": "Blue Lake Trail", "distance": 7.5},
    {"id": 2, "name": "Ridge Overlook", "distance": 9.2}
  ]
}
```

**TOON:**
```
hikes[2]{id,name,distance}:
  1,Blue Lake Trail,7.5
  2,Ridge Overlook,9.2
```

### Complex Example

**JSON:**
```json
{
  "context": {
    "task": "Our favorite hikes",
    "location": "Boulder"
  },
  "friends": ["ana", "luis", "sam"],
  "hikes": [
    {"id": 1, "name": "Blue Lake Trail", "distanceKm": 7.5},
    {"id": 2, "name": "Ridge Overlook", "distanceKm": 9.2}
  ]
}
```

**TOON:**
```
context:
  task: Our favorite hikes
  location: Boulder
friends[3]: ana,luis,sam
hikes[2]{id,name,distanceKm}:
  1,Blue Lake Trail,7.5
  2,Ridge Overlook,9.2
```

## API Reference

### ToonConverter

Main class that combines encoding and decoding functionality.

**Methods:**
- `String toToon(dynamic data)` - Convert Dart object to TOON
- `String jsonToToon(String jsonString)` - Convert JSON string to TOON
- `dynamic fromToon(String toonString)` - Convert TOON to Dart object
- `String toonToJson(String toonString)` - Convert TOON to JSON string

### ToonEncoder

Encodes JSON/Dart objects to TOON format.

**Constructor:**
- `ToonEncoder({String indent = '  '})` - Create encoder with custom indentation

**Methods:**
- `String encode(dynamic json)` - Encode data to TOON
- `String encodeFromJson(String jsonString)` - Encode JSON string to TOON

### ToonDecoder

Decodes TOON format to JSON/Dart objects.

**Methods:**
- `dynamic decode(String toon)` - Decode TOON to Dart object
- `String decodeToJson(String toon)` - Decode TOON to JSON string

## Running Tests

```bash
cd json_to_toon_package
flutter test
```

## Running the Example App

```bash
cd json_to_toon_package/example
flutter run
```

The example app provides an interactive UI to convert between JSON and TOON formats.

## Benefits of TOON

1. **Token Efficiency**: Reduces token count by 30-60% compared to JSON
2. **Cost Savings**: Lower API costs when working with LLMs
3. **Better Context**: More data fits in LLM context windows
4. **Human Readable**: Easy to read and understand
5. **Lossless**: Perfect round-trip conversion with JSON

## Use Cases

- Optimizing prompts for Large Language Models (LLMs)
- Reducing API costs for AI services
- Efficient data serialization for token-limited contexts
- Human-readable configuration files
- Data interchange in AI applications

## Specification

This package implements the official TOON specification v2.0. For more details, see:
- [TOON Specification](https://github.com/toon-format/spec)
- [TOON Format Repository](https://github.com/toon-format/toon)

## License

MIT License

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## Author

Created for efficient JSON-TOON conversion in Flutter/Dart applications.
