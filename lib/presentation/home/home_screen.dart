import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:starter_pack/core/constants/project_colors.dart';
import 'package:starter_pack/data/models/app_model.dart';
import 'package:starter_pack/data/models/category_model.dart';
import 'package:starter_pack/data/remote/service.dart';
import 'package:starter_pack/presentation/home/widgets/category_section.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<CategoryModel> _categories = [];
  List<CategoryModel> _filteredCategories = [];
  late final Service _service;
  bool _isLoading = false;
  bool _isSearching = false;

  final TextEditingController _searchController = TextEditingController();
  final Map<String, bool> _installedApps = {};

  @override
  void initState() {
    super.initState();
    _service = Service();
    _initializeData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _fetchItems();
    await _loadInstalledApps();
  }

  void _changeLoading() => setState(() => _isLoading = !_isLoading);

  Future<void> _fetchItems() async {
    _changeLoading();
    try {
      _categories = await _service.fetchEverything();
      _filteredCategories = List.from(_categories);
      if (mounted) {
        for (final category in _categories) {
          for (final app in category.apps) {
            if (app.iconUrl.isNotEmpty) {
              precacheImage(CachedNetworkImageProvider(app.iconUrl), context);
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Veri çekme hatası: $e');
    }
    _changeLoading();
  }

  void _filterApps(String query) {
    if (query.isEmpty) {
      setState(() => _filteredCategories = List.from(_categories));
      return;
    }
    final q = query.toLowerCase();
    setState(() {
      _filteredCategories = _categories
          .map((cat) {
            final matched = cat.apps.where((app) => app.appName.toLowerCase().contains(q)).toList();
            if (matched.isEmpty && !cat.categoryName.toLowerCase().contains(q)) {
              return null;
            }
            return CategoryModel(
              categoryName: cat.categoryName,
              apps: matched.isNotEmpty ? matched : cat.apps,
            );
          })
          .whereType<CategoryModel>()
          .toList();
    });
  }

  void _clearSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      _filteredCategories = List.from(_categories);
    });
  }

  Future<void> _loadInstalledApps() async {
    final results = <String, bool>{};
    for (final category in _categories) {
      for (final app in category.apps) {
        if (app.packageName.isEmpty) continue;
        results[app.packageName] = await _isAppInstalled(app.packageName);
      }
    }
    if (mounted) setState(() => _installedApps.addAll(results));
  }

  Future<bool> _isAppInstalled(String packageName) async {
    try {
      return await InstalledApps.isAppInstalled(packageName) ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> _onInstallTapped(AppModel app) async {
    if (_installedApps[app.packageName] == true) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text(
              '${app.appName} zaten cihazınızda mevcut',
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
      return;
    }
    final nativeUri = Uri.parse('market://details?id=${app.packageName}');
    final webUri = Uri.parse('https://play.google.com/store/apps/details?id=${app.packageName}');
    try {
      await launchUrl(nativeUri, mode: LaunchMode.externalNonBrowserApplication);
    } catch (_) {
      await launchUrl(webUri, mode: LaunchMode.platformDefault);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProjectColors.background,
      appBar: AppBar(
        backgroundColor: ProjectColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: _isSearching ? 8 : 20,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(color: ProjectColors.outlineVariant, height: 1),
        ),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: _filterApps,
                style: const TextStyle(
                  color: ProjectColors.onSurface,
                  fontFamily: 'Inter',
                  fontSize: 18,
                ),
                decoration: InputDecoration(
                  hintText: 'Uygulama veya kategori ara...',
                  hintStyle: const TextStyle(color: ProjectColors.onSurfaceVariant),
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.search, color: ProjectColors.primary),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close, color: ProjectColors.onSurfaceVariant),
                    onPressed: _clearSearch,
                  ),
                ),
              )
            : const Row(
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
        actions: _isSearching
            ? null
            : [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: IconButton(
                    onPressed: () => setState(() => _isSearching = true),
                    icon: const Icon(Icons.search, color: ProjectColors.onSurfaceVariant, size: 26),
                  ),
                ),
              ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: ProjectColors.primary))
          : _filteredCategories.isEmpty
          ? const Center(
              child: Text(
                'Datalar gelmedi!',
                style: TextStyle(color: ProjectColors.onSurface, fontSize: 16, fontFamily: 'Inter'),
              ),
            )
          : Center(
              child: SizedBox(
                width: 672,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  itemCount: _filteredCategories.length,
                  itemBuilder: (context, index) => CategorySection(
                    category: _filteredCategories[index],
                    installedApps: _installedApps,
                    onInstallTapped: _onInstallTapped,
                  ),
                ),
              ),
            ),
    );
  }
}
