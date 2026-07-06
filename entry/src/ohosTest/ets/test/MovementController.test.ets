import { describe, expect, it } from '@ohos/hypium';
import { MovementController } from '../../../main/ets/game/core/MovementController';

export default function movementControllerTest() {
  describe('MovementController', () => {
    it('ignores tiny joystick input inside the dead zone', 0, () => {
      const movement = new MovementController();
      const velocity = movement.update(0.016, { x: 0.08, y: 0 }, 180);

      expect(velocity.x).assertEqual(0);
      expect(velocity.y).assertEqual(0);
    });

    it('keeps shallow joystick input slower than full push', 0, () => {
      const movement = new MovementController();
      const shallow = movement.update(1, { x: 0.5, y: 0 }, 180);

      expect(shallow.x).assertLess(120);
      expect(shallow.x).assertLarger(0);
      expect(shallow.y).assertEqual(0);
    });

    it('eases velocity down after releasing the joystick', 0, () => {
      const movement = new MovementController();
      movement.update(1, { x: 1, y: 0 }, 180);
      const braking = movement.update(0.016, { x: 0, y: 0 }, 180);

      expect(braking.x).assertLarger(0);
      expect(braking.x).assertLess(180);
      expect(braking.y).assertEqual(0);
    });
  });
}
