package en.hazard;

/**
 * Bounce pad, when the player touches this, they will get a sudden
 * boost of speed and be launched into the air at a high speed.
 */
class BouncePad extends Hazard {
  public function new(eBouncePad:Entity_BouncePad) {
    super(eBouncePad.cx, eBouncePad.cy);

    var bounceAse = dn.heaps.assets.Aseprite.convertToSLib(Const.FPS,
      hxd.Res.img.bouncepad_two_ase.toAseprite());
    // var bounceAssets = dn.heaps.assets.Aseprite.convertToSLib() // var bounceAssets = dn.heaps.assets.Aseprite.convertToSLib()

    spr.set(bounceAse);
    spr.anim.playAndLoop('idle');
  }

  /**
   * Bouncing animation play
   */
  public function bounce() {
    spr.anim.setSpeed(120);
    spr.anim.play('bounce', 1);
    spr.anim.onEnd(() -> {
      spr.anim.play('idle', 1);
    });
  }
}