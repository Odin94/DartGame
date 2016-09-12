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

    Dart.fromDart(Dart dart) {
        _x = dart._x;
        _y = dart._y;
        _r = dart._r;

        _velX = dart._velX;
        _velY = dart._velY;

        wasThrown = dart.wasThrown;
        hitTargets = dart.hitTargets;
    }

    num get diameter => _r * 2;

    void shootDart(num vel_x, num vel_y) {
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
        _velX = _velX * (1 - airResistance * elapsed);

        _velY += gravity * elapsed;
    }

    void render(context) {
        context
            ..beginPath()
            ..fillStyle = "black"
            ..arc(_x, _y, _r, 0, PI * 2.0)
            ..fill();
    }
}