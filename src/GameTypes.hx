/**
 * Game enemy types
 */
enum EnemyTypes {
  Ziggle;
  Sslug;
  Spawner;
}

/**
 * Coordinates in game
 */
typedef Coords = {
  var x:Int;
  var y:Int;
}

typedef PlayerState = {
  unlockedDash:Bool,
  unlockedDoubleJump:Bool,
  levelId:Int,
  health:Int,
  keys:Int
}

/**
 * Label Constants
 */
enum abstract LC(String) from String to String {
  var CHK_COORDS:String = 'CheckpointCoords';
  var SETTINGS:String = 'Settings';
  var PLAYER_INFO:String = 'PlayerInfo';
  var KNOCKBACK:String = 'Knockback';
}