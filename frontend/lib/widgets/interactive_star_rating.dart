import 'package:flutter/material.dart';

class InteractiveStarRating extends StatefulWidget {
  final int initialRating;
  final Function(int) onRatingChanged;

  const InteractiveStarRating({
    Key? key,
    required this.initialRating,
    required this.onRatingChanged,
  }) : super(key: key);

  @override
  _InteractiveStarRatingState createState() => _InteractiveStarRatingState();
}

class _InteractiveStarRatingState extends State<InteractiveStarRating> {
  int _currentRating = 0;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _currentRating = index + 1;
            });
            widget.onRatingChanged(_currentRating);
          },
          child: Icon(
            index < _currentRating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 30,
          ),
        );
      }),
    );
  }
}
