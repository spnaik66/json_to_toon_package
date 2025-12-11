import 'package:json_to_toon/json_to_toon.dart';

void main() {
  // Create a converter instance
  final converter = ToonConverter();

  print('=== JSON to TOON Conversion Examples ===\n');

  // Example 1: Simple object
  print('Example 1: Simple Object');
  final simpleData = {
    'name': 'Alice',
    'age': 30,
    'active': true,
  };
  final simpleToon = converter.toToon(simpleData);
  print('TOON Output:');
  print(simpleToon);
  print('\n---\n');

  // Example 2: Nested object
  print('Example 2: Nested Object');
  final nestedData = {
    'user': {
      'name': 'Bob',
      'email': 'bob@example.com',
      'settings': {'theme': 'dark', 'notifications': true}
    }
  };
  final nestedToon = converter.toToon(nestedData);
  print('TOON Output:');
  print(nestedToon);
  print('\n---\n');

  // Example 3: Arrays
  print('Example 3: Arrays');
  final arrayData = {
    'colors': ['red', 'green', 'blue'],
    'users': [
      {'id': 1, 'name': 'Alice', 'role': 'admin'},
      {'id': 2, 'name': 'Bob', 'role': 'user'},
      {'id': 3, 'name': 'Charlie', 'role': 'user'}
    ]
  };
  final arrayToon = converter.toToon(arrayData);
  print('TOON Output:');
  print(arrayToon);
  print('\n---\n');

  // Example 4: Complex nested structure
  print('Example 4: Complex Structure (Hiking Data)');
  final complexData = {
    'context': {
      'task': 'Our favorite hikes together',
      'location': 'Boulder',
      'season': 'spring_2025'
    },
    'friends': ['ana', 'luis', 'sam'],
    'hikes': [
      {
        'id': 1,
        'name': 'Blue Lake Trail',
        'distanceKm': 7.5,
        'elevationGain': 320,
        'companion': 'ana',
        'wasSunny': true
      },
      {
        'id': 2,
        'name': 'Ridge Overlook',
        'distanceKm': 9.2,
        'elevationGain': 540,
        'companion': 'luis',
        'wasSunny': false
      },
      {
        'id': 3,
        'name': 'Wildflower Loop',
        'distanceKm': 5.1,
        'elevationGain': 180,
        'companion': 'sam',
        'wasSunny': true
      }
    ]
  };
  final complexToon = converter.toToon(complexData);
  print('TOON Output:');
  print(complexToon);
  print('\n---\n');

  // Example 5: Round-trip conversion
  print('Example 5: Round-trip Conversion (TOON → JSON → TOON)');
  final originalToon = 'name: Alice\nage: 30\nactive: true';
  print('Original TOON:');
  print(originalToon);

  final decoded = converter.fromToon(originalToon);
  print('\nDecoded to Dart object:');
  print(decoded);

  final reencoded = converter.toToon(decoded);
  print('\nRe-encoded to TOON:');
  print(reencoded);

  print('\nRound-trip successful: ${originalToon == reencoded}');
  print('\n---\n');

  // Example 6: Token count comparison
  print('Example 6: Token Count Comparison');
  final jsonString = converter.toonToJson(complexToon);
  print('JSON length: ${jsonString.length} characters');
  print('TOON length: ${complexToon.length} characters');
  final reduction =
      ((jsonString.length - complexToon.length) / jsonString.length * 100)
          .toStringAsFixed(1);
  print('Reduction: $reduction%');
}
