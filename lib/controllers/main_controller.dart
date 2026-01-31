import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/database_service.dart';

class MainController extends GetxController {
  final _dbService = DatabaseService();
  StreamSubscription<Map<String, dynamic>?>? _statusSubscription;
  StreamSubscription<Map<String, dynamic>?>? _settingsSubscription;
  StreamSubscription<Map<String, dynamic>?>? _liveDataSubscription;
  bool _isSyncingFromDb = false; // Prevent circular updates

  final tabIndex = 0.obs;

  final isStandbyMode = false.obs;

  final startHour = 6.obs;
  final startMinute = 0.obs;
  final startIsAm = true.obs;

  final endHour = 10.obs;
  final endMinute = 0.obs;
  final endIsAm = false.obs;

  final brightnessValue = 0.8.obs; // 0..1
  final hue = 0.0.obs; // 0..360
  final sat = 1.0.obs; // 0..1
  final val = 1.0.obs; // 0..1

  final selectedColor = const Color(0xFFFF0000).obs;
  final colorPresets = <Color>[
    const Color(0xFFFF0000),
    const Color(0xFF00D26A),
    const Color(0xFF2F7CFF),
    const Color(0xFFFFA000),
    const Color(0xFF8E5CFF),
  ].obs;

  final region = '서울'.obs;

  final weatherCondition = '맑음'.obs;

  final rainPercent = 0.30.obs; // 0..1 (display 30%)
  final rainThreshold = 0.50.obs; // 0..1

  final dustLabel = '좋음'.obs;
  final dustThreshold = 0.5.obs; // 0..1 (mapped to labels in UI)

  @override
  void onInit() {
    super.onInit();
    _listenToDatabase();
    _loadInitialData();
  }

  @override
  void onClose() {
    _statusSubscription?.cancel();
    _settingsSubscription?.cancel();
    _liveDataSubscription?.cancel();
    super.onClose();
  }

  Future<void> _loadInitialData() async {
    // Load status
    final status = await _dbService.getStatus();
    if (status != null) {
      _isSyncingFromDb = true;
      if (status['is_on'] != null) {
        isStandbyMode.value = status['is_on'] as bool;
      }
      if (status['brightness'] != null) {
        final brightness = (status['brightness'] as int) / 100.0;
        brightnessValue.value = brightness.clamp(0.0, 1.0);
      }
      if (status['color'] != null) {
        final colorHex = status['color'] as String;
        _setColorFromHex(colorHex);
      }
      _isSyncingFromDb = false;
    }

    // Load settings
    final settings = await _dbService.getSettings();
    if (settings != null) {
      _isSyncingFromDb = true;
      
      // Schedule
      if (settings['schedule'] != null) {
        final schedule = settings['schedule'] as Map;
        if (schedule['start_time'] != null) {
          _setTimeFromString(schedule['start_time'] as String, isStart: true);
        }
        if (schedule['end_time'] != null) {
          _setTimeFromString(schedule['end_time'] as String, isStart: false);
        }
      }
      
      // Region
      if (settings['region'] != null) {
        final regionData = settings['region'] as Map;
        if (regionData['location'] != null) {
          // Convert English name from DB to Korean for UI
          final englishName = regionData['location'] as String;
          region.value = _englishToKoreanRegion(englishName);
        }
      }
      
      // Thresholds
      if (settings['thresholds'] != null) {
        final thresholds = settings['thresholds'] as Map;
        if (thresholds['rain_threshold'] != null) {
          rainThreshold.value = (thresholds['rain_threshold'] as int) / 100.0;
        }
        if (thresholds['dust_threshold'] != null) {
          dustThreshold.value = (thresholds['dust_threshold'] as int) / 100.0;
          dustLabel.value = _dustLabelFor(dustThreshold.value);
        }
      }
      
      _isSyncingFromDb = false;
    }

    // Load live data
    final liveData = await _dbService.getLiveData();
    if (liveData != null) {
      if (liveData['rain_probability'] != null) {
        rainPercent.value = (liveData['rain_probability'] as int) / 100.0;
      }
      if (liveData['dust_status'] != null) {
        dustLabel.value = liveData['dust_status'] as String;
      }
    }
  }

