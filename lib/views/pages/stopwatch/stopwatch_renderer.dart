import 'dart:math';

import 'package:flutter/material.dart';
import 'package:note_taker/components/colors.dart';
import 'package:note_taker/views/widgets/widgets.dart';

class StopwatchRenderer extends StatelessWidget {
  const StopwatchRenderer(
      {Key? key, required this.elapsed, required this.radius})
      : super(key: key);
  final double radius;
  final Duration elapsed;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        for (int seconds = 0; seconds < 60; seconds++)
          Positioned(
            left: radius,
            top: radius,
            child: ClockMarkers(
              seconds: seconds,
              radius: radius,
            ),
          ),

        for (int seconds = 1; seconds <= 12; seconds++)
          Positioned(
            left: radius,
            top: radius,
            child: ClockText(
              time: seconds,
              radius: radius,
            ),
          ),
        Positioned(
          left: 0,
          right: 0,
          top: radius * 1.25,
          child: ElapsedTimeText(
            elapsed: elapsed,
            radius: radius,
          ),
        ),
        Positioned(
          left: radius,
          top: radius,
          child: ClockHand(
              rotationZ: pi + (2 * pi / 720) * elapsed.inMinutes,
              thickness: 6,
              length: radius * 0.45,
              color: kIconColor),
        ),
        Positioned(
          left: radius,
          top: radius,
          child: ClockHand(
              rotationZ: pi + (2 * pi / 3600) * elapsed.inSeconds,
              thickness: 4,
              length: radius * 0.6,
              color: kIconColor),
        ),
        Positioned(
          left: radius,
          top: radius,
          child: ClockHand(
              rotationZ: pi + (2 * pi / 60000) * elapsed.inMilliseconds,
              thickness: 3,
              length: radius,
              color: kIconColor),
        ),
        Positioned(
          left: radius - 10,
          top: radius - 10,
          child: SizedBox(
            height: 20,
            width: 20,
            child: Card(
              elevation: 5.0,
              color: kIconColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0)),
            ),
          ),
        )
      ],
    );
  }
}
