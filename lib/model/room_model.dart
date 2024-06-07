class RoomModel {
  String id;
  String title;

  RoomModel({
    required this.id,
    required this.title,
  });

  RoomModel.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String,
        title = json['title'] as String;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
      };
}
