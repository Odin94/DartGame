part of game;

class ScoreText {
    num score = 0;
    var popupScores = new List<String>();

    void onHitTarget(Target target, Dart dart) {
        num gainedScore = 800 + rnd.nextInt(1200 - 800);

        String gainedScoreString = "$gainedScore";
        if (dart.hitTargets > 1) {
            num hitTargets = dart.hitTargets;
            gainedScoreString += " x$hitTargets";

            gainedScore *= hitTargets;
        }

        score += gainedScore;

        popupScores.add(new PopupScore(gainedScoreString, target._x + target._w / 2, target._y - 20));
    }

    void update(num elapsed) {
        var indicesToRemove = new List<int>();

        for (int i = 0; i < popupScores.length; i++) {
            popupScores[i].update(elapsed);

            if (!popupScores[i].permanent && popupScores[i]._remainingLifetime <= 0) {
                indicesToRemove.add(i);
            }
        }

        for (int i = indicesToRemove.length - 1; i >= 0; i--) {
            num j = indicesToRemove[i];
            popupScores.removeAt(j);
        }
    }

    void render(var context) {
        context
            ..fillStyle = "black"
            ..font = "48px consolas"
            ..fillText("$score", 10, 50);

        for (var popupScore in popupScores) {
            popupScore.render(context);
        }
    }
}

class PopupScore {
    String score;
    num _x, _y;
    num _remainingLifetime;

    bool permanent = true;


    PopupScore(this.score, this._x, this._y, {remainingLifetime: 2}) {
        _remainingLifetime = remainingLifetime;
    }

    void update(num elapsed) {
        _remainingLifetime -= elapsed;
    }

    void render(var context) {
        context
            ..fillStyle = "black"
            ..font = "24px consolas"
            ..fillText(score, _x, _y);
    }
}