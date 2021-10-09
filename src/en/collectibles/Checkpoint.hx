package en.collectibles;

/**
 * Used to save the checkpoints for the individual hero within the game.
 * We use this to record the information and current position.
 */
class Checkpoint extends Entity {
  public var id:String;

  /*
   * Takes in the grid cx, cy column information to be placed on the map.
   * Records a checkpoint when the player interacts with it and saves their
   * current location progres.
   * @param x 
   * @param y 
   */
  public function new(checkpoint:Entity_Checkpoint) {
    super(checkpoint.cx, checkpoint.cy);
    id = '${checkpoint.cx}-${checkpoint.cy}';
    var ase = hxd.Res.img.diamond_checkpoint.toAseprite();
    var dia = dn.heaps.assets.Aseprite.convertToSLib(Const.FPS, ase);
    spr.set(dia);
    spr.anim.playAndLoop('idle');
  }
}