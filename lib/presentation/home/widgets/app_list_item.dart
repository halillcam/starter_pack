import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:starter_pack/core/constants/project_colors.dart';
import 'package:starter_pack/data/models/app_model.dart';

class AppListItem extends StatelessWidget {
  final AppModel app;
  final bool isInstalled;
  final VoidCallback onInstallTapped;
  final bool isLast;

  const AppListItem({
    super.key,
    required this.app,
    required this.isInstalled,
    required this.onInstallTapped,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: app.iconUrl,
                  width: 44,
                  height: 44,
                  fit: BoxFit.contain,
                  placeholder: (context, url) =>
                      Container(width: 44, height: 44, color: ProjectColors.surfaceContainer),

                  errorWidget: (context, url, error) {
                    // Konsola (Debug Console) uygulamanın adını, URL'ini ve tam hatayı basar.
                    debugPrint(' GÖRSEL YÜKLENEMEDİ (${app.appName}):');
                    debugPrint('URL: $url');
                    debugPrint('Hata Detayı: $error');
                    debugPrint('-----------------------------------------');

                    return const Icon(Icons.apps, color: ProjectColors.onSurfaceVariant, size: 44);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.appName,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: ProjectColors.onSurface,
                      ),
                    ),
                    Text(
                      app.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: ProjectColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onInstallTapped,
                style: IconButton.styleFrom(
                  minimumSize: const Size(40, 40),
                  padding: EdgeInsets.zero,
                ),
                icon: Icon(
                  isInstalled ? Icons.check_circle : Icons.download,
                  color: isInstalled ? ProjectColors.primary : ProjectColors.onSurfaceVariant,
                  size: 24,
                ),
              ),
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
