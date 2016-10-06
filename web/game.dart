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

part 'level_data.dart';

part 'bouncy_wall.dart';

part 'inverter_wall.dart';

Random rnd = new Random();
const int canvasWidth = 800,
    canvasHeight = 600;

class Game {
    final CanvasElement _canvas;
    final Keyboard _keyboard = new Keyboard();
    final Mouse _mouse = new Mouse();

    List<LevelData> levels = getLevelData();
    int currentLevel = 0;

    ScoreCounter scoreCounter = new ScoreCounter();

    TargetSpawner targetSpawner;
    List<Particle> particles = new List<Particle>();
    List<Particle> permanentParticles = new List<Particle>();

    WeaponModule weaponModule = new WeaponModule();
    List<Target> _targets = new List<Target>();

    List<Wall> _walls = new List<Wall>();

    num screenShakeMaxX = 0,
        screenShakeMaxY = 0,
        screenShakeX = 0,
        screenShakeY = 0,
        screenShakeDuration = 0;

    num levelTransitionCutsceneDuration = 3;
    num levelTransitionDurationAcc = 0;
    bool inLevelTransition = false;

    num gravity;
    num airResistance;

    int _lastTimestamp = 0;

    num requiredScore;

    Game(this._canvas);

    run() {
        _init(levels[currentLevel]);
        window.requestAnimationFrame(_gameLoop);
    }

    // init the level; let this method be called by a level-manager thingy with
    // different arguments to set different levels
    void _init(LevelData level) {
        startScreenShake(5);

        requiredScore = level.requiredScore +
            scoreCounter.score; // keep old score but require new score to be reached independently

        gravity = level.gravity;
        airResistance = level.airResistance;

        targetSpawner = level.targetSpawner;
        _walls = level.walls;
    }

    void playLevelTransitionCutscene(num elapsed) {
        levelTransitionDurationAcc += elapsed;
        updateScreenShake(elapsed);

        _render();

        _canvas.context2D
            ..fillStyle = "black"
            ..font = "64px consolas"
            ..fillText("Level $currentLevel completed!", 100, 200);

        if (levelTransitionDurationAcc >= levelTransitionCutsceneDuration) {
            loadNextLevel();
        }
    }

    void startLevelTransition() {
        inLevelTransition = true;
    }

    void loadNextLevel() {
        _wipe();

        currentLevel += 1;
        if (currentLevel >= levels.length) {
            currentLevel -= 1;
        }
        _init(levels[currentLevel]);

        inLevelTransition = false;
    }

    // clear level, reset everything
    void _wipe() {
        _targets = new List<Target>();
        _walls = new List<Wall>();
        // particles = new List<Particle>();  //don't reset particles cuz it looks cooler this way
        permanentParticles = new List<Particle>();
        scoreCounter.wipePopupScores();
        weaponModule.wipe();
        _lastTimestamp = 0;

        screenShakeDuration = 0;
        levelTransitionDurationAcc = 0;
    }

    void playGameLoop(num elapsed) {
        _update(elapsed);
        _render();
    }

    void _gameLoop(final double _) {
        num elapsed = _getElapsed();
        if(inLevelTransition) {
            playLevelTransitionCutscene(elapsed);
        }
        else {
            playGameLoop(elapsed);
        }

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
        updateScreenShake(elapsed);

        if (scoreCounter.score > requiredScore) {
            startLevelTransition();
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
            for (var wall in _walls) {
                if (rectRectCollision(particle, wall)) {
                    permanentParticles.add(particle.clone());
                    particle.outOfScreen = true; // not really out of screen, just want to remove it :x bad idea
                }
            }
        }
        for (int i = particles.length - 1; i >= 0; i--) {
            if (particles[i].outOfScreen) {
                particles.removeAt(i);
            }
        }

        // Spawn new targets; is creating a new list every time too inefficient?
        _targets = new List.from(_targets)
            ..addAll(targetSpawner.spawnTargetsIfTime(elapsed, _walls));

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

    void startScreenShake(num xIntensity, {num yIntensity: null, num duration: 1}) {
        if (yIntensity == null) yIntensity = xIntensity;

        screenShakeDuration += duration;
        screenShakeMaxX += xIntensity;
        screenShakeMaxY += yIntensity;
    }

    void updateScreenShake(num elapsed) {
        screenShakeDuration -= elapsed;
        if (screenShakeDuration <= 0) {
            screenShakeDuration = 0;
            screenShakeMaxX = 0;
            screenShakeMaxY = 0;

            screenShakeX = 0;
            screenShakeY = 0;
        }
        else {
            screenShakeX = -screenShakeMaxX + rnd.nextInt(screenShakeMaxX * 2);
            screenShakeY = -screenShakeMaxY + rnd.nextInt(screenShakeMaxY * 2);
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

        weaponModule.render(context, _mouse.mouseY, screenShakeX, screenShakeY);

        scoreCounter.render(context);

        for (var target in _targets) {
            target.render(context, screenShakeX, screenShakeY);
        }

        for (var particle in particles) {
            particle.render(context, screenShakeX, screenShakeY);
        }

        for (var particle in permanentParticles) {
            particle.render(context, screenShakeX, screenShakeY);
        }

        for (var wall in _walls) {
            wall.render(context, screenShakeX, screenShakeY);
        }
    }


}

void main() {
    final CanvasElement canvas = querySelector("#area");
    // turns focus away from address bar and towards the canvas
    canvas.focus();
    scheduleMicrotask(new Game(canvas).run);
}
