#library('jug-demo');

#import('dart:io');
#import('dart:isolate');

class TickHandler {
  Set<WebSocketConnection> connections;
  int counter = 0;
  Timer timer;

  TickHandler() : connections = new Set<WebSocketConnection>() {
    start();
  }

  bool get isRunning => timer != null;

  start() {
    timer = new Timer.repeating(1000, tick);
  }
  
  stop() {
    timer.cancel();
    timer = null;
  }
  
  toggle() {
    isRunning ? stop() : start();
  }
  
  tick(var _timer) {
    send((counter++).toString());
  }
  
  send(String message) {
    print("Send message: $message");
    connections.forEach((WebSocketConnection connection) => connection.send(message));
  }
  
  // closures!
  onOpen(WebSocketConnection conn) {
    print('New WebSocket connection');
    connections.add(conn);
    
    conn.onClosed = (int status, String reason) {
      print('Connection is closed');
      connections.remove(conn);
    };
    
    conn.onMessage = (message) {
      print('Message received: $message');
      toggle();
    };
    
    conn.onError = (e) {
      print("Connection error");
      connections.remove(conn);
    };
  }
}

main() {
  // 14 Septembre 2012 ! :p
  var port = 14912;

  HttpServer server = new HttpServer();
  
  WebSocketHandler wsHandler = new WebSocketHandler();
  wsHandler.onOpen = new TickHandler().onOpen;
  server.defaultRequestHandler = wsHandler.onRequest;
  
  server.onError = (error) => print(error);
  server.listen('127.0.0.1', port);
  print('listening for connections on http://127.0.0.1:$port');
}
