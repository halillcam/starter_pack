import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:starter_pack/data/models/app_model.dart';
import 'package:starter_pack/data/models/category_model.dart';

class Service {
  final Dio _dio = Dio();

  final String categoriesUrl =
      'https://raw.githubusercontent.com/halillcam/Starter-Pack-Datas/main/categories.json';

  Future<List<CategoryModel>> fetchEverything() async {
    try {
      final response = await _dio.get(categoriesUrl);

      if (response.statusCode != 200) {
        throw Exception('Kategoriler alınamadı');
      }

      final List<dynamic> categoriesJson = response.data is String
          ? jsonDecode(response.data)
          : response.data;

      List<CategoryModel> finalizedList = [];

      for (final category in categoriesJson) {
        final String categoryName = category['categoryName'] ?? '';
        final String appsUrl = category['appsUrl'] ?? '';

        if (appsUrl.isEmpty) continue;

        try {
          final subResponse = await _dio.get(appsUrl);

          print('$categoryName Status: ${subResponse.statusCode}');

          if (subResponse.statusCode != 200) {
            continue;
          }

          final List<dynamic> appsJson = subResponse.data is String
              ? jsonDecode(subResponse.data)
              : subResponse.data;

          final List<AppModel> appsList = appsJson.map((app) => AppModel.fromJson(app)).toList();

          finalizedList.add(CategoryModel(categoryName: categoryName, apps: appsList));
        } catch (e) {
          print('$categoryName kategorisinde hata: $e');
        }
      }

      print('Toplam kategori sayısı: ${finalizedList.length}');

      return finalizedList;
    } catch (e, s) {
      print('Genel hata: $e');
      print(s);
      throw Exception('Veri çekme hatası: $e');
    }
  }
}
