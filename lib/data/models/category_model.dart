import 'package:starter_pack/data/models/app_model.dart';

class CategoryModel {
  final String categoryName;
  final List<AppModel> apps;

  CategoryModel({required this.categoryName, required this.apps});
}
