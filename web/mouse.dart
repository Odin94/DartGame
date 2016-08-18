part of game;

enum MouseKey {
    down,
    up
}

class Mouse {
    final mouseEvents = new List();

    num mouseX = 0;
    num mouseY = 0;

    Mouse() {
        window.onMouseDown.listen((final MouseEvent e) {
            mouseEvents.add(MouseKey.down);
        });
        window.onMouseUp.listen((final MouseEvent e) {
            mouseEvents.add(MouseKey.up);
        });

        window.onMouseMove.listen((final MouseEvent e) {
            mouseX = e.offset.x;
            mouseY = e.offset.y;
        });
    }
}