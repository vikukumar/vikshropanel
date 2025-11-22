import 'package:flutter/material.dart';
import '../models/server.dart';
import '../services/server_store.dart';
import '../services/api_client.dart';
import 'package:provider/provider.dart';

class FilesPage extends StatefulWidget {
  final Server server;
  FilesPage({required this.server});

  @override
  State<FilesPage> createState() => _FilesPageState();
}

class _FilesPageState extends State<FilesPage> {
  final _path = TextEditingController(text: '/www');
  final _editor = TextEditingController();
  bool loading = false;
  bool saving = false;
  ApiClient? client;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final key = await Provider.of<ServerStore>(context, listen: false)
        .getApiKey(widget.server.id);
    client = ApiClient(baseUrl: widget.server.baseUrl, apiKey: key ?? '');
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final r = await client!.getFileBody(_path.text.trim());
      setState(() => _editor.text = r['data']?.toString() ?? r.toString());
    } catch (e) {
      setState(() => _editor.text = 'Error: $e');
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _save() async {
    setState(() => saving = true);
    try {
      final r = await client!.saveFileBody(_path.text.trim(), _editor.text);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Saved')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Save error: $e')));
    } finally {
      setState(() => saving = false);
    }
  }

  @override
  void dispose() {
    _path.dispose();
    _editor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Files'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          TextField(
              controller: _path,
              decoration: InputDecoration(labelText: 'Path')),
          const SizedBox(height: 8),
          Row(children: [
            ElevatedButton(
                onPressed: _load,
                child: loading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Open')),
            const SizedBox(width: 8),
            ElevatedButton(
                onPressed: _save,
                child: saving
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Save')),
          ]),
          const SizedBox(height: 12),
          Expanded(
              child: TextFormField(
                  controller: _editor,
                  maxLines: null,
                  expands: true,
                  decoration: InputDecoration(border: OutlineInputBorder()))),
        ]),
      ),
    );
  }
}
