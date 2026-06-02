import 'package:starter_pack/Features/Mock%20Datas/app_list.dart';

import 'package:starter_pack/Features/models/category_model.dart';

class Datas {
  AppList appList = AppList();
  List<CategoryModel> apps() {
    return [
      CategoryModel(categoryName: "Sosyal Medya", apps: appList.socialMediaApps),
      CategoryModel(categoryName: "Tarayıcı", apps: appList.browserApps),
      CategoryModel(categoryName: "Yapay Zeka ", apps: appList.aiApps),
      CategoryModel(categoryName: "Navigasyon ", apps: appList.navigationApps),
      CategoryModel(categoryName: "Video ve Fotoğraf Düzenleme", apps: appList.editingApps),
      CategoryModel(categoryName: "Bulut Hizmetleri", apps: appList.cloudApps),
    ];
  }
}
