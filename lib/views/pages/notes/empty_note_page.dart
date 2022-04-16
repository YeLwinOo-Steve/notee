import 'package:flutter/material.dart';
import 'package:note_taker/components/constants.dart';
import 'package:note_taker/views/widgets/custom_elevated_button.dart';

class EmptyNotePage extends StatelessWidget {
  const EmptyNotePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Expanded(
            flex: 5,
            child: Transform.scale(
              scale: 1,
              child: Image.asset(
                'assets/empty_note.png',
              ),
            ),
          ),
          const Expanded(
              child: Text(
            'No notes found',
            style: kTitleTextStyle,
          )),
        ],
      ),
    );
  }
}
