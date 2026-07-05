import { Vector2 } from './GameTypes';

export interface JoystickLayout {
  center: Vector2;
  radius: number;
  knobRadius: number;
}

export class InputController {
  private joystickPointerId: number = -1;
  private joystickVector: Vector2 = { x: 0, y: 0 };
  private interactionPressed: boolean = false;

  setJoystick(pointerId: number, point: Vector2, layout: JoystickLayout): void {
    if (this.joystickPointerId === -1) {
      this.joystickPointerId = pointerId;
    }
    if (this.joystickPointerId !== pointerId) {
      return;
    }

    const dx = point.x - layout.center.x;
    const dy = point.y - layout.center.y;
    const distance = Math.hypot(dx, dy);
    if (distance === 0) {
      this.joystickVector = { x: 0, y: 0 };
      return;
    }

    const clamped = Math.min(distance, layout.radius);
    this.joystickVector = {
      x: (dx / distance) * (clamped / layout.radius),
      y: (dy / distance) * (clamped / layout.radius)
    };
  }

  releaseJoystick(pointerId: number): void {
    if (this.joystickPointerId === pointerId) {
      this.joystickPointerId = -1;
      this.joystickVector = { x: 0, y: 0 };
    }
  }

  getMoveVector(): Vector2 {
    return { x: this.joystickVector.x, y: this.joystickVector.y };
  }

  pressInteraction(): void {
    this.interactionPressed = true;
  }

  consumeInteractionPress(): boolean {
    const pressed = this.interactionPressed;
    this.interactionPressed = false;
    return pressed;
  }
}
