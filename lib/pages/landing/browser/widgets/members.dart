import 'package:flutter/material.dart';

class MemberIcon extends StatelessWidget {
  final String name;
  const MemberIcon({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        fixedSize: const Size(180, 45),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
        padding: EdgeInsets.zero,
      ),
      child: Row(
        children: [
          Container(
            height: 35,
            width: 35,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: Colors.deepPurple[200],
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
            ),
          ),
          Text(
            name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class Members extends StatelessWidget {
  Members({super.key});

  final List<String> memberList = [
    'James',
    'Kevin',
    'Michael',
    'Johnson',
    'Nick'
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(width: 2, color: Colors.deepPurple),
        ),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              const Text(
                'Members',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: memberList.length,
                itemBuilder: (context, index) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MemberIcon(name: memberList[index]),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          Positioned(
            left: 20,
            bottom: 16,
            child: SizedBox(
              width: 150,
              child: FloatingActionButton(
                onPressed: () {},
                child: const Text(
                  '+ Invite Friends',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
