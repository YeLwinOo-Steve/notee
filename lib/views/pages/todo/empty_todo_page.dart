import 'package:flutter/material.dart';

import '../../../components/components.dart';

class EmptyTodoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 5,
              child: Image.asset(
            'assets/empty_todo.png',
            height: 300.0,
          )),
          Expanded(
            child: RichText(
              text: const TextSpan(
                text: 'No tasks found ',
                style: kTitleTextStyle,
                children: <TextSpan>[
                  TextSpan(text: '\nPlan up to', style: kBodyTextStyle),
                  TextSpan(text: ' 50 days', style: kTitleTextStyle),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
