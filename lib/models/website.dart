class WebsiteModel {
  final int id;
  final String name;
  final String path;
  final String remark;
  final int status;
  final String expiration;

  WebsiteModel({
    required this.id,
    required this.name,
    required this.path,
    required this.remark,
    required this.status,
    required this.expiration,
  });

  factory WebsiteModel.fromJson(Map data) {
    return WebsiteModel(
      id: data["id"],
      name: data["name"],
      path: data["path"],
      remark: data["ps"],
      status: data["status"], // 1 = running, 0 = stopped
      expiration: data["endtime"], // Example: "2025-12-20"
    );
  }
}
