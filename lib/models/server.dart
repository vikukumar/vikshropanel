class Server {
  final String id;
  final String name;
  final String baseUrl;

  Server({
    required this.id,
    required this.name,
    required this.baseUrl,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'baseUrl': baseUrl,
      };

  static Server fromJson(Map<String, dynamic> j) => Server(
        id: j['id'] as String,
        name: j['name'] as String,
        baseUrl: j['baseUrl'] as String,
      );
}
