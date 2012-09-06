#import('dart:html');
#import('dart:isolate');

List<String> activeStyles = const ["btn-inverse", "btn-info"];
int count = 0;

Timer timer;

void main() {
  start();
  counterButton.on.click.add((e) => toggle());
}

start() {
  timer = new Timer.repeating(1000, tick);
  counterActive = true;
}

stop() {
  timer.cancel();
  timer = null;
  counterActive = false;
}

toggle() {
  timer == null ? start() : stop();
}

void tick(var _timer) {
  showCount((count++).toString());
}

showCount(String value) => counter.innerHTML = value;

Element get counter => query("#counter"); 
Element get counterButton => query("#counterButton"); 

set counterActive(bool _active) {
  counterButton.classes..removeAll(activeStyles)
                       ..add(activeStyles[_active ? 1 : 0]);
}