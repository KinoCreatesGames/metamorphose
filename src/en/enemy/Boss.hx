package en.enemy;

class Boss extends Enemy {
  public function new(enemy:Entity_Enemy) {
    super(enemy.cx, enemy.cy);
    sightRange = 5;
    state = new State(idle);
  }

  public function attacking() {
    if (!inLineOfSight()) {
      state.currentState = idle;
    }
  }

  public function dashAttak() {}

  public function idle() {
    if (inLineOfSight()) {
      state.currentState = attacking;
    }
  }

  override public function update() {
    super.update();
    state.update();
    if (dx != 0) {
      dir = (-1 * M.sign(dx));
    }
  }
}