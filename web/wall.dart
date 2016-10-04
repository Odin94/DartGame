part of game;

class Wall {
    num _x, _y, _w, _h;

    Wall(this._x, this._y, this._w, this._h);

    void onDartCollision(Dart dart) {
        // dart is above wall
        if (dart._y < _y) {
            dart._y = (_y - dart._r) - 1;
            dart._velY = -dart._velY * 0.9;
        }
        //dart is below wall
        else if (dart._y > _y + _h) {
            dart._y = _y + _h + 1 + dart._r;
            dart._velY = -dart._velY * 0.9;
        }

        //dart is to the left of the wall
        else if (dart._x < _x) {
            dart._x = (_x - dart._r) - 1;
            dart._velX = -dart._velX * 0.9;
        }
        //dart is to the right of the wall
        else if (dart._x > _x + _w) {
            dart._x = _x + _w + 1 + dart._r;
            dart._velX = -dart._velX * 0.9;
        }
    }

    void render(context, num screenShakeX, num screenShakeY) {
        context
            ..globalAlpha = 1
            ..fillStyle = "black"
            ..beginPath()
            ..rect(_x = screenShakeX, _y = screenShakeY, _w, _h)
            ..fill();
    }
}