import 'package:flutter/material.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:starter_pack/Features/Mock%20Datas/datas.dart';
import 'package:starter_pack/Features/models/app_model.dart';
import 'package:starter_pack/Features/models/category_model.dart';
import 'package:starter_pack/Features/utils/project_colors.dart';
import 'package:url_launcher/url_launcher.dart';

// ─────────────────────────────────────────────
// Renk sabitleri merkezi bir class'ta toplandı
// ─────────────────────────────────────────────

// ─────────────────────────────────────────────
// Ana view — yalnızca state yönetiminden sorumlu
// ─────────────────────────────────────────────
class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  late final List<CategoryModel> _categories;
  final Map<String, bool> _installedApps = {};

  @override
  void initState() {
    super.initState();
    _categories = Datas().apps();
    _loadInstalledApps();
  }

  Future<void> _loadInstalledApps() async {
    final results = <String, bool>{};

    for (final category in _categories) {
      for (final app in category.apps ?? []) {
        final packageName = app.packageName;
        if (packageName == null) continue;
        results[packageName] = await _isAppInstalled(packageName);
      }
    }

    setState(() => _installedApps.addAll(results));
  }

  Future<bool> _isAppInstalled(String packageName) async {
    return await InstalledApps.isAppInstalled(packageName) ?? false;
  }

  Future<void> _openPlayStore(String packageName) async {
    final nativeUri = Uri.parse('market://details?id=$packageName');
    final webUri = Uri.parse('https://play.google.com/store/apps/details?id=$packageName');

    final launched = await _tryLaunch(nativeUri, LaunchMode.externalNonBrowserApplication);
    if (!launched) {
      await _tryLaunch(webUri, LaunchMode.platformDefault);
    }
  }

  Future<bool> _tryLaunch(Uri uri, LaunchMode mode) async {
    try {
      await launchUrl(uri, mode: mode);
      return true;
    } catch (_) {
      return false;
    }
  }

  void _showAlreadyInstalledMessage(String appName) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '$appName zaten cihazınızda mevcut',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: ProjectColors.onSurface,
            ),
          ),
          backgroundColor: ProjectColors.outlineVariant,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
  }

  void _onInstallTapped(AppModel app) {
    final isInstalled = _installedApps[app.packageName] == true;

    if (isInstalled) {
      _showAlreadyInstalledMessage(app.appName ?? '');
    } else {
      _openPlayStore(app.packageName ?? '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProjectColors.background,
      appBar: _AppBar(),
      body: _AppBody(
        categories: _categories,
        installedApps: _installedApps,
        onInstallTapped: _onInstallTapped,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// AppBar — görsel yapıdan sorumlu, logic içermez
// ─────────────────────────────────────────────
class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: ProjectColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: 20,
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(color: ProjectColors.outlineVariant, height: 1),
      ),
      title: const Row(
        children: [
          Icon(Icons.rocket_launch, color: ProjectColors.primary, size: 24),
          SizedBox(width: 12),
          Text(
            'StarterPack',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: ProjectColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Body — liste iskeletini oluşturur
// ─────────────────────────────────────────────
class _AppBody extends StatelessWidget {
  const _AppBody({
    required this.categories,
    required this.installedApps,
    required this.onInstallTapped,
  });

  final List<CategoryModel> categories;
  final Map<String, bool> installedApps;
  final void Function(AppModel app) onInstallTapped;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 672,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          itemCount: categories.length,
          itemBuilder: (context, index) => _CategorySection(
            category: categories[index],
            installedApps: installedApps,
            onInstallTapped: onInstallTapped,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Kategori bölümü — başlık + uygulama listesi
// ─────────────────────────────────────────────
class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.category,
    required this.installedApps,
    required this.onInstallTapped,
  });

  final CategoryModel category;
  final Map<String, bool> installedApps;
  final void Function(AppModel app) onInstallTapped;

  @override
  Widget build(BuildContext context) {
    final apps = category.apps ?? [];

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category.categoryName ?? '',
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: ProjectColors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          _AppList(apps: apps, installedApps: installedApps, onInstallTapped: onInstallTapped),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Uygulama listesi — kartı çerçeveler
// ─────────────────────────────────────────────
class _AppList extends StatelessWidget {
  const _AppList({required this.apps, required this.installedApps, required this.onInstallTapped});

  final List<AppModel> apps;
  final Map<String, bool> installedApps;
  final void Function(AppModel app) onInstallTapped;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ProjectColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ProjectColors.outlineVariant),
      ),
      child: Column(
        children: List.generate(apps.length, (index) {
          final app = apps[index];
          final isInstalled = installedApps[app.packageName] == true;
          final isLast = index == apps.length - 1;

          return _AppListItem(
            app: app,
            isInstalled: isInstalled,
            isLast: isLast,
            onInstallTapped: () => onInstallTapped(app),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Tek uygulama satırı
// ─────────────────────────────────────────────
class _AppListItem extends StatelessWidget {
  const _AppListItem({
    required this.app,
    required this.isInstalled,
    required this.isLast,
    required this.onInstallTapped,
  });

  final AppModel app;
  final bool isInstalled;
  final bool isLast;
  final VoidCallback onInstallTapped;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _AppIcon(iconUrl: app.iconUrl ?? ''),
              const SizedBox(width: 16),
              Expanded(
                child: _AppInfo(name: app.appName ?? '', description: app.description ?? ''),
              ),
              _AppActionButton(isInstalled: isInstalled, onTap: onInstallTapped),
            ],
          ),
        ),
        if (!isLast)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(color: ProjectColors.outlineVariant, height: 1),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Uygulama ikonu
// ─────────────────────────────────────────────
class _AppIcon extends StatelessWidget {
  const _AppIcon({required this.iconUrl});

  final String iconUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        iconUrl,
        width: 44,
        height: 44,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.apps, color: ProjectColors.onSurfaceVariant, size: 44),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Uygulama adı + açıklaması
// ─────────────────────────────────────────────
class _AppInfo extends StatelessWidget {
  const _AppInfo({required this.name, required this.description});

  final String name;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          name,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: ProjectColors.onSurface,
          ),
        ),
        Text(
          description,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: ProjectColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// İndir / Yüklü ikonu butonu
// ─────────────────────────────────────────────
class _AppActionButton extends StatelessWidget {
  const _AppActionButton({required this.isInstalled, required this.onTap});

  final bool isInstalled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      style: IconButton.styleFrom(minimumSize: const Size(40, 40), padding: EdgeInsets.zero),
      icon: Icon(
        isInstalled ? Icons.check_circle : Icons.download,
        color: isInstalled ? ProjectColors.primary : ProjectColors.onSurfaceVariant,
        size: 24,
      ),
    );
  }
}
