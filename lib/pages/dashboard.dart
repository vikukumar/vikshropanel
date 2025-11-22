import 'dart:async';
import 'package:flutter/material.dart';
import '../models/server.dart';
import '../services/server_store.dart';
import '../services/api_client.dart';
import 'package:provider/provider.dart';
import '../widgets/gauge.dart';
import '../pages/website_list.dart';

class DashboardPage extends StatefulWidget {
  final Server server;
  DashboardPage({required this.server});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  ApiClient? client;
  Map<String, dynamic>? system;
  Map<String, dynamic>? network;
  Timer? timer;
  bool loading = true;
  String? apiKey;

  @override
  void initState() {
    super.initState();
    _initClient().then((_) => _load());
    timer = Timer.periodic(const Duration(seconds: 20), (_) => _load());
  }

  Future<void> _initClient() async {
    final store = Provider.of<ServerStore>(context, listen: false);
    final key = await store.getApiKey(widget.server.id);
    client = ApiClient(baseUrl: widget.server.baseUrl, apiKey: key ?? '');
    apiKey = key;
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final s = await client!.getSystemTotal();
      final n = await client!.getNetWork();
      setState(() {
        system = s;
        network = n;
        loading = false;
      });
    } catch (e) {
      setState(() {
        system = {'error': e.toString()};
        loading = false;
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Widget functionGrid() {
    final icons = [
      Icons.public,
      Icons.storage,
      Icons.security,
      Icons.code,
      Icons.show_chart,
      Icons.vpn_key,
      Icons.folder,
      Icons.schedule,
      Icons.dock,
      Icons.article,
      Icons.settings
    ];
    final labels = [
      'Website',
      'Databases',
      'Firewall',
      'Terminal',
      'Monitor',
      'SSH',
      'Files',
      'Cron',
      'Docker',
      'Log',
      'Settings'
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: icons.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, mainAxisExtent: 92),
        itemBuilder: (context, i) {
          return GestureDetector(
            onTap: () {
              if (labels[i] == 'Website') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WebsiteListPage(
                      serverUrl: widget.server.baseUrl,
                      apiKey: apiKey ?? '',
                    ),
                  ),
                );
              }
              if (labels[i] == 'Files')
                Navigator.pushNamed(context, '/files',
                    arguments: widget.server);
              if (labels[i] == 'Terminal')
                Navigator.pushNamed(context, '/terminal',
                    arguments: widget.server);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey[100],
                    child: Icon(icons[i], color: Colors.green)),
                const SizedBox(height: 8),
                Text(labels[i],
                    style: const TextStyle(fontSize: 12),
                    textAlign: TextAlign.center),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cpuPercent = (system != null && system!['cpuRealUsed'] != null)
        ? (double.tryParse(system!['cpuRealUsed'].toString()) ?? 0) / 100.0
        : 0.05;
    final memPercent = (system != null &&
            system!['memRealUsed'] != null &&
            system!['memTotal'] != null)
        ? (double.tryParse(system!['memRealUsed'].toString())! /
            double.tryParse(system!['memTotal'].toString())!)
        : 0.45;
    final diskPercent = 0.56;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.server.name),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)]),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                          radius: 34,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.storage,
                              size: 40, color: Colors.green)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.server.name,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text(widget.server.baseUrl,
                              style: const TextStyle(color: Colors.grey)),
                        ],
                      )),
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(8)),
                          child: const Text("Running 2 Day(s)",
                              style: TextStyle(color: Colors.green)))
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                          child: SimpleGauge(
                              value: 0.07,
                              label: 'Load',
                              subtitle: 'Fluent',
                              color: Colors.green)),
                      const SizedBox(width: 8),
                      Expanded(
                          child: SimpleGauge(
                              value: cpuPercent,
                              label: 'CPU',
                              subtitle: 'Cores',
                              color: Colors.teal)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SimpleGauge(
                      value: memPercent,
                      label: 'Memory',
                      subtitle:
                          '${(memPercent * 100).toStringAsFixed(0)}% used',
                      color: Colors.orange),
                  const SizedBox(height: 8),
                  SimpleGauge(
                      value: diskPercent,
                      label: 'Disk (/)',
                      subtitle: '19.2G',
                      color: Colors.lime),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text("Function",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            functionGrid(),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(14)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Plugins",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  Text("Site Monitor   Nginx WAF",
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(14)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Environment",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text("Ubuntu 22", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
