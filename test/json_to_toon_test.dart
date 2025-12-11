import 'package:flutter_test/flutter_test.dart';
import 'package:json_to_toon/json_to_toon.dart';
import 'dart:convert';

void main() {
  group('ToonEncoder Tests', () {
    late ToonEncoder encoder;

    setUp(() {
      encoder = ToonEncoder();
    });

    test('encodes simple object', () {
      final json = {'name': 'Alice', 'age': 30};
      final toon = encoder.encode(json);
      expect(toon, contains('name: Alice'));
      expect(toon, contains('age: 30'));
    });

    test('encodes nested object', () {
      final json = {
        'user': {'name': 'Bob', 'email': 'bob@example.com'}
      };
      final toon = encoder.encode(json);
      expect(toon, contains('user:'));
      expect(toon, contains('name: Bob'));
      expect(toon, contains('email: bob@example.com'));
    });

    test('encodes primitive array', () {
      final json = {
        'colors': ['red', 'green', 'blue']
      };
      final toon = encoder.encode(json);
      expect(toon, contains('colors[3]:'));
      expect(toon, contains('red,green,blue'));
    });

    test('encodes array of objects (tabular)', () {
      final json = {
        'users': [
          {'id': 1, 'name': 'Alice'},
          {'id': 2, 'name': 'Bob'}
        ]
      };
      final toon = encoder.encode(json);
      expect(toon, contains('users[2]{id,name}:'));
      expect(toon, contains('1,Alice'));
      expect(toon, contains('2,Bob'));
    });

    test('encodes null values', () {
      final json = {'value': null};
      final toon = encoder.encode(json);
      expect(toon, contains('value: null'));
    });

    test('encodes boolean values', () {
      final json = {'active': true, 'deleted': false};
      final toon = encoder.encode(json);
      expect(toon, contains('active: true'));
      expect(toon, contains('deleted: false'));
    });

    test('encodes numbers', () {
      final json = {'count': 42, 'price': 19.99};
      final toon = encoder.encode(json);
      expect(toon, contains('count: 42'));
      expect(toon, contains('price: 19.99'));
    });

    test('quotes strings with special characters', () {
      final json = {'message': 'Hello, World!'};
      final toon = encoder.encode(json);
      expect(toon, contains('"Hello, World!"'));
    });

    test('encodes complex nested structure', () {
      final json = {
        'context': {'task': 'Our favorite hikes', 'location': 'Boulder'},
        'friends': ['ana', 'luis', 'sam'],
        'hikes': [
          {'id': 1, 'name': 'Blue Lake Trail', 'distance': 7.5},
          {'id': 2, 'name': 'Ridge Overlook', 'distance': 9.2}
        ]
      };
      final toon = encoder.encode(json);
      expect(toon, contains('context:'));
      expect(toon, contains('friends[3]:'));
      expect(toon, contains('hikes[2]{id,name,distance}:'));
    });

    test('encodes from JSON string', () {
      final jsonString = '{"name":"Alice","age":30}';
      final toon = encoder.encodeFromJson(jsonString);
      expect(toon, contains('name: Alice'));
      expect(toon, contains('age: 30'));
    });
  });

  group('ToonDecoder Tests', () {
    late ToonDecoder decoder;

    setUp(() {
      decoder = ToonDecoder();
    });

    test('decodes simple object', () {
      final toon = 'name: Alice\nage: 30';
      final result = decoder.decode(toon);
      expect(result, isA<Map>());
      expect(result['name'], 'Alice');
      expect(result['age'], 30);
    });

    test('decodes nested object', () {
      final toon = 'user:\n  name: Bob\n  email: bob@example.com';
      final result = decoder.decode(toon);
      expect(result['user'], isA<Map>());
      expect(result['user']['name'], 'Bob');
      expect(result['user']['email'], 'bob@example.com');
    });

    test('decodes primitive array', () {
      final toon = 'colors[3]: red,green,blue';
      final result = decoder.decode(toon);
      expect(result['colors'], isA<List>());
      expect(result['colors'], ['red', 'green', 'blue']);
    });

    test('decodes tabular array', () {
      final toon = 'users[2]{id,name}:\n  1,Alice\n  2,Bob';
      final result = decoder.decode(toon);
      expect(result['users'], isA<List>());
      expect(result['users'].length, 2);
      expect(result['users'][0]['id'], 1);
      expect(result['users'][0]['name'], 'Alice');
      expect(result['users'][1]['id'], 2);
      expect(result['users'][1]['name'], 'Bob');
    });

    test('decodes null values', () {
      final toon = 'value: null';
      final result = decoder.decode(toon);
      expect(result['value'], isNull);
    });

    test('decodes boolean values', () {
      final toon = 'active: true\ndeleted: false';
      final result = decoder.decode(toon);
      expect(result['active'], true);
      expect(result['deleted'], false);
    });

    test('decodes numbers', () {
      final toon = 'count: 42\nprice: 19.99';
      final result = decoder.decode(toon);
      expect(result['count'], 42);
      expect(result['price'], 19.99);
    });

    test('decodes quoted strings', () {
      final toon = 'message: "Hello, World!"';
      final result = decoder.decode(toon);
      expect(result['message'], 'Hello, World!');
    });

    test('decodes to JSON string', () {
      final toon = 'name: Alice\nage: 30';
      final jsonString = decoder.decodeToJson(toon);
      final json = jsonDecode(jsonString);
      expect(json['name'], 'Alice');
      expect(json['age'], 30);
    });
  });

  group('ToonConverter Tests', () {
    late ToonConverter converter;

    setUp(() {
      converter = ToonConverter();
    });

    test('round-trip conversion (object)', () {
      final original = {'name': 'Alice', 'age': 30, 'active': true};
      final toon = converter.toToon(original);
      final decoded = converter.fromToon(toon);
      expect(decoded['name'], original['name']);
      expect(decoded['age'], original['age']);
      expect(decoded['active'], original['active']);
    });

    test('round-trip conversion (array)', () {
      final original = {
        'users': [
          {'id': 1, 'name': 'Alice'},
          {'id': 2, 'name': 'Bob'}
        ]
      };
      final toon = converter.toToon(original);
      final decoded = converter.fromToon(toon);
      expect(decoded['users'].length, 2);
      expect(decoded['users'][0]['name'], 'Alice');
      expect(decoded['users'][1]['name'], 'Bob');
    });

    test('JSON to TOON to JSON', () {
      final jsonString = '{"name":"Alice","age":30}';
      final toon = converter.jsonToToon(jsonString);
      final resultJson = converter.toonToJson(toon);
      final result = jsonDecode(resultJson);
      expect(result['name'], 'Alice');
      expect(result['age'], 30);
    });
  });
}
