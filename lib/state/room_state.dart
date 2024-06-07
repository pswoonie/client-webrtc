import 'dart:math';

import 'package:flutter/material.dart';

import '../model/room_model.dart';

class RoomState with ChangeNotifier {
  final _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _random = Random();

  final List<RoomModel> _roomList = [];
  List<RoomModel> get roomList => _roomList.toList();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_random.nextInt(_chars.length))));

  void addNewRoom() {
    var id = getRandomString(25);
    var rand = getRandomString(5);
    var room = RoomModel(id: id, title: 'title-$rand');
    _roomList.add(room);
    notifyListeners();
  }

  void removeRoom(int index) {
    _roomList.removeAt(index);
    notifyListeners();
  }
}
