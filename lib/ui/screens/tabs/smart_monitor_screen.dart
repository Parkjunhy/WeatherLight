import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/main_controller.dart';
import '../../../theme/app_colors.dart';
import '../../widgets/gradient_slider.dart';
import '../../widgets/neumorphic_card.dart';

class SmartMonitorScreen extends StatelessWidget {
  const SmartMonitorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<MainController>();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 96),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF1C6BFF), Color(0xFF55B3FF)],
                ).createShader(bounds),
                child: Text(
                  'WeatherLight',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 32,
                        letterSpacing: -0.5,
                        color: Colors.white,
                      ),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // [블록 1] 지역 설정
            NeumorphicCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF3FF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.place_rounded,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        '지역 설정',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                              letterSpacing: -0.2,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE6EAF2)),
                    ),
                    child: Obx(() {
                      return DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: c.region.value,
                          borderRadius: BorderRadius.circular(16),
                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(value: '서울', child: Text('서울')),
                            DropdownMenuItem(value: '인천', child: Text('인천')),
                            DropdownMenuItem(value: '강원', child: Text('강원')),
                            DropdownMenuItem(value: '충북', child: Text('충북')),
                            DropdownMenuItem(value: '충남', child: Text('충남')),
                            DropdownMenuItem(value: '경북', child: Text('경북')),
                            DropdownMenuItem(value: '경남', child: Text('경남')),
                            DropdownMenuItem(value: '전북', child: Text('전북')),
                            DropdownMenuItem(value: '전남', child: Text('전남')),
                          ],
                          onChanged: (v) {
                            if (v == null) return;
                            c.setRegion(v);
                          },
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '선택한 지역의 날씨 정보를 바탕으로 스마트하게 제어합니다.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.subText,
                        ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // [블록 2] 모드 선택 (터치 영역 격리 문제 해결됨)
            NeumorphicCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF3FF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.monitor_rounded,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        '모드 선택',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                              letterSpacing: -0.2,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  
                  // 모드 선택 토글 버튼
                  Container(
                    height: 52, // 높이 고정으로 레이아웃 안정화
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F4F8), // 전체 트랙 배경색
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Obx(() {
                      final isRain = c.monitorMode.value == 'rain';
                      
                      return Row(
                        children: [
                          // 1. 강수확률 버튼
                          Expanded(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: isRain ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: isRain
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        )
                                      ]
                                    : [],
                              ),
                              // [중요] Ripple 효과가 둥근 모서리 밖으로 나가지 않도록 자름
                              clipBehavior: Clip.hardEdge, 
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => c.setMonitorMode('rain'),
                                  borderRadius: BorderRadius.circular(10),
                                  splashColor: const Color(0xFFDEE6F2), // 은은한 회색
                                  highlightColor: const Color(0xFFEFF4F9),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.water_drop_rounded,
                                          size: 18,
                                          color: isRain ? AppColors.accent : AppColors.subText,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '강수확률',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: isRain ? AppColors.text : AppColors.subText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: 4),

                          // 2. 미세먼지 버튼
                          Expanded(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: !isRain ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: !isRain
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        )
                                      ]
                                    : [],
                              ),
                              // [중요] Ripple 효과 격리
                              clipBehavior: Clip.hardEdge,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => c.setMonitorMode('dust'),
                                  borderRadius: BorderRadius.circular(10),
                                  splashColor: const Color(0xFFDEE6F2),
                                  highlightColor: const Color(0xFFEFF4F9),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.grain_rounded,
                                          size: 18,
                                          color: !isRain ? AppColors.accent : AppColors.subText,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '미세먼지',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: !isRain ? AppColors.text : AppColors.subText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '선택한 모드의 알림값이 초과되면 LED가 작동합니다.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.subText,
                        ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // [블록 3] 오늘 날씨
            NeumorphicCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF3FF),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.wb_sunny_rounded,
                              color: AppColors.accent,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '오늘 날씨',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 20,
                                      letterSpacing: -0.2,
                                    ),
                              ),
                              Obx(() => Text(
                                c.weatherLastUpdated.value.isEmpty 
                                  ? '업데이트 중...' 
                                  : '최근 업데이트 : ${_formatTime(c.weatherLastUpdated.value)}',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: AppColors.subText,
                                      fontSize: 11,
                                    ),
                              )),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 3단 정보 표시
                  Obx(() => Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Icon(
                                  _getWeatherIcon(c.weatherCondition.value),
                                  size: 32,
                                  color: AppColors.accent,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  c.weatherCondition.value,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1.5,
                            height: 40,
                            color: const Color(0xFFE6EAF2),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.water_drop_rounded,
                                  size: 32,
                                  color: AppColors.accent,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${(c.rainPercent.value * 100).round()}%',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1.5,
                            height: 40,
                            color: const Color(0xFFE6EAF2),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  '미세먼지',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppColors.subText,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  c.dustLabel.value,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 20,
                                        color: _getDustColor(c.dustLabel.value),
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )),
                  const SizedBox(height: 10),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // [블록 4] 강수 확률 모니터
            NeumorphicCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF3FF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.beach_access_rounded, 
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        '강수 확률 모니터',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                              letterSpacing: -0.2,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Obx(() {
                    final t = (c.rainThreshold.value * 100).round();
                    return Text(
                      '$t%',
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall
                          ?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.accent,
                            letterSpacing: -1.0,
                          ),
                    );
                  }),
                  const SizedBox(height: 10),
                  Text(
                    '알림값 설정',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.subText,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    return GradientSlider(
                      value: c.rainThreshold.value,
                      onChanged: c.setRainThreshold,
                      gradient: const LinearGradient(
                        colors: [AppColors.accent, Color(0xFF55B3FF)],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // [블록 5] 미세먼지 모니터
            NeumorphicCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF3FF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.grass_rounded,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        '미세먼지 모니터',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                              letterSpacing: -0.2,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Obx(() {
                    return Text(
                      c.dustLabel.value,
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall
                          ?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.accent,
                            letterSpacing: -1.0,
                          ),
                    );
                  }),
                  const SizedBox(height: 10),
                  Text(
                    '알림값 설정',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.subText,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    return GradientSlider(
                      value: c.dustThreshold.value,
                      onChanged: c.setDustThreshold,
                      gradient: const LinearGradient(
                        colors: [AppColors.accent, Color(0xFF55B3FF)],
                      ),
                      divisions: 4,
                    );
                  }),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _Tick('매우나쁨'),
                      _Tick('나쁨'),
                      _Tick('보통'),
                      _Tick('좋음'),
                      _Tick('매우좋음'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 헬퍼 함수
  String _formatTime(String dateTimeStr) {
    try {
      final parts = dateTimeStr.split(' ');
      if (parts.length > 1) {
        final timeParts = parts[1].split(':');
        return '${timeParts[0]}:${timeParts[1]}';
      }
      return dateTimeStr;
    } catch (e) {
      return dateTimeStr;
    }
  }

  static String _dustLabelFor(double v) {
    if (v <= 0.0) return '매우나쁨';
    if (v <= 0.25) return '나쁨';
    if (v <= 0.5) return '보통';
    if (v <= 0.75) return '좋음';
    return '매우좋음';
  }
}

class _Tick extends StatelessWidget {
  const _Tick(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: const Color(0xFF9AA4B5),
            fontWeight: FontWeight.w700,
          ),
    );
  }
}

IconData _getWeatherIcon(String condition) {
  if (condition.contains('구름')) return Icons.cloud_rounded;
  if (condition.contains('비')) return Icons.umbrella_rounded;
  if (condition.contains('눈')) return Icons.ac_unit_rounded;
  return Icons.wb_sunny_rounded; 
}

Color _getDustColor(String status) {
  if (status == '좋음' || status == '매우좋음') return const Color(0xFF00D26A);
  if (status == '보통') return const Color(0xFF2F7CFF);
  if (status == '나쁨') return const Color(0xFFFFA000);
  if (status == '매우나쁨') return const Color(0xFFFF0000);
  return AppColors.text;
}