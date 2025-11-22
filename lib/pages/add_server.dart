import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/server_store.dart';

class AddServerPage extends StatefulWidget {
  @override
  State<AddServerPage> createState() => _AddServerPageState();
}

class _AddServerPageState extends State<AddServerPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _url = TextEditingController();
  final _key = TextEditingController();
  bool saving = false;

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<ServerStore>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: Text('Add Server')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
                controller: _name,
                decoration: InputDecoration(labelText: 'Server name')),
            TextFormField(
                controller: _url,
                decoration:
                    InputDecoration(labelText: 'Base URL (https://...)'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Enter URL' : null),
            TextFormField(
                controller: _key,
                decoration: InputDecoration(labelText: 'API Key (api_sk)'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Enter API key' : null),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: saving
                  ? CircularProgressIndicator(color: Colors.white)
                  : Icon(Icons.save),
              label: Text('Save'),
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;
                setState(() => saving = true);
                await store.addServer(
                    name: _name.text.trim(),
                    baseUrl: _url.text.trim(),
                    apiKey: _key.text.trim());
                setState(() => saving = false);
                Navigator.pop(context);
              },
            )
          ]),
        ),
      ),
    );
  }
}
