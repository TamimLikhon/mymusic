import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mymusic/services/stream/stream_bridge_message.dart';

String message({
  required int generation,
  required int sequence,
  int version = StreamBridgeMessage.protocolVersion,
  String type = 'playbackState',
  Map<String, dynamic> payload = const {'state': 'playing'},
}) =>
    jsonEncode({
      'version': version,
      'documentGeneration': generation,
      'sequenceNumber': sequence,
      'type': type,
      'payload': payload,
    });

void main() {
  group('StreamBridgeMessageGate', () {
    test('accepts only increasing messages from its current document', () {
      final gate = StreamBridgeMessageGate()..beginDocument(4);
      final first = StreamBridgeMessage.tryParse(
        message(generation: 4, sequence: 1),
      )!;
      final replay = StreamBridgeMessage.tryParse(
        message(generation: 4, sequence: 1),
      )!;
      final staleDocument = StreamBridgeMessage.tryParse(
        message(generation: 3, sequence: 2),
      )!;
      final next = StreamBridgeMessage.tryParse(
        message(generation: 4, sequence: 2),
      )!;

      expect(gate.accepts(first), isTrue);
      expect(gate.accepts(replay), isFalse);
      expect(gate.accepts(staleDocument), isFalse);
      expect(gate.accepts(next), isTrue);
    });

    test('rejects malformed and unsupported protocol messages', () {
      expect(StreamBridgeMessage.tryParse('{not json}'), isNull);
      expect(
        StreamBridgeMessage.tryParse(
          message(generation: 1, sequence: 1, version: 999),
        ),
        isNotNull,
      );

      final gate = StreamBridgeMessageGate()..beginDocument(1);
      expect(
        gate.accepts(
          StreamBridgeMessage.tryParse(
            message(generation: 1, sequence: 1, version: 999),
          )!,
        ),
        isFalse,
      );
    });
  });
}
