part of game;

num length(num x, num y) {
    return sqrt(x * x + y * y);
}

List<num> normalize(num x, num y, {num len: 1}) {
    if (length(x, y) == 0) {
        print("lol its 0 m8");
    }

    num nf = 1 / length(x, y);
    return [x * nf * len, y * nf * len];
}