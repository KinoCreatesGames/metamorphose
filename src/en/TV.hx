package en;

import dn.heaps.assets.Aseprite;

class TV extends Entity {
  public function new(eTV:Entity_TV) {
    super(eTV.cx, eTV.cy);
    setupAnimations();
  }

  public function setupAnimations() {
    var tv = Aseprite.convertToSLib(Const.FPS,
      hxd.Res.img.tv_base_final.toAseprite());
    spr.set(tv);
    spr.setCenterRatio();
    spr.anim.playAndLoop('talking');
  }
}