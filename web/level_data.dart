part of game;

class LevelData {
    num requiredScore;
    num gravity;
    num airResistance;

    TargetSpawner targetSpawner;
    List<Wall> walls;

    LevelData(this.requiredScore, this.targetSpawner, this.walls, {this.gravity: 350, this.airResistance: .25});
}

List<LevelData> getLevelData() {
    List<LevelData> levels = new List();

    levels.add(loadLevel1());
    levels.add(loadLevel2());

    return levels;
}

LevelData loadLevel1() {
    List<Wall> walls = new List();
    walls.add(new Wall(500, 25, 200, 50));
    walls.add(new Wall(50, 25, 200, 50));
    walls.add(new Wall(100, 500, 200, 50));
    walls.add(new Wall(600, 300, 50, 250));

    return new LevelData(3000, new TargetSpawner(100, 500, maxX: 600, maxY: 500), walls);
}

LevelData loadLevel2() {
    List<Wall> walls = new List();

    walls.add(new Wall(725, 100, 50, 450));

    return new LevelData(10000, new TargetSpawner(100, 500, maxX: 550, maxY: 300), walls);
}