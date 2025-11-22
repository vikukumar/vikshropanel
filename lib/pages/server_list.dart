import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/server_store.dart';
import '../models/server.dart';
import '../widgets/gauge.dart';

class ServerListPage extends StatefulWidget {
  @override
  State<ServerListPage> createState() => _ServerListPageState();
}

class _ServerListPageState extends State<ServerListPage> {
  List<Server> servers = [];
  bool loading = true;

  Future<void> load() async {
    setState(() => loading = true);
    final store = Provider.of<ServerStore>(context, listen: false);
    servers = await store.getServers();
    await Future.delayed(const Duration(milliseconds: 200));
    setState(() => loading = false);
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  Widget serverCard(Server s) {
    // fake values initially; real values come from API in dashboard
    final cpu = 0.09;
    final mem = 0.64;
    final disk = 0.57;
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/dashboard', arguments: s)
          .then((_) => load()),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
            ]),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white,
                      child:
                          Icon(Icons.storage, color: Colors.green, size: 32)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 6),
                      Row(children: [
                        Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(8)),
                            child: Text("2 Day(s)",
                                style: TextStyle(color: Colors.green[800]))),
                        const SizedBox(width: 8),
                        Text("IP: ${s.baseUrl}",
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 12),
                            overflow: TextOverflow.ellipsis),
                      ])
                    ],
                  )),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 4)
                        ]),
                    child: Icon(Icons.swap_vert, color: Colors.grey),
                  )
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
                    child: Column(
                      children: [
                        SimpleGauge(
                            value: cpu,
                            label: 'CPU',
                            subtitle: '1 Core',
                            color: Colors.teal),
                        const SizedBox(height: 8),
                        SimpleGauge(
                            value: mem,
                            label: 'Memory',
                            subtitle: '908 MB',
                            color: Colors.orange),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.green,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.storage), label: 'Servers'),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'Files'),
          BottomNavigationBarItem(
              icon: Icon(Icons.security), label: 'Authenticator'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEFF7F5),
        elevation: 0,
        title: Row(children: [
          Image.asset('assets/aa_logo.png',
              width: 40,
              height: 40,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.cloud, color: Colors.green)),
          const SizedBox(width: 8),
          Expanded(
              child: TextField(
                  decoration: InputDecoration(
                      hintText: 'Search Server or IP',
                      border: InputBorder.none))),
          IconButton(
              onPressed: () =>
                  Navigator.pushNamed(context, '/add').then((_) => load()),
              icon: Icon(Icons.add)),
        ]),
      ),
      body: RefreshIndicator(
        onRefresh: load,
        child: loading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: servers.length,
                itemBuilder: (_, i) => serverCard(servers[i]),
              ),
      ),
    );
  }
}
