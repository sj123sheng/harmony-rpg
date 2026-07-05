import { Rect, Size, Vector2 } from '../core/GameTypes';

export function rectsOverlap(a: Rect, b: Rect): boolean {
  return a.x < b.x + b.width &&
    a.x + a.width > b.x &&
    a.y < b.y + b.height &&
    a.y + a.height > b.y;
}

export function resolveMovement(actor: Rect, desiredPosition: Vector2, collisions: Rect[], bounds: Size): Vector2 {
  const nextX: Rect = {
    id: actor.id,
    x: desiredPosition.x,
    y: actor.y,
    width: actor.width,
    height: actor.height
  };

  let resolvedX = desiredPosition.x;
  if (isOutOfBounds(nextX, bounds) || collisions.some((rect) => rectsOverlap(nextX, rect))) {
    resolvedX = actor.x;
  }

  const nextY: Rect = {
    id: actor.id,
    x: resolvedX,
    y: desiredPosition.y,
    width: actor.width,
    height: actor.height
  };

  let resolvedY = desiredPosition.y;
  if (isOutOfBounds(nextY, bounds) || collisions.some((rect) => rectsOverlap(nextY, rect))) {
    resolvedY = actor.y;
  }

  return { x: resolvedX, y: resolvedY };
}

function isOutOfBounds(rect: Rect, bounds: Size): boolean {
  return rect.x < 0 ||
    rect.y < 0 ||
    rect.x + rect.width > bounds.width ||
    rect.y + rect.height > bounds.height;
}
