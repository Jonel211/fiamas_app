import 'package:shared_preferences/shared_preferences.dart';

class SyncPreferences {
  static const _kSyncActiva = 'sincronizacion_activa';
  static const _kUltimaSync = 'ultima_sincronizacion';

  Future<bool> isSyncActiva() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kSyncActiva) ?? false;
  }

  Future<void> setSyncActiva(bool activa) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kSyncActiva, activa);
  }

  Future<DateTime?> getUltimaSincronizacion() async {
    final prefs = await SharedPreferences.getInstance();
    final millis = prefs.getInt(_kUltimaSync);
    if (millis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  Future<void> setUltimaSincronizacion(DateTime fecha) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kUltimaSync, fecha.millisecondsSinceEpoch);
  }
}
