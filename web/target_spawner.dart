part of game;

class TargetSpawner {
    num _minSpawnDelay, _maxSpawnDelay;
    num _maxX, _maxY;

    num _minX = 400;

    num _minW = 30,
        _maxW = 100,
        _minH = 30,
        _maxH = 100;

    num _minLifetime = 500,
        _maxLifetime = 2000;

    num _accumulator = 0;
    num _currentSpawnDelay;

    var _rng = new Random();

    TargetSpawner(this._minSpawnDelay, this._maxSpawnDelay, {maxX: 800, maxY: 600}) {
        _generateSpawnDelay();

        _maxX = maxX;
        _maxY = maxY;
    }

    void _generateSpawnDelay() {
        _currentSpawnDelay = _minSpawnDelay + _rng.nextInt(_maxSpawnDelay - _minSpawnDelay);
    }

    List<Target> spawnTargetsIfTime(num elapsed) {
        var targetList = new List<Target>();
        _accumulator += elapsed * 100;

        while (_accumulator - _currentSpawnDelay >= 0) {
            _accumulator -= _currentSpawnDelay;

            targetList.add(_generateTarget());
            _generateSpawnDelay();
        }

        return targetList;
    }

    Target _generateTarget() {
        num targetW = _minW + _rng.nextInt(_maxW - _minW);
        num targetH = _minH + _rng.nextInt(_maxH - _minH);

        num targetX = _minX + _rng.nextInt(_maxX - _minX) - targetW;
        num targetY = _rng.nextInt(_maxY) - targetH;

        num lifetime = _minLifetime + _rng.nextInt(_maxLifetime);
        return new Target(targetX, targetY, targetW, targetH, lifetime);
    }
}