  void _listenToDatabase() {
    // Listen to status changes
    _statusSubscription = _dbService.getStatusStream().listen((data) {
      if (data == null || _isSyncingFromDb) return;
      
      _isSyncingFromDb = true;
      
      if (data['is_on'] != null) {
        isStandbyMode.value = data['is_on'] as bool;
      }
      if (data['brightness'] != null) {
        final brightness = (data['brightness'] as int) / 100.0;
        brightnessValue.value = brightness.clamp(0.0, 1.0);
      }
      if (data['color'] != null) {
        final colorHex = data['color'] as String;
        _setColorFromHex(colorHex);
      }
      
      _isSyncingFromDb = false;
    });

    // Listen to settings changes
    _settingsSubscription = _dbService.getSettingsStream().listen((data) {
      if (data == null || _isSyncingFromDb) return;
      
      _isSyncingFromDb = true;
      
      // Schedule
      if (data['schedule'] != null) {
        final schedule = data['schedule'] as Map;
        if (schedule['start_time'] != null) {
          _setTimeFromString(schedule['start_time'] as String, isStart: true);
        }
        if (schedule['end_time'] != null) {
          _setTimeFromString(schedule['end_time'] as String, isStart: false);
        }
      }
      
      // Region
      if (data['region'] != null) {
        final regionData = data['region'] as Map;
        if (regionData['location'] != null) {
          // Convert English name from DB to Korean for UI
          final englishName = regionData['location'] as String;
          region.value = _englishToKoreanRegion(englishName);
        }
      }
      
      // Thresholds
      if (data['thresholds'] != null) {
        final thresholds = data['thresholds'] as Map;
        if (thresholds['rain_threshold'] != null) {
          rainThreshold.value = (thresholds['rain_threshold'] as int) / 100.0;
        }
        if (thresholds['dust_threshold'] != null) {
          dustThreshold.value = (thresholds['dust_threshold'] as int) / 100.0;
          dustLabel.value = _dustLabelFor(dustThreshold.value);
        }
      }
      
      _isSyncingFromDb = false;
    });

    // Listen to live data changes (read-only)
    _liveDataSubscription = _dbService.getLiveDataStream().listen((data) {
      if (data == null) return;
      
      if (data['rain_probability'] != null) {
        rainPercent.value = (data['rain_probability'] as int) / 100.0;
      }
      if (data['dust_status'] != null) {
        dustLabel.value = data['dust_status'] as String;
      }
    });
  }

  void _setColorFromHex(String hex) {
    try {
      // Remove # if present
      final cleanHex = hex.replaceAll('#', '');
      final colorValue = int.parse(cleanHex, radix: 16);
      final color = Color(0xFF000000 | colorValue);
      setSelectedColor(color);
    } catch (e) {
      // Invalid hex, ignore
    }
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  void setTab(int index) => tabIndex.value = index;

  Future<void> toggleStandby() async {
    isStandbyMode.value = !isStandbyMode.value;
    if (!_isSyncingFromDb) {
      await _dbService.updatePower(isStandbyMode.value);
    }
  }

  Future<void> setBrightness(double v) async {
    brightnessValue.value = v.clamp(0.0, 1.0);
    if (!_isSyncingFromDb) {
      final brightnessInt = (brightnessValue.value * 100).round();
      await _dbService.updateBrightness(brightnessInt);
    }
  }

  TimeOfDay get startTimeOfDay => TimeOfDay(
        hour: _to24(startIsAm.value, startHour.value, startMinute.value).$1,
        minute: startMinute.value,
      );

  TimeOfDay get endTimeOfDay => TimeOfDay(
        hour: _to24(endIsAm.value, endHour.value, endMinute.value).$1,
        minute: endMinute.value,
      );

  Future<void> setStartTime(TimeOfDay t) async {
    _setFrom24(
      t.hour,
      t.minute,
      isAm: startIsAm,
      hour: startHour,
      minute: startMinute,
    );
    if (!_isSyncingFromDb) {
      final timeStr = _timeToString(t);
      final endTimeStr = _timeToString(endTimeOfDay);
      await _dbService.updateSchedule(timeStr, endTimeStr);
    }
  }

  Future<void> setEndTime(TimeOfDay t) async {
    _setFrom24(
      t.hour,
      t.minute,
      isAm: endIsAm,
      hour: endHour,
      minute: endMinute,
    );
    if (!_isSyncingFromDb) {
      final startTimeStr = _timeToString(startTimeOfDay);
      final timeStr = _timeToString(t);
      await _dbService.updateSchedule(startTimeStr, timeStr);
    }
  }

  void _setTimeFromString(String timeStr, {required bool isStart}) {
    // Parse "HH:mm" format
    final parts = timeStr.split(':');
    if (parts.length != 2) return;
    
    final hour24 = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour24 == null || minute == null) return;
    
    if (isStart) {
      _setFrom24(hour24, minute, isAm: startIsAm, hour: startHour, minute: startMinute);
    } else {
      _setFrom24(hour24, minute, isAm: endIsAm, hour: endHour, minute: endMinute);
    }
  }

