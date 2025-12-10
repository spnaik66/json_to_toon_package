/// A library for converting between JSON and TOON (Token-Oriented Object Notation) formats.
///
/// TOON is a compact, human-readable encoding of the JSON data model optimized for
/// LLM prompts. It provides lossless serialization while minimizing tokens.
library json_to_toon;

export 'src/toon_encoder.dart';
export 'src/toon_decoder.dart';
export 'src/toon_converter.dart';
