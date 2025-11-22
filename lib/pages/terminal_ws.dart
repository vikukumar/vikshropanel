import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:vikshro_panel/services/api_client.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:crypto/crypto.dart';
import '../models/server.dart';
//import '../services/server_store.dart';
//import 'package:provider/provider.dart';

class WebSshTerminalPage extends StatefulWidget {
  final Server server;
  final ApiClient? client;
  const WebSshTerminalPage({required this.server, required this.client});

  @override
  State<WebSshTerminalPage> createState() => _WebSshTerminalPageState();
}

class _WebSshTerminalPageState extends State<WebSshTerminalPage> {
  WebSocketChannel? channel;
  ApiClient? client;
  final List<String> lines = [];
  final ScrollController scroll = ScrollController();
  final TextEditingController input = TextEditingController();
  bool connecting = true;
  String status = 'Connecting...';

  @override
  void initState() {
    super.initState();
    client = widget.client;
    _connect();
  }

  String md5hex(String s) => md5.convert(utf8.encode(s)).toString();

  Future<void> _connect() async {
    //final store = Provider.of<ServerStore>(context, listen: false);
    //final apiKey = await store.getApiKey(widget.server.id) ?? '';
    //final time = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
    //final token = md5hex(time + md5hex(apiKey));
    final info = await client?.getPanelConfig();
    debugPrint(info.toString());
    var ws = widget.server.baseUrl
        .replaceFirst('https://', 'wss://')
        .replaceFirst('http://', 'ws://');
    if (ws.endsWith('/')) ws = ws.substring(0, ws.length - 1);
    ws = '$ws/v2/webssh';
    setState(() {
      connecting = true;
      status = 'Connecting...';
      lines.add('Connecting...');
    });

    try {
      channel = WebSocketChannel.connect(Uri.parse(ws));
      channel!.stream.listen((event) {
        try {
          final msg = jsonDecode(event);
          if (msg is Map && msg['type'] == 'stdout') {
            _append(msg['data']?.toString() ?? '');
          } else if (msg is Map && msg['type'] == 'error') {
            _append('[ERROR] ${msg['data']}');
          } else {
            _append(event.toString());
          }
        } catch (e) {
          _append(event.toString());
        }
      }, onDone: () {
        _append('*** Disconnected ***');
        setState(() {
          connecting = false;
          status = 'Disconnected';
        });
      }, onError: (e) {
        _append('[WebSocket Error] $e');
        setState(() {
          connecting = false;
          status = 'Error';
        });
      });

      setState(() {
        connecting = false;
        status = 'Connected';
      });
      _append('Connected.');
    } catch (e) {
      _append('Connection failed: $e');
      setState(() {
        connecting = false;
        status = 'Failed';
      });
    }
  }

  void _append(String s) {
    final parts = s.split('\n');
    for (var p in parts) lines.add(p + '\n');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scroll.hasClients) {
        scroll.jumpTo(scroll.position.maxScrollExtent);
      }
      setState(() {});
    });
  }

  void _send() {
    final text = input.text;
    if (text.isEmpty) return;
    channel?.sink.add(jsonEncode({'type': 'stdin', 'data': text + '\n'}));
    input.clear();
  }

  @override
  void dispose() {
    channel?.sink.close();
    scroll.dispose();
    input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terminal - ${widget.server.name}'),
        actions: [
          Center(
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(status)))
        ],
      ),
      body: Column(
        children: [
          if (connecting) LinearProgressIndicator(minHeight: 3),
          Expanded(
            child: Container(
              color: Colors.black,
              child: ListView.builder(
                controller: scroll,
                padding: EdgeInsets.all(8),
                itemCount: lines.length,
                itemBuilder: (_, i) => Text(lines[i],
                    style: TextStyle(
                        color: Colors.greenAccent, fontFamily: 'monospace')),
              ),
            ),
          ),
          Container(
            color: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                Expanded(
                    child: TextField(
                        controller: input,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration.collapsed(
                            hintText: 'Command',
                            hintStyle: TextStyle(color: Colors.white54)))),
                IconButton(
                    onPressed: _send,
                    icon: Icon(Icons.send, color: Colors.white)),
              ],
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.replay),
          onPressed: () {
            channel?.sink.close();
            lines.clear();
            _connect();
          }),
    );
  }
}
