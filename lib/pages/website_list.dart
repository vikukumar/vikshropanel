import 'package:flutter/material.dart';
import 'package:vikshro_panel/services/api_client.dart';
import '../models/website.dart';

class WebsiteListPage extends StatefulWidget {
  final ApiClient? client;

  const WebsiteListPage({
    required this.client,
  });

  @override
  _WebsiteListPageState createState() => _WebsiteListPageState();
}

class _WebsiteListPageState extends State<WebsiteListPage> {
  late ApiClient? api;
  List<WebsiteModel> websites = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    api = widget.client;
    loadList();
  }

  Future<void> loadList() async {
    final list = await api?.getWebsiteLists();
    websites = list?["data"].map((e) => WebsiteModel.fromJson(e)).toList();
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Website Management"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: const [
          Icon(Icons.search, size: 26),
          SizedBox(width: 12),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: websites.length,
              itemBuilder: (context, index) {
                return buildSiteCard(websites[index]);
              },
            ),
    );
  }

  Widget buildSiteCard(WebsiteModel w) {
    final running = w.status == 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 5,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TITLE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                w.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              const Icon(Icons.more_vert)
            ],
          ),

          const SizedBox(height: 8),

          // DIRECTORY
          Text("Website Directory:",
              style: TextStyle(color: Colors.grey.shade700)),

          InkWell(
            onTap: () {},
            child: Text(
              w.path,
              style: const TextStyle(
                color: Colors.green,
                fontSize: 15,
                decoration: TextDecoration.underline,
              ),
            ),
          ),

          const SizedBox(height: 4),

          // REMARK
          Text(
            "Remark:  ${w.remark}",
            style: TextStyle(color: Colors.grey.shade600),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              // STATUS BADGE
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: running ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Icon(
                      running ? Icons.play_circle : Icons.stop_circle,
                      size: 16,
                      color: running ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      running ? "Running" : "Stopped",
                      style:
                          TextStyle(color: running ? Colors.green : Colors.red),
                    )
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // SSL EXPIRATION
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_clock, color: Colors.green, size: 16),
                    const SizedBox(width: 6),
                    Text("Expires: ${w.expiration}"),
                  ],
                ),
              ),

              const Spacer(),

              InkWell(
                child: Text(
                  "Details >",
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                onTap: () {},
              )
            ],
          )
        ],
      ),
    );
  }
}
