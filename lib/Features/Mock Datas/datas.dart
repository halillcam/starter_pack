import 'package:starter_pack/Features/models/app_model.dart';
import 'package:starter_pack/features/models/category_model.dart';

class Datas {
  List<CategoryModel> apps() {
    return [
      CategoryModel(
        categoryName: "Sosyal Medya",
        apps: [
          AppModel(
            appName: "Instagram",
            description: "Sosyal Medya Uygulaması",
            packageName: "com.instagram.android",
            iconUrl: "https://upload.wikimedia.org/wikipedia/commons/5/58/Instagram-Icon.png",
            url: "https://play.google.com/store/apps/details?id=com.instagram.android",
          ),
          AppModel(
            appName: "WhatsApp",
            description: "Mesajlaşma Uygulaması",
            packageName: "com.whatsapp",
            iconUrl:
                "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4c/WhatsApp_Logo_green.svg/960px-WhatsApp_Logo_green.svg.png",
            url: "https://play.google.com/store/apps/details?id=com.whatsapp",
          ),
        ],
      ),
    ];
  }
}
