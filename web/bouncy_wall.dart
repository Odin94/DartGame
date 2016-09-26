part of game;

class BouncyWall extends Wall {
    num bounceMultiplier = 2;

    BouncyWall(num _x, _y, _w, _h) : super(_x, _y, _w, _h);

    void onDartCollision(Dart dart) {
        // dart is above wall
        if (dart._y < _y) {
            dart._y = (_y - dart._r) - 1;
            dart._velY = -dart._velY * bounceMultiplier;
        }
        //dart is below wall
        else if (dart._y > _y + _h) {
            dart._y = _y + _h + 1 + dart._r;
            dart._velY = -dart._velY * bounceMultiplier;
        }

        //dart is to the left of the wall
        else if (dart._x < _x) {
            dart._x = (_x - dart._r) - 1;
            dart._velX = -dart._velX * bounceMultiplier;
        }
        //dart is to the right of the wall
        else if (dart._x > _x + _w) {
            dart._x = _x + _w + 1 + dart._r;
            dart._velX = -dart._velX * bounceMultiplier;
        }
    }

    void render(context) {
        context
            ..globalAlpha = 1
            ..fillStyle = "blue"
            ..beginPath()
            ..rect(_x, _y, _w, _h)
            ..fill();
    }
}