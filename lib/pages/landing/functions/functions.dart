import '../../../state/room_state.dart';

class Func {
  void handleOnPressed(int index, RoomState controller) {
    switch (index) {
      case 1:
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
        return 'Menu1';
      case 2:
        return 'Menu2';
      case 3:
        return 'Menu3';
      default:
        return '';
    }
  }
}
