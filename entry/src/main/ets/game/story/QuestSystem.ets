import { DialogueEvent, QuestData, QuestPhase } from '../core/GameTypes';

export function createQuestState(template: QuestData): QuestData {
  return {
    id: template.id,
    title: template.title,
    phase: template.phase
  };
}

export function advanceQuestPhase(currentPhase: QuestPhase, event: DialogueEvent): QuestPhase {
  if (currentPhase === 'notStarted' && event === 'keeperAsked') {
    return 'askedKeeper';
  }
  if (currentPhase === 'askedKeeper' && event === 'teaMasterAsked') {
    return 'askedTeaMaster';
  }
  if (currentPhase === 'askedTeaMaster' && event === 'spiritStoneFound') {
    return 'foundSpiritStone';
  }
  if (currentPhase === 'foundSpiritStone' && event === 'spiritLampLit') {
    return 'completed';
  }
  return currentPhase;
}
