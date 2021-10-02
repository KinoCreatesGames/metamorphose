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

/**
 * Label Constants
 */
enum abstract LC(String) from String to String {
  var CHK_COORDS:String = 'CheckpointCoords';
  var SETTINGS:String = 'Settings';
  var KNOCKBACK:String = 'Knockback';
}