class AppModel {
  final String appName;
  final String description;
  final String packageName;
  final String iconUrl;
  final String url;

  AppModel({
    required this.appName,
    required this.description,
    required this.packageName,
    required this.iconUrl,
    required this.url,
  });

  factory AppModel.fromJson(Map<String, dynamic> json) {
    return AppModel(
      appName: json['appName'],
      description: json['description'],
      packageName: json['packageName'],
      iconUrl: json['iconUrl'],
      url: json['url'],
    );
  }
}
