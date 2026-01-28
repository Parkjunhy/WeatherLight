import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/main_controller.dart';
import '../../../theme/app_colors.dart';
import '../../widgets/gradient_slider.dart';
import '../../widgets/neumorphic_card.dart';

class MainDashboardScreen extends StatelessWidget {
  const MainDashboardScreen({super.key});

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
            NeumorphicCard(
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF3FF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.bolt_rounded,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '스탠바이 모드',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20,
                                    letterSpacing: -0.2,
                                  ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          height: 36,
                          child: Obx(() {
                            return Text(
                              c.isStandbyMode.value
                                  ? '작동중'
                                  : '기상상황에 따라\n사람을 감지하면 켜집니다.',
                              style:
                                  Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.subText,
                                        height: 1.35,
                                      ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Obx(() {
                    final on = c.isStandbyMode.value;
                    return GestureDetector(
                      onTap: c.toggleStandby,
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.shadowDark,
                              blurRadius: 16,
                              offset: Offset(0, 10),
                            ),
                          ],
                          border: Border.all(
                            color: on
                                ? AppColors.accent
                                : const Color(0xFFE6EAF2),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.power_settings_new_rounded,
                              color: on
                                  ? AppColors.accent
                                  : const Color(0xFFB0BACB),
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 14),
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
                          Icons.access_time_rounded,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        '가동 시간 설정',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                              letterSpacing: -0.2,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _TimePickerTile(
                    title: '기상 모드',
                    getTime: () => c.startTimeOfDay,
                    onPicked: c.setStartTime,
                  ),
                  const SizedBox(height: 12),
                  _TimePickerTile(
                    title: '취침 모드',
                    getTime: () => c.endTimeOfDay,
                    onPicked: c.setEndTime,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
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
                          Icons.lightbulb_rounded,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        'LED 설정',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                              letterSpacing: -0.2,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Text(
                        '조명 밝기',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.subText,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const Spacer(),
                      Obx(() {
                        final p = (c.brightnessValue.value * 100).round();
                        return Text(
                          '$p%',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w800,
                              ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    return GradientSlider(
                      value: c.brightnessValue.value,
                      onChanged: c.setBrightness,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1C6BFF), Color(0xFF55B3FF)],
                      ),
                    );
                  }),
                  const SizedBox(height: 14),
                  Container(
                    height: 140,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: _DetailPalette(controller: c),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 18,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x11000000),
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: _HueStrip(controller: c),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Obx(() {
                    return _PresetRow(
                      selected: c.selectedColor.value,
                      onSelect: c.setSelectedColor,
                      presets: c.colorPresets,
                      onAdd: () => c.addPreset(c.selectedColor.value),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimePickerTile extends StatelessWidget {
  const _TimePickerTile({
    required this.title,
    required this.getTime,
    required this.onPicked,
  });

  final String title;
  final TimeOfDay Function() getTime;
  final ValueChanged<TimeOfDay> onPicked;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FD),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: base.bodySmall?.copyWith(
              color: const Color(0xFF7F8AA0),
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Obx(() {
            // Rebuild when controller updates via GetX (time stored in controller).
            final t = getTime();
            final ampm = t.period == DayPeriod.am ? 'AM' : 'PM';
            final hh = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
            final mm = t.minute.toString().padLeft(2, '0');
            return InkWell(
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: t,
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: Theme.of(context).colorScheme.copyWith(
                              primary: AppColors.accent,
                              primaryContainer: const Color(0xFFE8ECF2),
                              onPrimaryContainer: AppColors.text,
                              secondary: AppColors.subText,
                              secondaryContainer: const Color(0xFFE8ECF2),
                              onSecondaryContainer: AppColors.text,
                              tertiary: AppColors.subText,
                              tertiaryContainer: const Color(0xFFE8ECF2),
                              onTertiaryContainer: AppColors.text,
                            ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) onPicked(picked);
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE6EAF2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$ampm  $hh : $mm',
                      style: base.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: Color(0xFF9AA4B5),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _PresetRow extends StatelessWidget {
  const _PresetRow({
    required this.selected,
    required this.onSelect,
    required this.presets,
    required this.onAdd,
  });

  final Color selected;
  final ValueChanged<Color> onSelect;
  final List<Color> presets;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _AddButton(onTap: onAdd),
          const SizedBox(width: 12),
          ...presets.map((c) {
            final active = c.value == selected.value;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _ColorDot(
                color: c,
                active: active,
                onTap: () => onSelect(c),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowDark,
              blurRadius: 16,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: const Icon(
          Icons.add_rounded,
          color: Color(0xFF8EA0B8),
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.color,
    required this.active,
    required this.onTap,
  });

  final Color color;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: active ? Colors.white : Colors.transparent,
            width: 3,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 14,
              offset: Offset(0, 10),
            ),
          ],
        ),
      ),
    );
  }
}

class _HueStrip extends StatelessWidget {
  const _HueStrip({required this.controller});
  final MainController controller;

  @override
  Widget build(BuildContext context) {
    const gradient = LinearGradient(
      colors: [
        Color(0xFFFF0000),
        Color(0xFFFFFF00),
        Color(0xFF00FF00),
        Color(0xFF00FFFF),
        Color(0xFF0000FF),
        Color(0xFFFF00FF),
        Color(0xFFFF0000),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        return Obx(() {
          final h = controller.hue.value.clamp(0.0, 360.0);
          final x = (h / 360.0) * w;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanDown: (d) => _setHue(d.localPosition, w),
            onPanUpdate: (d) => _setHue(d.localPosition, w),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(decoration: const BoxDecoration(gradient: gradient)),
                Positioned(
                  left: x - 8,
                  top: 1,
                  bottom: 1,
                  child: Container(
                    width: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  void _setHue(Offset p, double w) {
    final t = (p.dx / w).clamp(0.0, 1.0);
    controller.setHue(t * 360.0);
  }
}

class _DetailPalette extends StatelessWidget {
  const _DetailPalette({required this.controller});
  final MainController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        return Obx(() {
          final hue = controller.hue.value;
          final s = controller.sat.value;
          final v = controller.val.value;
          final base = HSVColor.fromAHSV(1, hue, 1, 1).toColor();
          final x = s * size.width;
          final y = (1 - v) * size.height;

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanDown: (d) => _setSv(d.localPosition, size),
            onPanUpdate: (d) => _setSv(d.localPosition, size),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // saturation: white -> hue color
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, base],
                    ),
                  ),
                ),
                // value: transparent -> black
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x00000000),
                        Color(0xFF000000),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: x - 10,
                  top: y - 10,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  void _setSv(Offset p, Size size) {
    final s = (p.dx / size.width).clamp(0.0, 1.0);
    final v = (1 - (p.dy / size.height)).clamp(0.0, 1.0);
    controller.setSv(s, v);
  }
}

