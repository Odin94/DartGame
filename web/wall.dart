part of game;

class Wall {
    num _x, _y, _w, _h;

    Wall(this._x, this._y, this._w, this._h);

    void onDartCollision(Dart dart) {
        // dart is above or below wall
        if (dart._y + dart._r < _y || dart._y > _y + _h) {
            dart._velY = -dart._velY * 0.9;
        }

        //dart is to the right or left of wall
        else if (dart._x < _x || dart._x + dart._r > _x + _w) {
            dart._velX = -dart._velX * 0.9;
        }
    }

    void render(context) {
        context
            ..globalAlpha = 1
            ..fillStyle = "black"
            ..beginPath()
            ..rect(_x, _y, _w, _h)
            ..fill();
    }
}