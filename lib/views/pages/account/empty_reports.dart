import 'package:flutter/material.dart';
import 'package:note_taker/components/components.dart';

class EmptyNoteReport extends StatelessWidget {
  const EmptyNoteReport({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Text(
              'No tasks found',
              style: kSmallTitleTextStyle,
            )
          ],
        ),
      ),
    );
  }
}
