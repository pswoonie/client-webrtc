import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../state/room_state.dart';

mixin Func {
  Future<void> displayDialog(BuildContext context, RoomState controller) {
    final formKey = GlobalKey<FormState>();
    String rid = '';

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Room ID'),
          content: Form(
            key: formKey,
            child: TextFormField(
              onSaved: (str) {
                if (str != null) {
                  rid = str;
                }
              },
              validator: (str) {
                if (str == null || str.isEmpty) {
                  return 'Room ID is REQUIRED!';
                }

                return null;
              },
              onFieldSubmitted: (str) {
                if (str.isEmpty) return;
                context.pop();
                context.go('/landing/room');
                formKey.currentState?.reset();
              },
              decoration: const InputDecoration(
                label: Text('Room ID'),
                hintText: 'Aa',
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('JOIN'),
              onPressed: () {
                formKey.currentState!.save();
                if (formKey.currentState?.validate() != null &&
                    formKey.currentState!.validate()) {
                  controller.setCurrentRoom(rid);
                  context.pop();
                  context.go('/landing/room');
                  formKey.currentState?.reset();
                }
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Cancel'),
              onPressed: () {
                context.pop();
              },
            ),
          ],
        );
      },
    );
  }

  void handleOnPressed(int index, RoomState controller, BuildContext context) {
    switch (index) {
      case 1:
        displayDialog(context, controller);
        break;
      case 2:
        break;
      case 3:
        break;
      default:
        controller.addNewRoom();
    }
  }

  String getTitle(int index) {
    switch (index) {
      case 1:
        return 'JOIN';
      case 2:
        return 'Menu2';
      case 3:
        return 'Menu3';
      default:
        return '';
    }
  }
}
