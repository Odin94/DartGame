part of game;

class TargetSpawner {
    num _minSpawnDelay, _maxSpawnDelay;
    num _maxX, _maxY;

    num _minX = 400;
    num _minY = 50;

    num _minW = 30,
        _maxW = 100,
        _minH = 30,
        _maxH = 100;

    num _minLifetime = 500,
        _maxLifetime = 2000;

    num _accumulator = 0;
    num _currentSpawnDelay;

    TargetSpawner(this._minSpawnDelay, this._maxSpawnDelay, {maxX: 800, maxY: 600}) {
        _generateSpawnDelay();

        _maxX = maxX;
        _maxY = maxY;
    }

    void _generateSpawnDelay() {
        _currentSpawnDelay = _minSpawnDelay + rnd.nextInt(_maxSpawnDelay - _minSpawnDelay);
    }

    List<Target> spawnTargetsIfTime(num elapsed, List<Wall> walls) {
        var targetList = new List<Target>();
        _accumulator += elapsed * 100;

        while (_accumulator - _currentSpawnDelay >= 0) {
            _accumulator -= _currentSpawnDelay;

            Target newTarget = _generateTarget();
            num i = 0;
            while (_targetCollidesWithWall(newTarget, walls)) {
                newTarget = _generateTarget();

                i++;
                if (i > 50) {
                    print("Can't seem to find an empty spot to spawn the target! Too many walls!");
                    continue;
                }
            }

            targetList.add(newTarget);
            _generateSpawnDelay();
        }

        return targetList;
    }

    bool _targetCollidesWithWall(Target target, List<Wall> walls) {
        for (Wall wall in walls) {
            if (rectRectCollision(wall, target)) {
                return true;
            }
        }
        return false;
    }

    Target _generateTarget() {
        num targetW = _minW + rnd.nextInt(_maxW - _minW);
        num targetH = _minH + rnd.nextInt(_maxH - _minH);

        num targetX = _minX + rnd.nextInt(_maxX - _minX) - targetW;
        num targetY = _minY + rnd.nextInt(_maxY - _minY) - targetH;

        num lifetime = _minLifetime + rnd.nextInt(_maxLifetime);
        return new Target(targetX, targetY, targetW, targetH, lifetime);
    }
}