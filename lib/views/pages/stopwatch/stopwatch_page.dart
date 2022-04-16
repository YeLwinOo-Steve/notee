import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:note_taker/views/widgets/widgets.dart';

import 'stopwatch_renderer.dart';
import '../../../components/components.dart';

class StopwatchPage extends StatefulWidget {
  const StopwatchPage({Key? key}) : super(key: key);

  @override
  State<StopwatchPage> createState() => _StopwatchPageState();
}

class _StopwatchPageState extends State<StopwatchPage>
    with TickerProviderStateMixin {
  Duration _previousElapsedTime = Duration.zero;
  Duration _currentElapsedTime = Duration.zero;
  late final Ticker _ticker;
  late AnimationController _playPauseController;
  bool _isPlaying = false;
  Duration get _elapsed => _previousElapsedTime + _currentElapsedTime;
  @override
  void initState() {
    super.initState();
    _playPauseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    _ticker = createTicker((elapsed) {
      setState(() {
        _currentElapsedTime = elapsed;
      });
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void toggleRun() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _ticker.start();
        _playPauseController.forward();
      } else {
        _ticker.stop();
        _previousElapsedTime += _currentElapsedTime;
        _currentElapsedTime = Duration.zero;
        _playPauseController.reverse();
      }
    });
  }

  void reset() {
    setState(() {
      _isPlaying = false;
      _ticker.stop();
      _playPauseController.reverse();
      _previousElapsedTime = Duration.zero;
      _currentElapsedTime = Duration.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 50.0, right: 50.0, top: 0.0),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1.0,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final radius = constraints.maxWidth * 0.5;
                    return StopwatchRenderer(elapsed: _elapsed, radius: radius);
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 50.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  splashColor: kPrimaryColor,
                  borderRadius: BorderRadius.circular(50.0),
                  onTap: toggleRun,
                  child: Card(
                    elevation: 10.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    shadowColor: Theme.of(context).scaffoldBackgroundColor,
                    child: AnimatedContainer(
                      width: 60.0,
                      height: 60.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50.0),
                        color: _isPlaying ? Colors.red.shade400 : kIconColor,
                      ),
                      duration: const Duration(milliseconds: 250),
                      child: Center(
                        child: AnimatedIcon(
                          icon: AnimatedIcons.play_pause,
                          size: 35.0,
                          color: kPrimaryColor,
                          progress: _playPauseController,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10.0,
                ),
                RoundedIconButton(
                  icon: Icons.stop_rounded,
                  color: kIconColor,
                  onTap: reset,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
