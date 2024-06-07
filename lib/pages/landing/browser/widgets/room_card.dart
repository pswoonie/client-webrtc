import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../model/room_model.dart';

class RoomCard extends StatelessWidget {
  final int index;
  final RoomModel room;
  final void Function() onDelete;
  const RoomCard({
    super.key,
    required this.index,
    required this.room,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      color: Colors.deepPurple,
      child: SizedBox(
        height: 200,
        width: 300,
        child: Column(
          children: [
            Container(
              height: 140,
              width: 280,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.deepPurple[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  room.title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 50, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    context.go('/landing/room');
                  },
                  child: const Text(
                    'JOIN',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: onDelete,
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
