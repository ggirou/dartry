
#import('dart:html');
#import('dart:isolate');

List<String> activeStyles = const ["btn-inverse", "btn-info"];

WebSocket webSocket;

void main() {
  int port = 14912;
  String url = "ws://127.0.0.1:$port/ws";
  
  init(url);
  counterButton.on.click.add((e) => toggle());
}

init(String url) {
  webSocket = new WebSocket(url);
  
  webSocket.on.open.add((e) => print("Connected"));
  webSocket.on.close.add((e) => print("Disconnected"));
  webSocket.on.message.add((MessageEvent e) {
    print('Message received: ${e.data}');
    counterActive = true;
    showCount(e.data);
  });
}

toggle() {
  counterActive = !counterActive;
  send("That's all folks! ($counterActive)");
}

send(String message){
  print("Send message: $message");
  webSocket.send(message);
}

showCount(String value) => counter.innerHTML = value;

Element get counter() => query("#counter"); 
Element get counterButton() => query("#counterButton"); 

get counterActive() => counterButton.classes.contains(activeStyles[1]);
set counterActive(bool _active) {
  counterButton.classes.removeAll(activeStyles);
  counterButton.classes.add(activeStyles[_active ? 1 : 0]);
}