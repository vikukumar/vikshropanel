import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/server_store.dart';
import 'pages/server_list.dart';
import 'pages/add_server.dart'
    show AddServerPage; // small add server page below
import 'pages/dashboard.dart';
import 'pages/files_page.dart';
import 'pages/terminal_ws.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = ServerStore();
  await store.init();
  runApp(MyApp(store: store));
}

class MyApp extends StatelessWidget {
  final ServerStore store;
  const MyApp({required this.store, super.key});

  @override
  Widget build(BuildContext context) {
    return Provider<ServerStore>.value(
      value: store,
      child: MaterialApp(
        title: 'VIKSHRO Panel',
        theme: ThemeData(
          primarySwatch: Colors.green,
          scaffoldBackgroundColor: const Color(0xFFF6F7F8),
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (_) => ServerListPage(),
          '/add': (_) => AddServerPage(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/dashboard') {
            final server = settings.arguments as dynamic;
            return MaterialPageRoute(
                builder: (_) => DashboardPage(server: server));
          }
          if (settings.name == '/files') {
            final server = settings.arguments as dynamic;
            return MaterialPageRoute(builder: (_) => FilesPage(server: server));
          }
          if (settings.name == '/terminal') {
            final server = settings.arguments as dynamic;
            return MaterialPageRoute(
                builder: (_) =>
                    WebSshTerminalPage(server: server[0], client: server[1]));
          }
          return null;
        },
      ),
    );
  }
}
