import 'package:flutter/material.dart';

import '../../../model/room_model.dart';

class RoomCard extends StatelessWidget {
  final int index;
  final RoomModel room;
  final void Function() onDelete;
  final void Function() onJoin;
  const RoomCard({
    super.key,
    required this.index,
    required this.room,
    required this.onDelete,
    required this.onJoin,
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
                child: SelectionArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        room.title,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        room.id,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onJoin,
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
