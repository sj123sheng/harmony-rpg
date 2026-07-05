import { Direction, PlayerData, Rect, Vector2 } from '../core/GameTypes';

export function createPlayer(spawnPoint: Vector2): PlayerData {
  return {
    id: 'player',
    name: '旅人',
    position: { x: spawnPoint.x, y: spawnPoint.y },
    size: { width: 38, height: 54 },
    direction: 'down',
    speed: 180
  };
}

export function getPlayerRect(player: PlayerData): Rect {
  return {
    id: player.id,
    x: player.position.x,
    y: player.position.y,
    width: player.size.width,
    height: player.size.height
  };
}

export function directionFromVector(vector: Vector2, fallback: Direction): Direction {
  if (Math.abs(vector.x) > Math.abs(vector.y)) {
    return vector.x >= 0 ? 'right' : 'left';
  }

  if (Math.abs(vector.y) > 0) {
    return vector.y >= 0 ? 'down' : 'up';
  }

  return fallback;
}
