import 'package:flutter/material.dart';

import '../../../state/auth_state.dart';
import '../../../state/room_state.dart';
import 'widgets/button_menu.dart';
import 'widgets/room_card.dart';

class Browser extends StatefulWidget {
  final AuthState authController;
  final RoomState roomController;
  const Browser({
    super.key,
    required this.authController,
    required this.roomController,
  });

  @override
  State<Browser> createState() => _BrowserState();
}

class _BrowserState extends State<Browser> {
  late RoomState roomController;

  @override
  void initState() {
    super.initState();
    roomController = widget.roomController;
  }

  void handleOnPressed(int index) {
    switch (index) {
      case 1:
        break;
      case 2:
        break;
      case 3:
        break;
      default:
        roomController.addNewRoom();
    }
  }

  String getTitle(int index) {
    switch (index) {
      case 1:
        return 'Menu1';
      case 2:
        return 'Menu2';
      case 3:
        return 'Menu3';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 3,
        toolbarHeight: 70,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 4,
                itemBuilder: (context, index) {
                  return ButtonMenu(
                    index: index,
                    title: getTitle(index),
                    onPressed: () {
                      handleOnPressed(index);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 950,
            child: ScrollConfiguration(
              behavior:
                  ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: SingleChildScrollView(
                child: ListenableBuilder(
                    listenable: roomController,
                    builder: (context, child) {
                      return Wrap(
                        children: List.generate(
                          roomController.roomList.length,
                          (index) {
                            return RoomCard(
                              index: index,
                              room: roomController.roomList[index],
                              onDelete: () {
                                roomController.removeRoom(index);
                              },
                            );
                          },
                        ),
                      );
                    }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
