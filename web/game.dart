library game;

import 'dart:html';
import 'dart:math';
import 'dart:async';
import 'dart:collection';


part 'keyboard.dart';

part 'mouse.dart';

part 'dart.dart';

part 'dart_reloader.dart';

part 'target.dart';

part 'aimArc.dart';

part 'vector_math.dart';

part 'target_spawner.dart';

part 'particle.dart';

part 'score_text.dart';

Random rnd = new Random();

class Game {
    final CanvasElement _canvas;
    final Keyboard _keyboard = new Keyboard();
    final Mouse _mouse = new Mouse();

    var scoreText = new ScoreText();

    final _dartStartY = 300;

    var targetSpawner = new TargetSpawner(100, 500);
    var particles = new List<Particle>();

    var _aimArc = new AimArc(40, 300, 50);
    var _dart;
    var _targets = new List<Target>();

    final gravity = 350;
    final airResistance = 100;

    num _powerCharge = 0;
    bool _charging = false;
    num _chargeCap = 1000;
    num _chargeRate;

    int _lastTimestamp = 0;
    double _x = 400.0;
    double _y = 300.0;

    Game(this._canvas) {
        _chargeRate = _chargeCap;
        _dart = new Dart(40, _dartStartY, 32);
    }

    run() {
        window.requestAnimationFrame(_gameLoop);
    }

    void _gameLoop(final double _) {
        _update(_getElapsed());
        _render();
        window.requestAnimationFrame(_gameLoop);
    }

    double _getElapsed() {
        final int time = new DateTime.now().millisecondsSinceEpoch;

        double elapsed = 0.0;
        if (_lastTimestamp != 0) {
            elapsed = (time - _lastTimestamp) / 1000.0;
        }

        _lastTimestamp = time;
        return elapsed;
    }

    void _update(final double elapsed) {
        if (_keyboard.isPressed(KeyCode.R)) _reset();

        if (_keyboard.isPressed(KeyCode.RIGHT)) _dart.throwDart(500, -100);

        while (_mouse.mouseEvents.isNotEmpty) {
            var mouseKey = _mouse.mouseEvents.removeAt(0);
            _handleMouseKey(mouseKey);
        }

        _dart.update(elapsed, gravity, airResistance);

        for (var particle in particles) {
            particle.update(elapsed);
        }
        for (int i = particles.length - 1; i >= 0; i--) {
            if (particles[i].outOfScreen) {
                particles.removeAt(i);
            }
        }

        // Spawn new targets; is creating a new list every time too inefficient?
        _targets = new List.from(_targets)
            ..addAll(targetSpawner.spawnTargetsIfTime(elapsed));

        var indicesToRemove = new List<int>();
        for (int i = 0; i < _targets.length; i++) {
            _targets[i].update(_dart, elapsed);

            if (_targets[i].remainingLifetime <= 0 || _targets[i].hit) {
                indicesToRemove.add(i);
            }
        }

        // iterate over indices to remove in reverse order
        // so removing elements doesn't change indices for later removals
        for (int i = indicesToRemove.length - 1; i >= 0; i--) {
            num j = indicesToRemove[i];
            if (_targets[j].hit) _onTargetHit(_targets[j]);
            _targets.removeAt(j);
        }

        scoreText.update(elapsed);

        if (_charging) {
            _powerCharge += _chargeRate * elapsed;
            _powerCharge %= _chargeCap;
        }
    }

    void _onTargetHit(var target) {
        particles = new List.from(particles)
            ..addAll(getParticlesForTarget(target, _dart));

        _dart.onTargetHit();
        scoreText.onHitTarget(target, _dart);
    }

    void _handleMouseKey(MouseKey k) {
        switch (k) {
            case MouseKey.down:
                _charging = true;
                break;
            case MouseKey.up:
                _charging = false;

                var vel = _getDartThrowVelocity();
                _dart.throwDart(vel[0], vel[1]);
                _powerCharge = 0;
        }
    }

    List<num> _getDartThrowVelocity() {
        num x = _aimArc.posX - _dart._x;
        num y = _aimArc.posY - _dart._y;

        return normalize(x, y, len: _powerCharge);
    }

    void _reset() {
        _dart = new Dart(40, _dartStartY, 32);
    }

    void _render() {
        final CanvasRenderingContext2D context = _canvas.context2D;

        context
            ..globalAlpha = 1
            ..fillStyle = "beige"
            ..beginPath()
            ..rect(0, 0, 800, 600)
            ..fill();

        context
            ..beginPath()
            ..fillStyle = "black"
            ..arc(_dart._x, _dart._y, _dart._r, 0, PI * 2.0)
            ..fill();

        scoreText.render(context);

        for (var target in _targets) {
            target.render(context);
        }

        for (var particle in particles) {
            particle.render(context);
        }

        _aimArc.renderAimAlongArc(_mouse.mouseY, _dartStartY, _canvas.height, context);
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

void main() {
    final CanvasElement canvas = querySelector("#area");

    // turns focus away from address bar and towards the canvas
    canvas.focus();
    scheduleMicrotask(new Game(canvas).run);
}
