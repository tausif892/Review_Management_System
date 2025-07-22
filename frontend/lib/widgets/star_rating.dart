import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final double size;
  final bool interactive;
  final Function(int)? onRatingChanged;

  const StarRating({
    Key? key,
    required this.rating,
    this.size = 20,
    this.interactive = false,
    this.onRatingChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: interactive ? () => onRatingChanged?.call(index + 1) : null,
          child: Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: size,
          ),
        );
      }),
    );
  }
}