  String _timeToString(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void setHue(double h) {
    hue.value = h.clamp(0.0, 360.0);
    _syncColorFromHsv();
  }

  void setSv(double s, double v) {
    sat.value = s.clamp(0.0, 1.0);
    val.value = v.clamp(0.0, 1.0);
    _syncColorFromHsv();
  }

  Future<void> setSelectedColor(Color c) async {
    selectedColor.value = c;
    final hsv = HSVColor.fromColor(c);
    hue.value = hsv.hue;
    sat.value = hsv.saturation;
    val.value = hsv.value;
    
    if (!_isSyncingFromDb) {
      await _dbService.updateColor(_colorToHex(c));
    }
  }

  void _syncColorFromHsv() {
    selectedColor.value = HSVColor.fromAHSV(1, hue.value, sat.value, val.value)
        .toColor();
  }

  void addPreset(Color c) {
    if (colorPresets.any((p) => p.value == c.value)) return;
    colorPresets.insert(0, c);
    if (colorPresets.length > 7) {
      colorPresets.removeRange(7, colorPresets.length);
    }
  }

  Future<void> setRegion(String v) async {
    region.value = v;
    if (!_isSyncingFromDb) {
      // Convert Korean name to English for database
      final englishName = _koreanToEnglishRegion(v);
      await _dbService.updateRegion(englishName);
    }
  }

  String _koreanToEnglishRegion(String korean) {
    const mapping = {
      '서울': 'Seoul',
      '인천': 'Incheon',
      '강원': 'Gangwon',
      '충북': 'Chungbuk',
      '충남': 'Chungnam',
      '경북': 'Gyeongbuk',
      '경남': 'Gyeongnam',
      '전북': 'Jeonbuk',
      '전남': 'Jeonnam',
    };
    return mapping[korean] ?? korean;
  }

  String _englishToKoreanRegion(String english) {
    const mapping = {
      'Seoul': '서울',
      'Incheon': '인천',
      'Gangwon': '강원',
      'Chungbuk': '충북',
      'Chungnam': '충남',
      'Gyeongbuk': '경북',
      'Gyeongnam': '경남',
      'Jeonbuk': '전북',
      'Jeonnam': '전남',
    };
    return mapping[english] ?? english;
  }

  Future<void> setRainThreshold(double v) async {
    rainThreshold.value = v.clamp(0.0, 1.0);
    if (!_isSyncingFromDb) {
      final rainInt = (rainThreshold.value * 100).round();
      final dustInt = (dustThreshold.value * 100).round();
      await _dbService.updateThresholds(rainInt, dustInt);
    }
  }

  Future<void> setDustThreshold(double v) async {
    dustThreshold.value = v.clamp(0.0, 1.0);
    dustLabel.value = _dustLabelFor(dustThreshold.value);
    if (!_isSyncingFromDb) {
      final rainInt = (rainThreshold.value * 100).round();
      final dustInt = (dustThreshold.value * 100).round();
      await _dbService.updateThresholds(rainInt, dustInt);
    }
  }

  static String _dustLabelFor(double v) {
    // snapped (divisions=4) => 0.0, 0.25, 0.5, 0.75, 1.0
    if (v <= 0.0) return '매우나쁨';
    if (v <= 0.25) return '나쁨';
    if (v <= 0.5) return '보통';
    if (v <= 0.75) return '좋음';
    return '매우좋음';
  }

  static (int, int) _to24(bool isAm, int hour12, int minute) {
    // hour12: 1..12
    var h = hour12 % 12;
    if (!isAm) h += 12;
    return (h, minute);
  }

  static void _setFrom24(
    int hour24,
    int minuteValue, {
    required RxBool isAm,
    required RxInt hour,
    required RxInt minute,
  }) {
    isAm.value = hour24 < 12;
    var h12 = hour24 % 12;
    if (h12 == 0) h12 = 12;
    hour.value = h12;
    minute.value = minuteValue;
  }
}

