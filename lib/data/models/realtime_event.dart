import 'dart:convert' show jsonDecode;

class RealtimeEvent {
  final String eventName;
  final String channelName;
  final Map<String, dynamic> data;

  RealtimeEvent({
    required this.eventName,
    required this.channelName,
    required this.data,
  });

  factory RealtimeEvent.fromRaw({
    required String eventName,
    required String channelName,
    required String? rawData,
  }) {
    Map<String, dynamic> parsed = {};
    if (rawData != null && rawData.isNotEmpty) {
      try {
        parsed = jsonDecode(rawData) as Map<String, dynamic>;
      } catch (_) {
        parsed = {'raw': rawData};
      }
    }
    return RealtimeEvent(
      eventName: eventName,
      channelName: channelName,
      data: parsed,
    );
  }

  @override
  String toString() => 'RealtimeEvent(event: $eventName, channel: $channelName, data: $data)';
}
