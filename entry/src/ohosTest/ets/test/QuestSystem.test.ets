import { describe, expect, it } from '@ohos/hypium';
import { advanceQuestPhase } from '../../../main/ets/game/story/QuestSystem';

export default function questSystemTest() {
  describe('QuestSystem', () => {
    it('advances the spirit lamp quest in order', 0, () => {
      expect(advanceQuestPhase('notStarted', 'keeperAsked')).assertEqual('askedKeeper');
      expect(advanceQuestPhase('askedKeeper', 'teaMasterAsked')).assertEqual('askedTeaMaster');
      expect(advanceQuestPhase('askedTeaMaster', 'spiritStoneFound')).assertEqual('foundSpiritStone');
      expect(advanceQuestPhase('foundSpiritStone', 'spiritLampLit')).assertEqual('completed');
    });
  });
}
