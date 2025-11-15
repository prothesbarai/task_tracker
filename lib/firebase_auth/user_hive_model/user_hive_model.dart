import 'package:hive/hive.dart';
part 'user_hive_model.g.dart';

@HiveType(typeId: 1)
class UserHiveModel extends HiveObject {
  @HiveField(0)
  String uid;

  @HiveField(1)
  String email;

  UserHiveModel({required this.uid, required this.email});
}
