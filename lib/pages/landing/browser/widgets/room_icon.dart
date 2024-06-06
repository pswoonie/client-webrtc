import 'package:flutter/material.dart';

class RoomIcon extends StatelessWidget {
  final String title;
  const RoomIcon({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        fixedSize: const Size(60, 60),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        ),
      ),
      child: Center(
        child: Text(
          (title == '0') ? 'x' : title,
          style: TextStyle(
            color: Colors.deepPurple[50],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
