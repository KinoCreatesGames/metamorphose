package en.hazard;

/**
 * Door which is unlocked by keys when the player interacts with them
 * in the game. Can't pass through if the door is locked.
 */
class Door extends Hazard {
  public var unlocked:Bool;

  public function new(door:Entity_Door) {
    super(door.cx, door.cy);
    this.unlocked = door.f_unlocked;
    var doorAse = dn.heaps.assets.Aseprite.convertToSLib(Const.FPS,
      hxd.Res.img.light_door_anim_aseprite.toAseprite());
    spr.set(doorAse);

    spr.anim.playAndLoop('closed');
  }

  override function update() {
    super.update();

    if (unlocked) {
      spr.anim.play('open');
    } else {
      spr.anim.play('closed');
    }
  }
}