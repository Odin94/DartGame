part of game;

bool circleRectangleCollision(circle, rectangle) {
    num circleDistanceX = (circle._x - (rectangle._x + rectangle._w / 2)).abs();
    num circleDistanceY = (circle._y - (rectangle._y + rectangle._h / 2)).abs();

    if (circleDistanceX > (rectangle._w / 2 + circle._r)) return false;
    if (circleDistanceY > (rectangle._h / 2 + circle._r)) return false;

    if (circleDistanceX <= (rectangle._w / 2)) return true;
    if (circleDistanceY <= (rectangle._h / 2)) return true;

    num cornerDistanceSq = (circleDistanceX - rectangle._w / 2) +
        (circleDistanceY - rectangle._h / 2) * (circleDistanceY - rectangle._h / 2);

    return (cornerDistanceSq <= (circle._r * circle._r));
}