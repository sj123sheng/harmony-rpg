import { describe, expect, it } from '@ohos/hypium';
import { resolveMovement } from '../../../main/ets/game/world/CollisionSystem';

export default function collisionSystemTest() {
  describe('CollisionSystem', () => {
    it('blocks movement when the player would overlap an obstacle', 0, () => {
      const result = resolveMovement(
        { id: 'player', x: 20, y: 20, width: 20, height: 20 },
        { x: 35, y: 20 },
        [{ id: 'wall', x: 45, y: 10, width: 20, height: 60 }],
        { width: 200, height: 200 }
      );
      expect(result.x).assertEqual(20);
      expect(result.y).assertEqual(20);
    });
  });
}
