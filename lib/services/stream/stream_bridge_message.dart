import 'dart:convert';

/// The versioned, origin-validated message contract used by the YouTube Music
/// page adapter. Keeping this type platform-free makes the bridge testable
/// without starting a WebView.
class StreamBridgeMessage {
  static const int protocolVersion = 1;

  final int version;
  final int documentGeneration;
  final int sequenceNumber;
  final String type;
  final Map<String, dynamic> payload;

  const StreamBridgeMessage({
    required this.version,
    required this.documentGeneration,
    required this.sequenceNumber,
    required this.type,
    required this.payload,
  });

  static StreamBridgeMessage? tryParse(String raw) {
    if (raw.length > 32 * 1024) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;

      final version = decoded['version'];
      final documentGeneration = decoded['documentGeneration'];
      final sequenceNumber = decoded['sequenceNumber'];
      final type = decoded['type'];
      final payload = decoded['payload'];

      if (version is! int ||
          documentGeneration is! int ||
          sequenceNumber is! int ||
          type is! String ||
          payload is! Map ||
          documentGeneration < 1 ||
          sequenceNumber < 1 ||
          type.isEmpty) {
        return null;
      }

      return StreamBridgeMessage(
        version: version,
        documentGeneration: documentGeneration,
        sequenceNumber: sequenceNumber,
        type: type,
        payload: Map<String, dynamic>.from(payload),
      );
    } on FormatException {
      return null;
    }
  }
}

/// Rejects messages that do not belong to the current document or are replayed
/// out of order. Origin and main-frame checks are performed by the WebView
/// controller before a message reaches this gate.
class StreamBridgeMessageGate {
  int _documentGeneration = 0;
  int _lastSequenceNumber = 0;

  int get documentGeneration => _documentGeneration;
  int get lastSequenceNumber => _lastSequenceNumber;

  void beginDocument(int generation) {
    _documentGeneration = generation;
    _lastSequenceNumber = 0;
  }

  bool accepts(StreamBridgeMessage message) {
    if (message.version != StreamBridgeMessage.protocolVersion ||
        message.documentGeneration != _documentGeneration ||
        message.sequenceNumber <= _lastSequenceNumber) {
      return false;
    }

    _lastSequenceNumber = message.sequenceNumber;
    return true;
  }
}
