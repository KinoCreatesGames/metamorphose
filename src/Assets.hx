import dn.heaps.slib.*;

/**
 * Centralizes all of the assets in the game and keeps them
 *  in a single location to promote file watching.
 */
class Assets {
  public static var fontPixel:h2d.Font;
  public static var fontTiny:h2d.Font;
  public static var fontSmall:h2d.Font;
  public static var fontMedium:h2d.Font;
  public static var fontLarge:h2d.Font;
  public static var tiles:SpriteLib;

  static var initDone = false;

  /**
   * LDTKProject data
   */
  public static var projData:ldtkData.LDTkProj;

  public static function init() {
    if (initDone) return;
    initDone = true;

    fontPixel = hxd.Res.fonts.minecraftiaOutline.toFont();
    fontTiny = hxd.Res.fonts.barlow_condensed_medium_regular_9.toFont();
    fontSmall = hxd.Res.fonts.barlow_condensed_medium_regular_11.toFont();
    fontMedium = hxd.Res.fonts.barlow_condensed_medium_regular_17.toFont();
    fontLarge = hxd.Res.fonts.barlow_condensed_medium_regular_32.toFont();
    tiles = dn.heaps.assets.Atlas.load("atlas/tiles.atlas");

    projData = new ldtkData.LDTkProj();

    // Hot Reloading from LDTK for testing
    #if debug
    // Gets the file entry for the LDtk file then uses it later
    // To reload the world / level
    var res = try hxd.Res.load(projData.projectFilePath.substr(4))
    catch (_) null; // assume the LDtk file is in "res/" subfolde
    if (res != null) {
      res.watch(() -> {
        // Delayer allows callbacks to be run in a future frame
        // Cancel by ID cancels the LDTk delayer in a future frame
        Main.ME.delayer.cancelById('ldtk');
        Main.ME.delayer.addS('ldtk', () -> {
          projData.parseJson(res.entry.getText());
          // Automatically reloads the level when the there
          // are updates made to the LDtk file.
          if (Game.ME != null) {
            Game.ME.onLDtkReload();
          }
        }, 0.2);
      });
    }
    #end
  }
}