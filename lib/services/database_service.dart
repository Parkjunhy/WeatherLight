import 'package:firebase_database/firebase_database.dart';

class DatabaseService {
  static const String _statusPath = 'weatherlight/status';
  static const String _settingsPath = 'weatherlight/settings';
  static const String _liveDataPath = 'weatherlight/live_data';
  
  // Initialize Firebase Database references
  final DatabaseReference _statusRef = FirebaseDatabase.instance.ref(_statusPath);
  final DatabaseReference _settingsRef = FirebaseDatabase.instance.ref(_settingsPath);
  final DatabaseReference _liveDataRef = FirebaseDatabase.instance.ref(_liveDataPath);

  // ========== STATUS (Power, Brightness, Color) ==========
  
  // Listen to all status changes
  Stream<Map<String, dynamic>?> getStatusStream() {
    return _statusRef.onValue.map((event) {
      final snapshot = event.snapshot;
      if (snapshot.value == null) return null;
      return Map<String, dynamic>.from(snapshot.value as Map);
    });
  }

  // Update power status
  Future<void> updatePower(bool isOn) async {
    await _statusRef.child('is_on').set(isOn);
  }

  // Update brightness (0-100)
  Future<void> updateBrightness(int brightness) async {
    await _statusRef.child('brightness').set(brightness);
  }

  // Update color (hex string)
  Future<void> updateColor(String colorHex) async {
    await _statusRef.child('color').set(colorHex);
  }

  // Get current status once
  Future<Map<String, dynamic>?> getStatus() async {
    final snapshot = await _statusRef.get();
    if (snapshot.value == null) return null;
    return Map<String, dynamic>.from(snapshot.value as Map);
  }

  // ========== SETTINGS (Schedule, Region, Thresholds) ==========

  // Listen to settings changes
  Stream<Map<String, dynamic>?> getSettingsStream() {
    return _settingsRef.onValue.map((event) {
      final snapshot = event.snapshot;
      if (snapshot.value == null) return null;
      return Map<String, dynamic>.from(snapshot.value as Map);
    });
  }

  // Get settings once
  Future<Map<String, dynamic>?> getSettings() async {
    final snapshot = await _settingsRef.get();
    if (snapshot.value == null) return null;
    return Map<String, dynamic>.from(snapshot.value as Map);
  }

  // Update schedule (start_time, end_time as "HH:mm" strings)
  Future<void> updateSchedule(String startTime, String endTime) async {
    await _settingsRef.child('schedule').set({
      'start_time': startTime,
      'end_time': endTime,
    });
  }

  // Update region
  Future<void> updateRegion(String location) async {
    await _settingsRef.child('region').set({
      'location': location,
    });
  }

  // Update thresholds (rain_threshold, dust_threshold as int 0-100)
  Future<void> updateThresholds(int rainThreshold, int dustThreshold) async {
    await _settingsRef.child('thresholds').set({
      'rain_threshold': rainThreshold,
      'dust_threshold': dustThreshold,
    });
  }

  // ========== LIVE DATA (Read-only, real-time updates) ==========

  // Listen to live weather data changes
  Stream<Map<String, dynamic>?> getLiveDataStream() {
    return _liveDataRef.onValue.map((event) {
      final snapshot = event.snapshot;
      if (snapshot.value == null) return null;
      return Map<String, dynamic>.from(snapshot.value as Map);
    });
  }

  // Get live data once
  Future<Map<String, dynamic>?> getLiveData() async {
    final snapshot = await _liveDataRef.get();
    if (snapshot.value == null) return null;
    return Map<String, dynamic>.from(snapshot.value as Map);
  }
}
