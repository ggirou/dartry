#library('jug-demo');

#import('dart:io');
#import('dart:isolate');

class TickHandler {
  int counter = 0;
  Timer timer;

  TickHandler() {
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
    // TODO send something
  }
}

main() {
  // 14 Septembre 2012 ! :p
  var port = 14912;

  HttpServer server = new HttpServer();
  server.onError = (error) => print(error);
  
  // TODO set an handler
  
  server.listen('127.0.0.1', port);
  print('listening for connections on http://127.0.0.1:$port');
}