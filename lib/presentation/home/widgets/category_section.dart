import 'package:flutter/material.dart';
import 'package:starter_pack/core/constants/project_colors.dart';
import 'package:starter_pack/data/models/app_model.dart';
import 'package:starter_pack/data/models/category_model.dart';
import 'package:starter_pack/presentation/home/widgets/app_list_item.dart';

class CategorySection extends StatelessWidget {
  final CategoryModel category;
  final Map<String, bool> installedApps;
  final void Function(AppModel) onInstallTapped;

  const CategorySection({
    super.key,
    required this.category,
    required this.installedApps,
    required this.onInstallTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category.categoryName,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: ProjectColors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: ProjectColors.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ProjectColors.outlineVariant),
            ),
            child: Column(
              children: List.generate(category.apps.length, (index) {
                return AppListItem(
                  app: category.apps[index],
                  isInstalled: installedApps[category.apps[index].packageName] == true,
                  isLast: index == category.apps.length - 1,
                  onInstallTapped: () => onInstallTapped(category.apps[index]),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
