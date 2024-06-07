import 'package:flutter/material.dart';

class ButtonMenu extends StatelessWidget {
  final int index;
  final String title;
  final void Function() onPressed;
  const ButtonMenu({
    super.key,
    required this.index,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          fixedSize: const Size(60, 60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
          ),
          padding: EdgeInsets.zero,
        ),
        child: (index == 0)
            ? const Icon(Icons.add, color: Colors.white)
            : Center(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.deepPurple[50],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
      ),
    );
  }
}
