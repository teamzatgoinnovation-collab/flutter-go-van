import 'package:zatgo_dart_sdk/zatgo_dart_sdk.dart';

import '../models/models.dart';
import '../services/session.dart';

/// ERPNext-backed Go Van store via `zatgo_core.api.v1.go_van` (no seed data).
class MockRepo {
  List<RouteStop> _stops = [];
  List<VanOrder> _orders = [];
  List<Collection> _collections = [];
  List<StockLine> _stock = [];

  String routeName = 'Go Van route';
  String driverName = 'Driver';

  Future<void> refreshFromErpnext(GoVanSession session) async {
    if (!session.connected) {
      _stops = [];
      _orders = [];
      _collections = [];
      _stock = [];
      return;
    }
    await session.store.callMethod(ZatGoApiMethods.goVanPing);
    final env = await session.store.callMethod(
      ZatGoApiMethods.goVanTripsList,
      args: {'page': 1, 'page_size': 100},
    );
    final rows = env.data is List ? env.data as List : const [];
    _stops = [
      for (var i = 0; i < rows.length; i++)
        RouteStop(
          id: '${(rows[i] as Map)['name'] ?? (rows[i] as Map)['id'] ?? 'trip-$i'}',
          customerName:
              '${(rows[i] as Map)['customer'] ?? (rows[i] as Map)['title'] ?? 'Stop ${i + 1}'}',
          address: '${(rows[i] as Map)['address'] ?? ''}',
          sequence: i + 1,
          lat: double.tryParse('${(rows[i] as Map)['lat'] ?? ''}') ?? 0,
          lng: double.tryParse('${(rows[i] as Map)['lng'] ?? ''}') ?? 0,
          plannedAt: DateTime.now(),
        ),
    ];
    _orders = [];
    _collections = [];
    _stock = [];
  }

  List<RouteStop> listStops() => List.unmodifiable(_stops);

  List<VanOrder> listOrders({String query = ''}) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return List.unmodifiable(_orders);
    return _orders
        .where(
          (o) =>
              o.customerName.toLowerCase().contains(q) ||
              o.id.toLowerCase().contains(q),
        )
        .toList(growable: false);
  }

  List<Collection> listCollections() => List.unmodifiable(_collections);

  List<StockLine> listStock() => List.unmodifiable(_stock);

  DaySummary summary() {
    final done = _stops
        .where((s) => s.visitStatus == VisitStatus.completed)
        .length;
    final queued = _orders
        .where((o) => o.syncStatus != OrderSyncStatus.synced)
        .length;
    final collected = _collections.fold<double>(0, (s, c) => s + c.amount);
    return DaySummary(
      stopsTotal: _stops.length,
      stopsDone: done,
      ordersQueued: queued,
      collectionsToday: collected,
      vanStockSku: _stock.length,
    );
  }

  VanOrder createOrder({
    required String customerName,
    required String itemsLabel,
    required double amount,
  }) {
    throw StateError(
      'Create order requires ERPNext DocTypes (zatgo_core stub only).',
    );
  }

  Collection recordCollection({
    required String customerName,
    required double amount,
    required String method,
  }) {
    throw StateError(
      'Collections require ERPNext DocTypes (zatgo_core stub only).',
    );
  }

  RouteStop? updateVisit(String id, VisitStatus status) {
    final i = _stops.indexWhere((s) => s.id == id);
    if (i < 0) return null;
    final updated = _stops[i].copyWith(visitStatus: status);
    _stops = [..._stops]..[i] = updated;
    return updated;
  }

  void transferStock({required String itemCode, required double qty}) {
    throw StateError(
      'Stock transfer requires ERPNext DocTypes (zatgo_core stub only).',
    );
  }

  int flushOfflineQueue() => 0;
}

final mockRepo = MockRepo();
