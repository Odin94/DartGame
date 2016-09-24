part of game;

const num _minParticleVelX = 100,
    _maxParticleVelX = 1000,
    _minParticleVelY = -400,
    _maxParticleVelY = 400;

num _maxParticleSize = 4;

List<Particle> getParticlesForTarget(Target target, Dart dart) {
    int particleCountMax = (target.size / 10).round();
    int particleCountMin = (target.size / 20).round();
    int particleCount = particleCountMin + rnd.nextInt(particleCountMax - particleCountMin);

    //TODO: make this depend on the impact angle
    int minParticleVelY = (dart._velY - 200).round();
    int maxParticleVelY = (dart._velY + 200).round();

    var particles = new List<Particle>();
    for (int i = 0; i < particleCount; i++) {
        particles.add(
            new Particle(
                target._x, target._x + target._w, target._y, target._y + target._h, minParticleVelY: minParticleVelY,
                maxParticleVelY: maxParticleVelY));
    }

    return particles;
}

class Particle {
    num _x, _y, _w, _h, _velX, _velY, _size;
    bool outOfScreen = false;

    Particle(num minX, num maxX, num minY, num maxY,
        {minParticleVelY: _minParticleVelY, maxParticleVelY: _maxParticleVelY}) {
        _x = minX + rnd.nextInt((maxX - minX).round());
        _y = minY + rnd.nextInt((maxY - minY).round());

        _velX = _minParticleVelX + rnd.nextInt(_maxParticleVelX - _minParticleVelX);
        _velY = minParticleVelY + rnd.nextInt(maxParticleVelY - minParticleVelY);

        _size = 1 + rnd.nextInt(_maxParticleSize - 1);
        _w = _size;
        _h = _size;
    }

    Particle clone() {
        window.alert("1");
        Particle cloned = new Particle(5, 10, 5, 10);

        cloned._x = this._x;
        cloned._y = this._y;
        cloned._velX = 0;
        cloned._velY = 0;
        cloned._size = this._size;

        cloned._w = this._size;
        cloned._h = this._size;


        return cloned;
    }

    void update(num elapsed) {
        _x += _velX * elapsed;
        _y += _velY * elapsed;

        if (_x > 800 || _x < 0 || _y > 600 || _y < 0) {
            outOfScreen = true;
        }
    }

    void render(context) {
        context
            ..globalAlpha = 1
            ..fillStyle = "red"
            ..beginPath()
            ..rect(_x, _y, _size, _size)
            ..fill();
    }
}