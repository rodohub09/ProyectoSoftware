import 'package:flutter/material.dart';

class Divisor extends StatelessWidget {
  const Divisor({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(thickness: 1.2)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text("o"),
        ),
        Expanded(child: Divider(thickness: 1.2)),
      ],
    );
  }
}
