enum OrderSyncStatus { synced, queued, failed }

enum VisitStatus { planned, checkedIn, completed, skipped }

class RouteStop {
  const RouteStop({
    required this.id,
    required this.customerName,
    required this.address,
    required this.sequence,
    required this.lat,
    required this.lng,
    this.plannedAt,
    this.visitStatus = VisitStatus.planned,
  });

  final String id;
  final String customerName;
  final String address;
  final int sequence;
  final double lat;
  final double lng;
  final DateTime? plannedAt;
  final VisitStatus visitStatus;

  RouteStop copyWith({VisitStatus? visitStatus}) {
    return RouteStop(
      id: id,
      customerName: customerName,
      address: address,
      sequence: sequence,
      lat: lat,
      lng: lng,
      plannedAt: plannedAt,
      visitStatus: visitStatus ?? this.visitStatus,
    );
  }
}

class VanOrder {
  const VanOrder({
    required this.id,
    required this.customerName,
    required this.itemsLabel,
    required this.amount,
    required this.createdAt,
    required this.syncStatus,
  });

  final String id;
  final String customerName;
  final String itemsLabel;
  final double amount;
  final DateTime createdAt;
  final OrderSyncStatus syncStatus;

  VanOrder copyWith({OrderSyncStatus? syncStatus}) {
    return VanOrder(
      id: id,
      customerName: customerName,
      itemsLabel: itemsLabel,
      amount: amount,
      createdAt: createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}

class Collection {
  const Collection({
    required this.id,
    required this.customerName,
    required this.amount,
    required this.method,
    required this.collectedAt,
    required this.synced,
  });

  final String id;
  final String customerName;
  final double amount;
  final String method;
  final DateTime collectedAt;
  final bool synced;
}

class StockLine {
  const StockLine({
    required this.itemCode,
    required this.itemName,
    required this.qty,
    required this.uom,
  });

  final String itemCode;
  final String itemName;
  final double qty;
  final String uom;

  StockLine copyWith({double? qty}) {
    return StockLine(
      itemCode: itemCode,
      itemName: itemName,
      qty: qty ?? this.qty,
      uom: uom,
    );
  }
}

class DaySummary {
  const DaySummary({
    required this.stopsTotal,
    required this.stopsDone,
    required this.ordersQueued,
    required this.collectionsToday,
    required this.vanStockSku,
  });

  final int stopsTotal;
  final int stopsDone;
  final int ordersQueued;
  final double collectionsToday;
  final int vanStockSku;
}
