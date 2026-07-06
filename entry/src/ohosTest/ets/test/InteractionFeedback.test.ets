import { describe, expect, it } from '@ohos/hypium';
import { InteractionTarget } from '../../../main/ets/game/core/GameTypes';
import { getInteractionActionText, getInteractionPromptText } from '../../../main/ets/game/core/InteractionFeedback';

export default function interactionFeedbackTest() {
  describe('InteractionFeedback', () => {
    it('shows talk text for nearby npc targets', 0, () => {
      const target: InteractionTarget = {
        id: 'keeper',
        kind: 'npc',
        name: '守灯人',
        dialogueId: 'keeper-start',
        distance: 42
      };

      expect(getInteractionActionText(target)).assertEqual('交谈');
      expect(getInteractionPromptText(target)).assertEqual('交谈 守灯人');
    });

    it('shows specific action text for quest objects', 0, () => {
      const stone: InteractionTarget = {
        id: 'spirit-stone',
        kind: 'object',
        name: '井边灵石',
        dialogueId: 'stone-found',
        distance: 38
      };
      const lamp: InteractionTarget = {
        id: 'spirit-lamp',
        kind: 'object',
        name: '村口灵灯',
        dialogueId: 'lamp-light',
        distance: 38
      };

      expect(getInteractionActionText(stone)).assertEqual('查看');
      expect(getInteractionActionText(lamp)).assertEqual('点亮');
      expect(getInteractionPromptText(lamp)).assertEqual('点亮 村口灵灯');
    });
  });
}
