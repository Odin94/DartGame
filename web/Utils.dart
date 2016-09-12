part of game;

bool circleRectangleCollision(circle, rectangle) {
    num rectCenterX = rectangle._x + rectangle._w / 2;
    num rectCenterY = rectangle._y + rectangle._h / 2;

    num circleDistanceX = (circle._x - rectCenterX).abs();
    num circleDistanceY = (circle._y - rectCenterY).abs();

    if (circleDistanceX > (rectangle._w / 2 + circle._r)) return false;
    if (circleDistanceY > (rectangle._h / 2 + circle._r)) return false;

    if (circleDistanceX <= (rectangle._w / 2)) return true;
    if (circleDistanceY <= (rectangle._h / 2)) return true;

    num cornerDistanceSq = (circleDistanceX - rectangle._w / 2) * (circleDistanceX - rectangle._w / 2) +
        (circleDistanceY - rectangle._h / 2) * (circleDistanceY - rectangle._h / 2);

    return (cornerDistanceSq <= (circle._r * circle._r));
}