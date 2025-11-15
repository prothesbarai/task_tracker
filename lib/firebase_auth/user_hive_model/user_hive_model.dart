import 'package:hive/hive.dart';
part 'user_hive_model.g.dart';

@HiveType(typeId: 1)
class UserHiveModel extends HiveObject {
  @HiveField(0)
  String uid;

  @HiveField(1)
  String name;

  @HiveField(2)
  String email;

  @HiveField(3)
  String phone;

  UserHiveModel({required this.uid, required this.name, required this.email, required this.phone,});
}
