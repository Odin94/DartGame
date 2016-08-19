part of game;

const num _minParticleVelX = 100,
    _maxParticleVelX = 1000,
    _minParticleVelY = -400,
    _maxParticleVelY = 400;

num _particleSize = 2;

List<Particle> getParticlesForTarget(Target target, Dart dart) {
    var rnd = new Random();

    int particleCountMax = (target.size / 10).round();
    int particleCountMin = (target.size / 20).round();
    int particleCount = particleCountMin + rnd.nextInt(particleCountMax - particleCountMin);

    //TODO: make this depend on the impact angle
    int minParticleVelY = (dart._velY - 200).round();
    int maxParticleVelY = (dart._velY + 200).round();

    var particles = new List<Particle>();
    for (int i = 0; i < particleCount; i++) {
        particles.add(
            new Particle(target._x, target._y, minParticleVelY: minParticleVelY, maxParticleVelY: maxParticleVelY));
    }

    return particles;
}

class Particle {
    num _x, _y, _velX, _velY;

    Particle(this._x, this._y, {minParticleVelY: _minParticleVelY, maxParticleVelY: _maxParticleVelY}) {
        var rnd = new Random();
        _velX = _minParticleVelX + rnd.nextInt(_maxParticleVelX - _minParticleVelX);
        _velY = minParticleVelY + rnd.nextInt(maxParticleVelY - minParticleVelY);
    }

    void update(num elapsed) {
        _x += _velX * elapsed;
        _y += _velY * elapsed;
    }

    void render(context) {
        context
            ..globalAlpha = 1
            ..fillStyle = "red"
            ..beginPath()
            ..rect(_x, _y, _particleSize, _particleSize)
            ..fill();
    }
}