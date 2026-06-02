import 'package:flutter/material.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:starter_pack/Features/Mock%20Datas/datas.dart';
import 'package:starter_pack/Features/models/category_model.dart';
import 'package:url_launcher/url_launcher.dart';

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  late Datas datas;
  late final List<CategoryModel> categories;
  final Map<String, bool> installedApps = {};

  @override
  void initState() {
    super.initState();
    datas = Datas();
    categories = datas.apps();
    loadInstalledApps();
  }

  Future<void> loadInstalledApps() async {
    for (final category in categories) {
      for (final app in category.apps!) {
        final installed = await checkApp(app.packageName!);

        installedApps[app.packageName!] = installed ?? false;
      }
    }

    setState(() {});
  }

  Future<bool?> checkApp(String packageName) async {
    return await InstalledApps.isAppInstalled(packageName);
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
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey.shade100,
                    child: ClipOval(
                      child: Image.network(
                        app.iconUrl!,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.apps, size: 20),
                        loadingBuilder: (_, child, progress) {
                          if (progress == null) return child;
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  title: Text(app.appName!),
                  subtitle: Text(app.description!),
                  trailing: IconButton(
                    onPressed: () {
                      if (installedApps[app.packageName!] == true) {
                        return;
                      }

                      openStore(app.url!);
                    },
                    icon: Icon(
                      installedApps[app.packageName!] == true ? Icons.check_circle : Icons.download,
                    ),
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
