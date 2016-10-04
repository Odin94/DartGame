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
        return circleRectCollision(dart, this);
    }

    void _shrink(num elapsed) {
        remainingLifetime -= elapsed * 100;
        if (remainingLifetime < 0) remainingLifetime = 0;

        _w = _originalW * (remainingLifetime / _originalLifetime);
        _h = _originalH * (remainingLifetime / _originalLifetime);

        _x = _originalX + (_originalW - _w) / 2;
        _y = _originalY + (_originalH - _h) / 2;
    }

    void render(context, num screenShakeX, num screenShakeY) {
        context
            ..globalAlpha = 1
            ..fillStyle = "red"
            ..beginPath()
            ..rect(_x + screenShakeX, _y + screenShakeY, _w, _h)
            ..fill();
    }
}