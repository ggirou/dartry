#library('jug-demo');

#import('dart:io');
#import('dart:isolate');

class StaticFileHandler {
  final String basePath;
  
  StaticFileHandler(this.basePath);
  
  _send404(HttpResponse response) {
    response.statusCode = HttpStatus.NOT_FOUND;
    response.outputStream.close();
  }

  // TODO: etags, last-modified-since support
  onRequest(HttpRequest request, HttpResponse response) {
    final String path = request.path == '/' ? '/index.html' : request.path;
    final File file = new File('${basePath}${path}');
    print("GET - ${file.fullPathSync()}");
    file.exists().then((found) {
      if (found) {
        file.fullPath().then((String fullPath) {
          if (!fullPath.startsWith(basePath)) {
            _send404(response);
          } else {
            file.openInputStream().pipe(response.outputStream);
          }
        });
      } else {
        _send404(response);
      }
    }); 
  }
}

class TickHandler {
  Set<WebSocketConnection> connections;
  int counter = 0;
  Timer timer;

  TickHandler(String basePath) : connections = new Set<WebSocketConnection>() {
    start();
  }

  start() {
    timer = new Timer.repeating(1000, tick);
  }
  
  stop() {
    timer.cancel();
    timer = null;
  }
  
  toggle() {
    timer == null ? start() : stop();
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
      connections.remove(conn); // onClosed isn't being called ??
    };
  }
}

runServer(String basePath, int port) {
  HttpServer server = new HttpServer();
  WebSocketHandler wsHandler = new WebSocketHandler();
  wsHandler.onOpen = new TickHandler(basePath).onOpen;
  
  server.defaultRequestHandler = new StaticFileHandler(basePath).onRequest;
  server.addRequestHandler((req) => req.path == "/ws", wsHandler.onRequest);
  server.onError = (error) => print(error);
  server.listen('127.0.0.1', port);
  print('listening for connections on http://127.0.0.1:$port');
  print("Basepath: $basePath");
}

main() {
  // 14 Septembre 2012 ! :p
  var port = 14912;
  var scriptLocation = new File(new Options().script).directorySync().path;
  var basepath = new Path("$scriptLocation/../client/").canonicalize().toNativePath();
  runServer(basepath, port);
}
