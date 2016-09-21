library game;

import 'dart:html';
import 'dart:math';
import 'dart:async';
import 'dart:collection';


part 'keyboard.dart';

part 'mouse.dart';

part 'dart.dart';

part 'weapon_module.dart';

part 'target.dart';

part 'aimArc.dart';

part 'vector_math.dart';

part 'target_spawner.dart';

part 'particle.dart';

part 'score_counter.dart';

part 'wall.dart';

part 'utils.dart';

Random rnd = new Random();
const int canvasWidth = 800,
    canvasHeight = 600;

class Game {
    final CanvasElement _canvas;
    final Keyboard _keyboard = new Keyboard();
    final Mouse _mouse = new Mouse();

    ScoreCounter scoreCounter = new ScoreCounter();

    TargetSpawner targetSpawner;
    List<Particle> particles = new List<Particle>();

    WeaponModule weaponModule = new WeaponModule();
    List<Target> _targets = new List<Target>();

    List<Wall> _walls = new List<Wall>();

    num gravity;
    num airResistance;

    int _lastTimestamp = 0;

    num requiredScore;

    Game(this._canvas);

    run() {
        _init();
        window.requestAnimationFrame(_gameLoop);
    }

    // init the level; let this method be called by a level-manager thingy with
    // different arguments to set different levels
    void _init() {
        requiredScore = 10000 + scoreCounter.score; // keep old score but require new score to be reached independently

        gravity = 0;//350;
        airResistance = .25;

        targetSpawner = new TargetSpawner(100, 500);
        spawnWalls();
    }

    void loadNextLevel(String levelname) {
        window.alert("new level!!");

        _wipe();
        _init(); //TODO: call init with the level file
    }

    // clear level, reset everything
    void _wipe() {
        _targets = new List<Target>();
        _walls = new List<Wall>();
        // particles = new List<Particle>();  //don't reset particles cuz it looks cooler this way
        scoreCounter.wipePopupScores();
        weaponModule.wipe();
        _lastTimestamp = 0;
    }

    void spawnWalls() {
        // TODO: move this in a separate class or sth
        _walls.add(new Wall(500, 25, 200, 50));
        _walls.add(new Wall(50, 25, 200, 50));

        _walls.add(new Wall(100, 500, 200, 50));
        _walls.add(new Wall(600, 300, 50, 250));
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
        if(scoreCounter.score > requiredScore) {
            loadNextLevel("levelname placeholder");
        }

        while (_mouse.mouseEvents.isNotEmpty) {
            var mouseKey = _mouse.mouseEvents.removeAt(0);
            _handleMouseKey(mouseKey);
        }

        weaponModule.update(elapsed, gravity, airResistance);
        weaponModule.handleWallCollisions(_walls);
        weaponModule.handleDartDartCollisions(elapsed);

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
            _targets[i].update(weaponModule.flyingDarts, elapsed);

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

        scoreCounter.update(elapsed);
    }

    void _onTargetHit(Target target) {
        particles = new List.from(particles)
            ..addAll(getParticlesForTarget(target, target.hittingDart));

        target.hittingDart.onTargetHit();
        scoreCounter.onHitTarget(target, target.hittingDart);
    }

    void _handleMouseKey(MouseKey k) {
        switch (k) {
            case MouseKey.down:
                weaponModule.startCharging();
                break;
            case MouseKey.up:
                weaponModule.shootDart();
        }
    }


    void _render() {
        final CanvasRenderingContext2D context = _canvas.context2D;

        context
            ..globalAlpha = 1
            ..fillStyle = "beige"
            ..beginPath()
            ..rect(0, 0, 800, 600)
            ..fill();

        weaponModule.render(context, _mouse.mouseY);

        scoreCounter.render(context);

        for (var target in _targets) {
            target.render(context);
        }

        for (var particle in particles) {
            particle.render(context);
        }

        for (var wall in _walls) {
            wall.render(context);
        }
    }


}

void main() {
    final CanvasElement canvas = querySelector("#area");

    // turns focus away from address bar and towards the canvas
    canvas.focus();
    scheduleMicrotask(new Game(canvas).run);
}
