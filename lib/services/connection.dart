import 'session.dart';

class ConnectionResult {
  const ConnectionResult({required this.ok, required this.message});

  final bool ok;
  final String message;
}

/// Ping ERPNext; business APIs stay on mock until `go_van` is deployed.
Future<ConnectionResult> testConnection(GoVanSession session) async {
  final result = await session.ping();
  return ConnectionResult(ok: result.ok, message: result.message);
}
