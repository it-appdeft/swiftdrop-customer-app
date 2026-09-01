import 'dart:async';
import 'dart:convert';
import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:get/get.dart';
import '../config/app_config.dart';
import '../network/api_endpoints.dart';
import '../utils/app_logger.dart';
import 'connectivity_service.dart';
import 'storage_service.dart';

class RealtimeService extends GetxService {
  static RealtimeService get to => Get.find();

  PusherChannelsClient? _client;
  StreamSubscription? _connectivitySub;
  StreamSubscription? _connectionSub;

  final RxString connectionState = 'disconnected'.obs;
  final Set<String> _subscribedChannels = {};
  final Map<String, Channel> _channelInstances = {};

  bool _intentionalDisconnect = false;
  bool _initialized = false;

  final Map<String, void Function(Map<String, dynamic>)> _eventHandlers = {};
  final Map<String, StreamSubscription> _eventSubscriptions = {};

  @override
  void onInit() {
    super.onInit();
    _listenToConnectivity();
  }

  @override
  void onClose() {
    disconnect();
    _connectivitySub?.cancel();
    super.onClose();
  }

  // ─── Connect to Reverb ──────────────────────────────────────────────────────

  Future<void> connect() async {
    if (_initialized) return;

    final appKey = AppConfig.reverbAppKey;
    final host = AppConfig.reverbHost;
    final port = AppConfig.reverbPort;
    final scheme = AppConfig.reverbScheme;

    if (appKey.isEmpty || host.isEmpty) {
      AppLogger.w('⚠️ [Reverb] Config missing (key: "$appKey", host: "$host") — skipping WebSocket connection');
      return;
    }

    _intentionalDisconnect = false;

    try {
      final wsScheme = (scheme.toLowerCase() == 'https' || scheme.toLowerCase() == 'wss')
          ? 'wss'
          : 'ws';

      final options = PusherChannelsOptions.fromHost(
        scheme: wsScheme,
        host: host,
        port: port,
        key: appKey,
        shouldSupplyMetadataQueries: true,
        metadata: PusherChannelsOptionsMetadata.byDefault(),
      );

      AppLogger.i('⚡ [Reverb] WebSocket URL: ${options.uri}');

      _client = PusherChannelsClient.websocket(
        options: options,
        connectionErrorHandler: (exception, trace, refresh) {
          AppLogger.e('❌ [Reverb Error] Connection error: $exception');
          connectionState.value = 'error';
          // Auto-retry after 5 seconds
          Future.delayed(const Duration(seconds: 5), () {
            if (!_intentionalDisconnect) {
              AppLogger.i('🔄 [Reverb] Auto-retrying connection...');
              refresh();
            }
          });
        },
        minimumReconnectDelayDuration: const Duration(seconds: 2),
        defaultActivityDuration: const Duration(seconds: 120),
        waitForPongDuration: const Duration(seconds: 30),
      );

      // Listen to connection established events
      _connectionSub?.cancel();
      _connectionSub = _client!.onConnectionEstablished.listen((_) {
        connectionState.value = 'connected';
        AppLogger.i('🟢 [Reverb Connection] CONNECTED to $wsScheme://$host:$port');
        // Re-subscribe pending channels
        _resubscribeExistingChannels();
      });

      connectionState.value = 'connecting';
      AppLogger.i('⚡ [Reverb Connection] State changed: DISCONNECTED ➔ CONNECTING');

      _client!.connect();
      _initialized = true;
      AppLogger.i('🚀 Connecting to Reverb at $wsScheme://$host:$port');
    } catch (e) {
      AppLogger.e('❌ [Reverb Error] Failed to connect: $e');
      connectionState.value = 'error';
    }
  }

  // ─── Disconnect ─────────────────────────────────────────────────────────────

  Future<void> disconnect() async {
    _intentionalDisconnect = true;
    _eventHandlers.clear();

    try {
      // Cancel all event subscriptions
      for (final sub in _eventSubscriptions.values) {
        sub.cancel();
      }
      _eventSubscriptions.clear();

      // Unsubscribe from all channels
      for (final channel in _channelInstances.values) {
        try {
          channel.unsubscribe();
        } catch (_) {}
      }
      _channelInstances.clear();
      _subscribedChannels.clear();

      _connectionSub?.cancel();
      _connectionSub = null;

      _client?.dispose();
      _client = null;
    } catch (e) {
      AppLogger.e('Error disconnecting from Reverb: $e');
    }

    _initialized = false;
    connectionState.value = 'disconnected';
    AppLogger.i('🔌 [Reverb Connection] Disconnected from Reverb');
  }

  // ─── Channel Subscription ──────────────────────────────────────────────────

