package en;

import dn.heaps.assets.Aseprite;

class Core extends Entity {
  public function new(eCore:Entity_Core) {
    super(eCore.cx, eCore.cy);
    setupAnimations();
  }

  public function setupAnimations() {
    var strobe = Aseprite.convertToSLib(Const.FPS,
      hxd.Res.img.strobe.toAseprite());
    spr.set(strobe);
    spr.setCenterRatio();
    spr.anim.playAndLoop('idle');
  }
}