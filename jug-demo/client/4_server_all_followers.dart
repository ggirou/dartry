#import('dart:html');
#import('dart:isolate');
#import('../shared/dartry.dart');

WebSocket webSocket;

var buttonIds = const ["counterButton"];

void main() {
  int port = 14912;
  String url = "ws://127.0.0.1:$port/ws";
  
  init(url);
  
  // Register buttons
  buttonIds.forEach((id) => new CounterElement(id));
}

init(String url) {
  webSocket = new WebSocket(url);
  
  webSocket.on.open.add((e) => print("Connected"));
  webSocket.on.close.add((e) => print("Disconnected"));
  webSocket.on.message.add((MessageEvent e) {
    print('Message received: ${e.data}');
    FollowersCount count = new FollowersCount.parse(e.data);
    var counter = new CounterElement(count.id);
    counter.active = true;
    counter.value = count.value.toString();
  });
}

send(FollowersCount message){
  print("Send message: $message");
  webSocket.send(message.toString());
}

class CounterElement {
  static Map<String, CounterElement> _instances;
  static List<String> _activeStyles = const ["btn-inverse", "btn-info"];

  Element button;
  
  factory CounterElement(String id) {
    if(_instances == null) {
      _instances = new Map();
    }
    
    _instances.putIfAbsent(id, () => new CounterElement._internal(query("#$id")));
    return _instances[id];
  }

  CounterElement._internal(this.button) {
    button.on.click.add((e) => toggle());
  }
  
  toggle() {
    active = !active;
    send(new FollowersCount(id, active));
  }

  get id => button.id;
  
  get counter => button.query("#counter"); 
  set value(String value) => counter.innerHTML = value;
  
  get active => button.classes.contains(_activeStyles[1]);
  set active(bool _active) {
    button.classes
      ..removeAll(_activeStyles)
      ..add(_activeStyles[_active ? 1 : 0]);
  }
}
