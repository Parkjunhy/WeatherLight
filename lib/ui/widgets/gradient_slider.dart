import 'package:flutter/material.dart';

class GradientSlider extends StatelessWidget {
  const GradientSlider({
    super.key,
    required this.value,
    required this.onChanged,
    required this.gradient,
    this.divisions,
  });

  final double value; // 0..1
  final ValueChanged<double> onChanged;
  final Gradient gradient;
  final int? divisions;

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0.0, 1.0);
    return LayoutBuilder(
      builder: (context, constraints) {
        final trackH = 6.0;
        final trackW = constraints.maxWidth;
        final activeW = trackW * v;

        return Stack(
          alignment: Alignment.centerLeft,
          children: [
            // Inactive track (light gray)
            Container(
              height: trackH,
              decoration: BoxDecoration(
                color: const Color(0xFFE8ECF2),
                borderRadius: BorderRadius.circular(trackH / 2),
              ),
            ),
            // Active track (gradient)
            ClipRRect(
              borderRadius: BorderRadius.circular(trackH / 2),
              child: Align(
                alignment: Alignment.centerLeft,
                widthFactor: v,
                child: Container(
                  height: trackH,
                  width: trackW,
                  decoration: BoxDecoration(gradient: gradient),
                ),
              ),
            ),
            // Real Slider on top (transparent track)
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: trackH,
                overlayShape: SliderComponentShape.noOverlay,
                activeTrackColor: Colors.transparent,
                inactiveTrackColor: Colors.transparent,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              ),
              child: Slider(
                value: v,
                onChanged: onChanged,
                divisions: divisions,
              ),
            ),
          ],
        );
      },
    );
  }
}

