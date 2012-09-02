#library('jug-demo');

#import('dart:io');
#import('dart:isolate');
#import('package:who_listen_me/who_listen_me.dart');
#import('../shared/dartry.dart');

class TickHandler {
  Set<WebSocketConnection> connections;
  Timer timer;
  CirclesApi circles = new CirclesApi();
  CirclesRequest request;

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
    request = circles.whoCircleMe('115816334172157652403');
    request..onError = ((error) => print(error))
        ..onResponse = ((response) => send(new CounterData("counterButton", response.totalCirclers)));
  }
  
  send(CounterData message) {
    if(isRunning) {
      print("Send message: $message");
      connections.forEach((WebSocketConnection connection) => connection.send(message.toString()));
    }
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
      connections.remove(conn); // onClosed isn't being called ??
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
