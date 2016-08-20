part of game;

class Dart {
    num _x;
    num _y;
    num _r;

    num _velX = 0;
    num _velY = 0;

    num hitTargets = 0;

    bool wasThrown = false;

    Dart(this._x, this._y, this._r);

    void throwDart(num vel_x, num vel_y) {
        if (!wasThrown) {
            _velX = vel_x;
            _velY = vel_y;

            wasThrown = true;
        }
    }

    void update(num elapsed, num gravity, num airResistance) {
        if (wasThrown) {
            _move(elapsed);
            _updateVelocity(elapsed, gravity, airResistance);
        }
    }

    void onTargetHit() {
        hitTargets++;
    }

    void _move(num elapsed) {
        _x += _velX * elapsed;
        _y += _velY * elapsed;
    }

    void _updateVelocity(num elapsed, num gravity, num airResistance) {
        _velX -= airResistance * elapsed;
        if (_velX < 0) _velX = 0;

        _velY += gravity * elapsed;
    }
}