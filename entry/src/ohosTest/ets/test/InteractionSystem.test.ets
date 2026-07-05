import { describe, expect, it } from '@ohos/hypium';
import { findNearestInteractable } from '../../../main/ets/game/world/InteractionSystem';

export default function interactionSystemTest() {
  describe('InteractionSystem', () => {
    it('selects the closest interactable inside the distance limit', 0, () => {
      const target = findNearestInteractable(
        {
          id: 'player',
          name: '旅人',
          position: { x: 100, y: 100 },
          size: { width: 40, height: 50 },
          direction: 'down',
          speed: 180
        },
        [
          {
            id: 'keeper',
            name: '守灯人',
            position: { x: 135, y: 100 },
            size: { width: 40, height: 50 },
            direction: 'left',
            dialogueByPhase: { notStarted: 'keeper-start' },
            fallbackDialogueId: 'keeper-default'
          }
        ],
        [],
        90,
        'notStarted'
      );
      expect(target?.id).assertEqual('keeper');
    });
  });
}
