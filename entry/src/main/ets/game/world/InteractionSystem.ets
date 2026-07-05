import {
  InteractionTarget,
  InteractableObjectData,
  NpcData,
  PlayerData,
  QuestPhase
} from '../core/GameTypes';
import { resolveDialogueByPhase } from '../actors/Npc';

export function findNearestInteractable(
  player: PlayerData,
  npcs: NpcData[],
  objects: InteractableObjectData[],
  maxDistance: number,
  phase: QuestPhase
): InteractionTarget | undefined {
  const candidates: InteractionTarget[] = [];

  npcs.forEach((npc) => {
    candidates.push({
      id: npc.id,
      kind: 'npc',
      name: npc.name,
      dialogueId: resolveDialogueByPhase(npc.dialogueByPhase, phase, npc.fallbackDialogueId),
      distance: distanceBetweenCenters(player, npc)
    });
  });

  objects.forEach((object) => {
    candidates.push({
      id: object.id,
      kind: 'object',
      name: object.name,
      dialogueId: resolveDialogueByPhase(object.dialogueByPhase, phase, object.fallbackDialogueId),
      distance: distanceBetweenCenters(player, object)
    });
  });

  return candidates
    .filter((target) => target.distance <= maxDistance)
    .sort((a, b) => a.distance - b.distance)[0];
}

function distanceBetweenCenters(a: PlayerData, b: NpcData | InteractableObjectData): number {
  const ax = a.position.x + a.size.width / 2;
  const ay = a.position.y + a.size.height / 2;
  const bx = b.position.x + b.size.width / 2;
  const by = b.position.y + b.size.height / 2;
  return Math.hypot(ax - bx, ay - by);
}
