import dn.data.SavedData;
import ui.Transition;
import en.Hero;
import depot.DepotData;
import ui.Modal;
import ui.MsgWindow;
import dn.Process;
import hxd.Key;

class Game extends Process {
  public static var ME:Game;

  /** Game controller (pad or keyboard) **/
  public var ca:dn.heaps.Controller.ControllerAccess;

  /** Particles **/
  public var fx:Fx;

  /** Basic viewport control **/
  public var camera:Camera;

  /** Container of all visual game objects. Ths wrapper is moved around by Camera. **/
  public var scroller:h2d.Layers;

  /** Level data **/
  public var level:Level;

  /** UI **/
  public var hud:ui.Hud;

  /**
   * In game notifications during item pick ups.
   */
  public var notify:ui.Notification;

  /**
   * Project file for LDtk in here.
   */
  public var proj:LDTkProj;

  public var title:Title;

  public var resumeGameOver:Bool;
  public var playerState:PlayerState;
  public var msgWin:MsgWindow;

  public function new() {
    super(Main.ME);
    ME = this;
    proj = new LDTkProj();
    ca = Main.ME.controller.createAccess("game");
    ca.setLeftDeadZone(0.2);
    ca.setRightDeadZone(0.2);
    createRootInLayers(Main.ME.root, Const.DP_BG);
    // Update Engine Background Color
    engine.backgroundColor = 0x0;

    resumeGameOver = false;
    scroller = new h2d.Layers();
    root.add(scroller, Const.DP_BG);
    scroller.filter = new h2d.filter.ColorMatrix(); // force rendering for pixel perfect
    camera = new Camera();
    // Turn this off to unclamp the camera and get camera working
    camera.clampToLevelBounds = false;
    msgWin = new MsgWindow();
    msgWin.hide();

    #if debug
    startInitialGame();
    #else
    title = new Title();
    #end
  }

  public function startInitialGame() {
    clearNewGameData();
    fx = new Fx();
    notify = new ui.Notification();
    notify.hide();
    hud = new ui.Hud();
    // Render ldtk level
    new Transition();
    startLevel(proj.all_levels.Level_14);

    Process.resizeAll();
    trace(Lang.t._("Game is ready."));
  }

  public static inline function exists() {
    return ME != null && !ME.destroyed;
  }

  public inline function invalidateHud() {
    if (!hud.destroyed) {
      hud.invalidate();
    }
  }

  public function nextLevel(levelId:Int, startX = -1, startY = -1) {
    level.destroy();
    // var level = proj.levels[levelId];
    var level = proj.levels.filter((lLevel) ->
      lLevel.identifier.contains('Level_${levelId}'))
      .first();
    if (level != null) {
      startLevel(level, startX, startY);
    } else {
      #if debug
      trace('Cannot find level');
      #end
    }
  }

  /** CDB file changed on disk**/
  public function onCdbReload() {}

  /**
   * Called whenever LDTk file changes on disk
   */
  @:allow(Assets)
  function onLDtkReload() {
    trace('LDTk file reloaded');
    reloadCurrentLevel();
  }

  public function reloadCurrentLevel() {
    if (level != null) {
      if (level.data != null) {
        startLevel(Assets.projData.getLevel(level.data.uid));
      }
    }
  }

  public function startLevel(ldtkLevel:LDTkProj_Level, startX = -1,
      startY = -1) {
    if (level != null) {
      level.destroy();
    }
    fx.clear();
    for (entity in Entity.ALL) {
      entity.destroy();
    }
    garbageCollectEntities();
    // Create new level
    level = new Level(ldtkLevel, startX, startY);
    // Will be using the looping mechanisms
  }

  /** Window/app resize event **/
  override function onResize() {
    super.onResize();
    scroller.setScale(Const.SCALE);
  }

  /** Garbage collect any Entity marked for destruction **/
  function garbageCollectEntities() {
    if (Entity.GC == null || Entity.GC.length == 0) return;

    for (e in Entity.GC)
      e.dispose();
    Entity.GC = [];
  }

  /** Called if game is destroyed, but only at the end of the frame **/
  override function onDispose() {
    super.onDispose();

    fx.destroy();
    for (e in Entity.ALL)
      e.destroy();
    garbageCollectEntities();
  }

  /** Loop that happens at the beginning of the frame **/
  override function preUpdate() {
    super.preUpdate();

    for (e in Entity.ALL)
      if (!e.destroyed) e.preUpdate();
  }

  /** Loop that happens at the end of the frame **/
  override function postUpdate() {
    super.postUpdate();

    for (e in Entity.ALL)
      if (!e.destroyed) e.postUpdate();
    garbageCollectEntities();
  }

  /** Main loop but limited to 30fps (so it might not be called during some frames) **/
  override function fixedUpdate() {
    super.fixedUpdate();

    for (e in Entity.ALL)
      if (!e.destroyed) e.fixedUpdate();
  }

  /** Main loop **/
  override function update() {
    super.update();

    for (e in Entity.ALL)
      if (!e.destroyed) e.update();

    if (!ui.Console.ME.isActive() && !ui.Modal.hasAny()) {
      #if hl
      // Exit
      if (ca.isKeyboardPressed(Key.ESCAPE)) if (!cd.hasSetS("exitWarn",
        3)) trace(Lang.t._("Press ESCAPE again to exit.")); else
        hxd.System.exit();
      #end

      // Restart
      if (ca.selectPressed()) {
        // Restart the level on select
        // Main.ME.startGame();
        reloadCurrentLevel();
      }
    }
  }

  public function notification(msg:String) {
    if (notify != null) {
      notify.sendMsg(msg);
    }
  }

  public function clearNewGameData() {
    SavedData.delete(CHK_COORDS);
    SavedData.delete(PERM_LIST);
    SavedData.delete(EVENT_LIST);
  }

  /**
   * Clear temporary save data when you're playing a level or
   * find a switch in the game.
   */
  public function clearTempSaveData() {
    if (SavedData.exists(CHK_COORDS)) {
      SavedData.delete(CHK_COORDS);
    }
  }

  public function savePermItem(identifier:String) {
    if (SavedData.exists(PERM_LIST)) {
      var permList = SavedData.load(PERM_LIST, {
        perms: []
      });
      permList.perms.push(identifier);
      SavedData.save(PERM_LIST, {
        perms: permList.perms
      });
    } else {
      SavedData.save(PERM_LIST, {
        perms: [identifier]
      });
    }
  }

  public function permExists(identifier:String) {
    if (SavedData.exists(PERM_LIST)) {
      var permList = SavedData.load(PERM_LIST, {
        perms: []
      });
      return permList.perms.contains(identifier);
    } else {
      return false;
    }
  }

  public function saveEvent(eventName:String) {
    if (SavedData.exists(EVENT_LIST)) {
      var eventList = SavedData.load(EVENT_LIST, {
        events: []
      });
      eventList.events.push(eventName);
      SavedData.save(EVENT_LIST, {
        events: eventList.events
      });
    } else {
      SavedData.save(EVENT_LIST, {
        events: [eventName]
      });
    }
  }

  public function eventExists(eventName:String) {
    if (SavedData.exists(EVENT_LIST)) {
      var eventList = SavedData.load(EVENT_LIST, {
        events: []
      });
      return eventList.events.contains(eventName);
    } else {
      return false;
    }
  }
}