part of game;

class AimArc {
    num _centerX, _centerY, _r;
    num posX, posY;

    AimArc(this._centerX, this._centerY, this._r);

    void renderAimAlongArc(mouseY, dartY, canvasHeight, context) {
        num mappedMouseY = _mapMouseYToPi(mouseY, dartY, canvasHeight);

        posX = _r * cos(mappedMouseY) + _centerX;
        posY = _r * sin(mappedMouseY) + _centerY;

        context
            ..beginPath()
            ..fillStyle = "black"
            ..arc(posX, posY, 4, 0, PI * 2.0)
            ..fill();
    }

    num _mapMouseYToPi(mouseY, dartY, canvasHeight) {
        if (mouseY > canvasHeight) mouseY = canvasHeight;

        return (mouseY + canvasHeight - dartY) * 3.14 / (canvasHeight) + 3.14;
    }
}