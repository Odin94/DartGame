part of game;

class WeaponModule {
    List<Dart> flyingDarts = new List<Dart>();
    Dart loadedDart;
    bool _loaded = true;

    AimArc aimArc = new AimArc(40, 300, 50);

    final int _dartStartY = 300;

    num _powerCharge = 0;
    bool _charging = false;
    num _chargeCap = 1000;
    num _chargeRate;

    num reloadTime = 2,
        reloadAcc = 0;

    WeaponModule() {
        loadedDart = new Dart(40, _dartStartY, 32);
        _chargeRate = _chargeCap;
    }

    void wipe() {
        flyingDarts = new List<Dart>();
        _reload();
    }

    void update(num elapsed, num gravity, num airResistance) {
        for (Dart dart in flyingDarts) {
            dart.update(elapsed, gravity, airResistance);
        }

        _removeOutOfFrameDarts();

        _manageCharging(elapsed);
        _manageReloading(elapsed);
    }

    void handleWallCollisions(List<Wall> walls) {
        for (Wall wall in walls) {
            for (Dart dart in flyingDarts) {
                if (circleRectCollision(dart, wall)) {
                    wall.onDartCollision(dart);
                }
            }
        }
    }

    void handleDartDartCollisions(num elapsed) {
        for (Dart firstDart in flyingDarts) {
            for (Dart secondDart in flyingDarts) {
                if (identical(firstDart, secondDart)) {
                    continue;
                }

                if (circleCircleCollision(firstDart, secondDart)) {
                    firstDart._velX = elasticCircleCollisionGetNewSpeed(firstDart._velX, secondDart._velX);
                    firstDart._velY = elasticCircleCollisionGetNewSpeed(firstDart._velY, secondDart._velY);

                    secondDart._velX = elasticCircleCollisionGetNewSpeed(secondDart._velX, firstDart._velX);
                    secondDart._velY = elasticCircleCollisionGetNewSpeed(secondDart._velY, firstDart._velY);

                    // separate the darts
                    num deltaX = firstDart._x - secondDart._x;
                    num deltaY = firstDart._y - secondDart._y;

                    firstDart._x += deltaX / 4;
                    firstDart._y += deltaY / 4;

                    secondDart._x -= deltaX / 4;
                    secondDart._y -= deltaY / 4;
                }
            }
        }
    }

    void _removeOutOfFrameDarts() {
        List<int> indicesToRemove = new List<int>();
        for (int i = 0; i < flyingDarts.length; i++) {
            Dart dart = flyingDarts[i];

            if (dart._x > canvasWidth || dart._y > canvasHeight || dart._x < -dart.diameter) {
                indicesToRemove.add(i);
            }
        }

        for (int i = indicesToRemove.length - 1; i >= 0; i--) {
            int j = indicesToRemove[i];
            flyingDarts.removeAt(j);
        }
    }

    void _manageCharging(num elapsed) {
        if (_charging) {
            _powerCharge += _chargeRate * elapsed;
            _powerCharge %= _chargeCap;
        }
    }

    void _manageReloading(num elapsed) {
        if (!_loaded) {
            reloadAcc += elapsed;
            if (reloadAcc >= reloadTime) {
                _reload();
                reloadAcc = 0;
            }
        }
    }

    void _reload() {
        _loaded = true;
        loadedDart = new Dart(40, _dartStartY, 32);
    }

    void shootDart() {
        if (_loaded) {
            _loaded = false;

            List<num> vel = _getDartThrowVelocity();
            loadedDart.shootDart(vel[0], vel[1]);
            flyingDarts.add(new Dart.fromDart(loadedDart));

            loadedDart = null;
        }

        _charging = false;
        _powerCharge = 0;
    }

    void startCharging() {
        _charging = true;
    }

    List<num> _getDartThrowVelocity() {
        num x = aimArc.posX - loadedDart._x;
        num y = aimArc.posY - loadedDart._y;

        return normalize(x, y, len: _powerCharge);
    }

    void render(CanvasRenderingContext2D context, mouseY, num screenShakeX, num screenShakeY) {
        aimArc.renderAimAlongArc(mouseY, _dartStartY, context);

        for (Dart dart in flyingDarts) {
            dart.render(context, screenShakeX, screenShakeY);
        }

        if (loadedDart != null) {
            loadedDart.render(context, 0, 0);
        }

        _renderPowerMeter(context);
    }

    _renderPowerMeter(context) {
        final powerMeter_x = 30;
        final powerMeter_y = 550;
        final powerMeter_w = 100;
        final powerMeter_h = 30;

        context
            ..rect(powerMeter_x, powerMeter_y, powerMeter_w, powerMeter_h)
            ..stroke();

        context
            ..fillStyle = "black"
            ..beginPath()
            ..lineWidth = 4
            ..rect(powerMeter_x, powerMeter_y, (_powerCharge / _chargeCap) * powerMeter_w, powerMeter_h)
            ..fill();
    }
}