  Future<void> subscribeToChannel(String channelName) async {
    // Store channel name for subscription (even if not yet connected)
    _subscribedChannels.add(channelName);

    if (_client == null || !_initialized) {
      AppLogger.w('⏳ [Reverb] Queued subscription for $channelName (not connected yet)');
      return;
    }

    if (_channelInstances.containsKey(channelName)) {
      AppLogger.d('Already subscribed to $channelName');
      return;
    }

    try {
      Channel channel;

      if (channelName.startsWith('private-')) {
        final token = StorageService.to.authToken ?? '';
        final authUrl = '${AppConfig.baseUrl}${ApiEndpoints.broadcastingAuth}';

        AppLogger.i('🔑 [Broadcasting Auth] Setting up auth for channel: $channelName');
        AppLogger.d('📍 [Broadcasting Auth] Auth endpoint: $authUrl');

        channel = _client!.privateChannel(
          channelName,
          authorizationDelegate:
              EndpointAuthorizableChannelTokenAuthorizationDelegate
                  .forPrivateChannel(
            authorizationEndpoint: Uri.parse(authUrl),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          ),
        );
      } else {
        channel = _client!.publicChannel(channelName);
      }

      _channelInstances[channelName] = channel;

      // Listen for subscription success
      channel.whenSubscriptionSucceeded().listen((_) {
        AppLogger.i('🟢 [Channel Subscribed] Successfully subscribed to: $channelName');
      });

      // Listen for auth errors on private channels
      if (channelName.startsWith('private-')) {
        channel.onSubscriptionError().listen((event) {
          AppLogger.e('❌ [Subscription Error] Auth failed for $channelName: ${event.data}');
        });
      }

      channel.subscribe();
      AppLogger.i('📡 Subscribing to $channelName');

      // Bind any previously registered handlers for this channel
      _bindPendingHandlers(channelName, channel);
    } catch (e) {
      AppLogger.e('❌ [Subscription Error] Failed to subscribe to $channelName: $e');
    }
  }

  // ─── Re-subscribe after reconnection ───────────────────────────────────────

  void _resubscribeExistingChannels() {
    final pendingChannels = Set<String>.from(_subscribedChannels);
    for (final channelName in pendingChannels) {
      if (!_channelInstances.containsKey(channelName)) {
        subscribeToChannel(channelName);
      } else {
        // Force re-subscribe existing channels
        _channelInstances[channelName]!.subscribeIfNotUnsubscribed();
      }
    }
  }

  // ─── Customer Specific Subscriptions ──────────────────────────────────────

  Future<void> subscribeUser(dynamic userId) async {
    if (userId == null || userId.toString().isEmpty) return;
    await subscribeToChannel('private-customer.$userId');
    await subscribeToChannel('customer.$userId');
  }

  Future<void> unsubscribeUser(dynamic userId) async {
    if (userId == null || userId.toString().isEmpty) return;
    await unsubscribeFromChannel('private-customer.$userId');
    await unsubscribeFromChannel('customer.$userId');
  }

  Future<void> subscribeOrder(dynamic orderId) async {
    if (orderId == null || orderId.toString().isEmpty) return;
    await subscribeToChannel('private-order.$orderId');
    await subscribeToChannel('order.$orderId');
  }

  Future<void> unsubscribeOrder(dynamic orderId) async {
    if (orderId == null || orderId.toString().isEmpty) return;
    await unsubscribeFromChannel('private-order.$orderId');
    await unsubscribeFromChannel('order.$orderId');
  }

  Future<void> subscribeToPrivateChannel(String channelName) async =>
      subscribeToChannel(channelName);

  // ─── Unsubscribe ───────────────────────────────────────────────────────────

  Future<void> unsubscribeFromChannel(String channelName) async {
    try {
      _channelInstances[channelName]?.unsubscribe();
      _channelInstances.remove(channelName);
      _subscribedChannels.remove(channelName);
      _removeHandlersForChannel(channelName);
      AppLogger.i('Unsubscribed from $channelName');
    } catch (e) {
      AppLogger.e('Failed to unsubscribe from $channelName: $e');
    }
  }

  Future<void> unsubscribeAll() async {
    for (final channel in _subscribedChannels.toList()) {
      await unsubscribeFromChannel(channel);
    }
  }

  void _removeHandlersForChannel(String channelName) {
    final cleanChannel = channelName.startsWith('private-')
        ? channelName.substring('private-'.length)
        : channelName;

    _eventHandlers.removeWhere((key, _) => key.startsWith('$cleanChannel::'));
  }

  // ─── Event Listening ───────────────────────────────────────────────────────

