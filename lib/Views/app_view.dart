import 'package:flutter/material.dart';
import 'package:starter_pack/features/Mock%20Datas/datas.dart';
import 'package:starter_pack/features/models/category_model.dart';
import 'package:url_launcher/url_launcher.dart';

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  late Datas datas;
  late final List<CategoryModel> categories;

  @override
  void initState() {
    super.initState();
    datas = Datas();
    categories = datas.apps();
  }

  Future<void> openStore(String url) async {
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw Exception("Açılamadı");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("StarterPack")),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category.categoryName!,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              ...category.apps!.map(
                (app) => ListTile(
                  leading: Image.network(app.iconUrl!, width: 40, height: 40),
                  title: Text(app.appName!),
                  subtitle: Text(app.description!),
                  trailing: IconButton(
                    onPressed: () {
                      openStore(app.url!);
                    },
                    icon: Icon(Icons.download),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
