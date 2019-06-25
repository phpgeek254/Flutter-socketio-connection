import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:adhara_socket_io/adhara_socket_io.dart';

void main() => runApp(MainApp());

class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Socket.io Test',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Init the soscket manager.
  final String URI = "http://localhost:2020/";
  List<String> toPrint = ["trying to conenct"];
  SocketIOManager socketIOManager;
  SocketIO socket;

  bool isConnected = false;

  Future<void> initSocketConnection() async {
    print("Initializing the socket connection");
    try {
      socket = await socketIOManager.createInstance(
        URI,
        query: {
          'auth': 'Maunda Alex',
          'info': 'connection from maunda alex iphone',
          'timestamp': DateTime.now().toString()
        },
        enableLogging: true,
      );
      print("Initilaizing the manager");
    } catch (error) {
      throw error;
    }

    // Event listening.
    socket.onConnect((data) {
      setState(() => isConnected = true);
      print("Socket io On Connection Method");
    });
    // On error with the connection.
    socket.onConnectError((error) {
      print("Connection Error Occured");
      print(error.toString());
    });

    // Timeout handler
    socket.onConnectTimeout((data) {
      print("Connection Error Timed Out");
    });

    //Error Hander
    socket.onError((data) {
      pprint("Connection Error onError");
      pprint(data);
    });

    //Disconnection handler
    socket.onDisconnect((_){
      setState(() {
        isConnected = false;
      });
      print("Socket disconected");
      });

    socket.on('message', (data) {
      pprint(data);
    });

    // Client related events on the socket connection.
    try {
      socket.connect();
      print("Establishing Connection");
    } catch (error) {
      print("Error during connection");
    }
  }

  // Disconnection handler
  Future<void> disconnectSocket() async {
    try {
      await socketIOManager.clearInstance(socket);
      print("Initilaizing the manager");
    } catch (error) {
      throw error;
    }

    setState(() {
      isConnected = false;
    });
  }

  pprint(data) {
    setState(() {
      if (data is Map) {
        data = json.encode(data);
      }
      print(data);
      toPrint.add(data);
    });
  }

  @override
  void initState() {
    super.initState();
    socketIOManager = new SocketIOManager();
    initSocketConnection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Socket.IO App"),
      ),
      body: Container(
        child: Center(
          child: Text(
            "Socket.IO Testing. \n ${isConnected ? 'Socket connection Active' : 'Socket connection inactive'}",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
        ),
      ),
    );
  }
}
