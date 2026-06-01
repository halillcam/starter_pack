import 'package:installed_apps/installed_apps.dart';

class AppService {
  Future<bool> isInstalled(String packageName) async {
    return await InstalledApps.isAppInstalled(packageName) ?? false;
  }
}
