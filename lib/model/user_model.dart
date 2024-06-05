class UserModel {
  String id;
  String name;

  UserModel({
    required this.id,
    required this.name,
  });

  UserModel.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String,
        name = json['name'] as String;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}
