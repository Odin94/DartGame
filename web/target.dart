part of game;

class Target {
    num _originalX, _originalY, _originalW, _originalH;

    num _x, _y, _w, _h;
    num _velX, _velY;

    num _originalLifetime;
    num remainingLifetime;

    bool hit = false;
    Dart hittingDart = null;

    Target(this._originalX, this._originalY, this._originalW, this._originalH, this._originalLifetime) {
        _x = _originalX;
        _y = _originalY;
        _w = _originalW;
        _h = _originalH;

        remainingLifetime = _originalLifetime;
    }

    num get size => _w * _h;

    void update(List<Dart> darts, num elapsed) {
        for (Dart dart in darts) {
            if (_checkCollision(dart)) {
                hit = true;
                hittingDart = dart;
                break;
            }
        }
        _shrink(elapsed);
    }

    bool _checkCollision(Dart dart) {
        num circleDistanceX = (dart._x - (_x + _w / 2)).abs();
        num circleDistanceY = (dart._y - (_y + _h / 2)).abs();

        if (circleDistanceX > (_w / 2 + dart._r)) return false;
        if (circleDistanceY > (_h / 2 + dart._r)) return false;

        if (circleDistanceX <= (_w / 2)) return true;
        if (circleDistanceY <= (_h / 2)) return true;

        num cornerDistanceSq = (circleDistanceX - _w / 2) +
            (circleDistanceY - _h / 2) * (circleDistanceY - _h / 2);

        return (cornerDistanceSq <= (dart._r * dart._r));
    }

    void _shrink(num elapsed) {
        remainingLifetime -= elapsed * 100;
        if (remainingLifetime < 0) remainingLifetime = 0;

        _w = _originalW * (remainingLifetime / _originalLifetime);
        _h = _originalH * (remainingLifetime / _originalLifetime);

        _x = _originalX + (_originalW - _w) / 2;
        _y = _originalY + (_originalH - _h) / 2;
    }

    void render(context) {
        context
            ..globalAlpha = 1
            ..fillStyle = "red"
            ..beginPath()
            ..rect(_x, _y, _w, _h)
            ..fill();
    }
}