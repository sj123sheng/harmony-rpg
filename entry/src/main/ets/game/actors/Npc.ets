import { DialogueByPhase, NpcData, QuestPhase } from '../core/GameTypes';

export function resolveNpcDialogueId(npc: NpcData, phase: QuestPhase): string {
  return resolveDialogueByPhase(npc.dialogueByPhase, phase, npc.fallbackDialogueId);
}

export function resolveDialogueByPhase(dialogues: DialogueByPhase, phase: QuestPhase, fallbackDialogueId: string): string {
  if (phase === 'notStarted' && dialogues.notStarted !== undefined) {
    return dialogues.notStarted;
  }
  if (phase === 'askedKeeper' && dialogues.askedKeeper !== undefined) {
    return dialogues.askedKeeper;
  }
  if (phase === 'askedTeaMaster' && dialogues.askedTeaMaster !== undefined) {
    return dialogues.askedTeaMaster;
  }
  if (phase === 'foundSpiritStone' && dialogues.foundSpiritStone !== undefined) {
    return dialogues.foundSpiritStone;
  }
  if (phase === 'completed' && dialogues.completed !== undefined) {
    return dialogues.completed;
  }
  return fallbackDialogueId;
}
