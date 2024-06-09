import 'package:flutter/material.dart';

const double size = 6.0;
const double spacing = 6.0;

class DotStepper extends StatelessWidget {
  const DotStepper({
    super.key,
    this.amount = 0,
    this.currentPage = 0
  });

  final int amount;
  final int currentPage;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        amount, 
        (index) =>
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: spacing / 2),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(
                  index < currentPage ? 1 : 0.25
                ),
                borderRadius: BorderRadius.circular(size / 2)
              ),
            ),
          )
      )
    );
  }
}