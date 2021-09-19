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
	 * Project file for LDtk in here.
	 */
	public var proj:LDTkProj;

	public var title:Title;

	public function new() {
		super(Main.ME);
		ME = this;
		proj = new LDTkProj();
		ca = Main.ME.controller.createAccess("game");
		ca.setLeftDeadZone(0.2);
		ca.setRightDeadZone(0.2);
		createRootInLayers(Main.ME.root, Const.DP_BG);

		scroller = new h2d.Layers();
		root.add(scroller, Const.DP_BG);
		scroller.filter = new h2d.filter.ColorMatrix(); // force rendering for pixel perfect
		camera = new Camera();
		title = new Title();
	}

	public function startInitialGame() {
		fx = new Fx();
		// Render ldtk level
		startLevel(proj.all_levels.Level_0);
		hud = new ui.Hud();

		Process.resizeAll();
		trace(Lang.t._("Game is ready."));
	}

	public static inline function exists() {
		return ME != null && !ME.destroyed;
	}

	/** CDB file changed on disk**/
	public function onCdbReload() {}

	/**
	 * Called whenever LDTk file changes on disk
	 */
	@:allow(Assets)
	function onLDtkReload() {
		trace('LDTk file reloaded');
		if (level != null) {
			if (level.data != null) {
				startLevel(Assets.projData.getLevel(level.data.uid));
			}
		}
	}

	public function startLevel(ldtkLevel:LDTkProj_Level) {
		if (level != null) {
			level.destroy();
		}
		fx.clear();
		for (entity in Entity.ALL) {
			entity.destroy();
		}
		garbageCollectEntities();
		// Create new level
		level = new Level(ldtkLevel);
		// Will be using the looping mechanisms
	}

	/** Window/app resize event **/
	override function onResize() {
		super.onResize();
		scroller.setScale(Const.SCALE);
	}

	/** Garbage collect any Entity marked for destruction **/
	function garbageCollectEntities() {
		if (Entity.GC == null || Entity.GC.length == 0)
			return;

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
			if (!e.destroyed)
				e.preUpdate();
	}

	/** Loop that happens at the end of the frame **/
	override function postUpdate() {
		super.postUpdate();

		for (e in Entity.ALL)
			if (!e.destroyed)
				e.postUpdate();
		garbageCollectEntities();
	}

	/** Main loop but limited to 30fps (so it might not be called during some frames) **/
	override function fixedUpdate() {
		super.fixedUpdate();

		for (e in Entity.ALL)
			if (!e.destroyed)
				e.fixedUpdate();
	}

	/** Main loop **/
	override function update() {
		super.update();

		for (e in Entity.ALL)
			if (!e.destroyed)
				e.update();

		if (!ui.Console.ME.isActive() && !ui.Modal.hasAny()) {
			#if hl
			// Exit
			if (ca.isKeyboardPressed(Key.ESCAPE))
				if (!cd.hasSetS("exitWarn", 3))
					trace(Lang.t._("Press ESCAPE again to exit."));
				else
					hxd.System.exit();
			#end

			// Restart
			if (ca.selectPressed())
				Main.ME.startGame();
		}
	}
}
