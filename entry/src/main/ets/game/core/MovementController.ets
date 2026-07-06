import { Vector2 } from './GameTypes';

const JOYSTICK_DEAD_ZONE: number = 0.12;
const INPUT_CURVE_POWER: number = 1.35;
const ACCELERATION_PER_SECOND: number = 12;
const DECELERATION_PER_SECOND: number = 16;
const STOP_SPEED: number = 1;

export class MovementController {
  private velocity: Vector2 = { x: 0, y: 0 };

  update(deltaSeconds: number, input: Vector2, maxSpeed: number): Vector2 {
    const target = this.resolveTargetVelocity(input, maxSpeed);
    const rate = this.isMoving(target) ? ACCELERATION_PER_SECOND : DECELERATION_PER_SECOND;
    const blend = Math.min(1, deltaSeconds * rate);

    this.velocity = {
      x: this.velocity.x + (target.x - this.velocity.x) * blend,
      y: this.velocity.y + (target.y - this.velocity.y) * blend
    };

    if (!this.isMoving(target) && Math.hypot(this.velocity.x, this.velocity.y) < STOP_SPEED) {
      this.velocity = { x: 0, y: 0 };
    }

    return { x: this.velocity.x, y: this.velocity.y };
  }

  private resolveTargetVelocity(input: Vector2, maxSpeed: number): Vector2 {
    const length = Math.min(1, Math.hypot(input.x, input.y));
    if (length <= JOYSTICK_DEAD_ZONE) {
      return { x: 0, y: 0 };
    }

    const normalizedPower = (length - JOYSTICK_DEAD_ZONE) / (1 - JOYSTICK_DEAD_ZONE);
    const curvedPower = Math.pow(normalizedPower, INPUT_CURVE_POWER);
    const speed = maxSpeed * curvedPower;

    return {
      x: input.x / length * speed,
      y: input.y / length * speed
    };
  }

  private isMoving(vector: Vector2): boolean {
    return vector.x !== 0 || vector.y !== 0;
  }
}
