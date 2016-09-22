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

bool circleCircleCollision(firstCircle, secondCircle) {
    // check rectangle collision first for efficiency
    if (!(firstCircle._x + firstCircle._r + secondCircle._r > secondCircle._x
        && firstCircle._x < secondCircle._x + firstCircle._r + secondCircle._r
        && firstCircle._y + firstCircle._r + secondCircle._r > secondCircle._y
        && firstCircle._y < secondCircle._y + firstCircle._r + secondCircle._r)) {
        return false;
    }

    num distance = sqrt(((firstCircle._x - secondCircle._x) * (firstCircle._x - secondCircle._x)) +
        ((firstCircle._y - secondCircle._y) * (firstCircle._y - secondCircle._y)));

    return distance < firstCircle._r + secondCircle._r;
}

List<num> getCircleCollisionPoint(firstCircle, secondCircle) {
    num collisionPointX =
        ((firstCircle._x * secondCircle._r) + (secondCircle._x * firstCircle._r))
            / (firstCircle._r + secondCircle._r);

    num collisionPointY =
        ((firstCircle._y * secondCircle._r) + (secondCircle._y * firstCircle._r))
            / (firstCircle._r + secondCircle._r);

    return [collisionPointX, collisionPointY];
}

num elasticCircleCollisionGetNewSpeed(firstCircleSpeed, secondCircleSpeed, {firstCircleMass: 1, secondCircleMass: 1}) {
    return (firstCircleSpeed * (firstCircleMass - secondCircleMass) +
        (2 * secondCircleMass * secondCircleSpeed)) / (firstCircleMass + secondCircleMass);
}