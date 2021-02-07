import 'package:flutter/widgets.dart';

class PedaxBoard extends StatelessWidget {
  const PedaxBoard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/images/black_stone.png', fit: BoxFit.contain, height: 32),
          ],
        ),
      );
}