  void onEvent(
    String channelName,
    String eventName,
    void Function(Map<String, dynamic> data) handler,
  ) {
    final cleanChannel = channelName.startsWith('private-')
        ? channelName.substring('private-'.length)
        : channelName;
    final cleanEvent = eventName.startsWith('.') ? eventName.substring(1) : eventName;

    final key = '$cleanChannel::$cleanEvent';
    _eventHandlers[key] = handler;

    AppLogger.d('Registered handler for $eventName on $key');
  }

  void removeEventHandler(String channelName, String eventName) {
    final cleanChannel = channelName.startsWith('private-')
        ? channelName.substring('private-'.length)
        : channelName;
    final cleanEvent = eventName.startsWith('.') ? eventName.substring(1) : eventName;

    _eventHandlers.remove('$cleanChannel::$cleanEvent');
  }

  // ─── Event Binding (Internal) ──────────────────────────────────────────────

  void _bindPendingHandlers(String channelName, Channel channel) {
    _eventSubscriptions[channelName]?.cancel();

    // Listen for all events on this channel to ensure no events are missed
    _eventSubscriptions[channelName] = channel.bindToAll().listen((event) {
      final rawEventName = event.name;
      if (rawEventName.isEmpty || rawEventName.startsWith('pusher:')) return;

      print('\n====================================================');
      print('⚡ [REVERB EVENT RECEIVED]');
      print('📡 Channel: $channelName');
      print('🏷️ Event Name: $rawEventName');
      print('📦 Raw Payload: ${event.data}');
      print('====================================================\n');

      AppLogger.i('📥 [Realtime Event] Received: "$rawEventName" on channel "$channelName"');
      AppLogger.d('📦 [Realtime Event Data] ${event.data}');

      Map<String, dynamic> data = {};
      if (event.data != null) {
        try {
          final decoded = jsonDecode(event.data!);
          if (decoded is Map<String, dynamic>) {
            data = decoded;
          } else if (decoded is Map) {
            data = Map<String, dynamic>.from(decoded);
          } else {
            data = {'raw': event.data};
          }
        } catch (_) {
          data = {'raw': event.data};
        }
      }

      final normalizedIncoming = rawEventName.startsWith('.')
          ? rawEventName.substring(1)
          : rawEventName;

      final normalizedIncomingChannel = channelName.startsWith('private-')
          ? channelName.substring('private-'.length)
          : channelName;

      bool matchedAny = false;
      for (final entry in _eventHandlers.entries) {
        final entryParts = entry.key.split('::');
        if (entryParts.length < 2) continue;
        final entryChannel = entryParts.first;
        final registeredEvent = entry.key.substring('$entryChannel::'.length);

        // Exact match on normalized channel
        if (entryChannel != normalizedIncomingChannel) {
          continue;
        }

        final normalizedRegistered = registeredEvent.startsWith('.')
            ? registeredEvent.substring(1)
            : registeredEvent;

        if (registeredEvent == rawEventName ||
            normalizedRegistered == normalizedIncoming ||
            rawEventName.endsWith(normalizedRegistered) ||
            normalizedIncoming.endsWith(normalizedRegistered)) {
          matchedAny = true;
          AppLogger.i('🎯 [Dispatching Handler] For event "$registeredEvent" on "$channelName"');
          try {
            entry.value(data);
          } catch (err, st) {
            AppLogger.e('Error executing handler for $registeredEvent', err, st);
          }
        }
      }

      if (!matchedAny) {
        AppLogger.w('⚠️ [No Handler Matched] for event "$rawEventName" on channel "$channelName". All Registered: ${_eventHandlers.keys.toList()}');
      }
    });
  }

  // ─── Reconnection via Connectivity ─────────────────────────────────────────

  void _listenToConnectivity() {
    _connectivitySub = ConnectivityService.to.isConnected.listen((connected) {
      if (_intentionalDisconnect) return;

      if (connected && connectionState.value != 'connected' && _subscribedChannels.isNotEmpty) {
        _reconnect();
      }
    });
  }

  Future<void> _reconnect() async {
    AppLogger.i('🔄 [Reverb] Reconnecting...');
    connectionState.value = 'reconnecting';

    final previousChannels = Set<String>.from(_subscribedChannels);
    final previousHandlers = Map<String, void Function(Map<String, dynamic>)>.from(_eventHandlers);

    await disconnect();
    _intentionalDisconnect = false;

    // Restore handlers and channels before connecting
    _eventHandlers.addAll(previousHandlers);
    _subscribedChannels.addAll(previousChannels);

    await connect();

    AppLogger.i('🔄 [Reverb] Reconnected — re-subscribing to ${previousChannels.length} channels');
  }

  // ─── State Helpers ─────────────────────────────────────────────────────────

  bool get isConnected => connectionState.value == 'connected';
  bool get isReconnecting => connectionState.value == 'reconnecting';
  List<String> get subscribedChannels => _subscribedChannels.toList();
}