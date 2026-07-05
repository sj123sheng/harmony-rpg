import { createPlayer, directionFromVector, getPlayerRect } from '../actors/Player';
import { MapData, GameStateSnapshot, InteractionTarget, PlayerData, QuestData, Vector2, ActiveDialogue, DialogueLineView } from './GameTypes';
import { VILLAGE_MAP } from '../world/VillageMap';
import { resolveMovement } from '../world/CollisionSystem';
import { findNearestInteractable } from '../world/InteractionSystem';
import { advanceDialogue, getDialogue, startDialogue } from '../story/DialogueSystem';
import { advanceQuestPhase, createQuestState } from '../story/QuestSystem';

const INTERACTION_DISTANCE = 96;

export class GameState {
  private readonly map: MapData = VILLAGE_MAP;
  private player: PlayerData = createPlayer(VILLAGE_MAP.spawnPoint);
  private quest: QuestData = createQuestState(VILLAGE_MAP.quest);
  private activeDialogue?: ActiveDialogue;
  private nearbyTarget?: InteractionTarget;

  update(deltaSeconds: number, moveVector: Vector2): void {
    if (this.activeDialogue) {
      this.refreshInteractionTarget();
      return;
    }

    const length = Math.hypot(moveVector.x, moveVector.y);
    if (length > 0) {
      const normalized: Vector2 = {
        x: moveVector.x / length,
        y: moveVector.y / length
      };
      const desiredPosition: Vector2 = {
        x: this.player.position.x + normalized.x * this.player.speed * deltaSeconds,
        y: this.player.position.y + normalized.y * this.player.speed * deltaSeconds
      };
      this.player.position = resolveMovement(getPlayerRect(this.player), desiredPosition, this.map.collisions, this.map.size);
      this.player.direction = directionFromVector(normalized, this.player.direction);
    }

    this.refreshInteractionTarget();
  }

  interact(): void {
    if (this.activeDialogue) {
      const result = advanceDialogue(this.activeDialogue, this.map);
      this.activeDialogue = result.nextDialogue;
      if (result.event) {
        this.quest.phase = advanceQuestPhase(this.quest.phase, result.event);
      }
      this.refreshInteractionTarget();
      return;
    }

    if (this.nearbyTarget) {
      this.activeDialogue = startDialogue(this.nearbyTarget.dialogueId, this.map);
    }
  }

  getCurrentDialogueLine(): DialogueLineView | undefined {
    const dialogue = getDialogue(this.activeDialogue, this.map);
    if (!dialogue || !this.activeDialogue) {
      return undefined;
    }
    return dialogue.lines[this.activeDialogue.lineIndex];
  }

  snapshot(): GameStateSnapshot {
    return {
      map: this.map,
      player: {
        id: this.player.id,
        name: this.player.name,
        position: { x: this.player.position.x, y: this.player.position.y },
        size: { width: this.player.size.width, height: this.player.size.height },
        direction: this.player.direction,
        speed: this.player.speed
      },
      quest: { id: this.quest.id, title: this.quest.title, phase: this.quest.phase },
      activeDialogue: this.activeDialogue ? { id: this.activeDialogue.id, lineIndex: this.activeDialogue.lineIndex } : undefined,
      nearbyInteractableId: this.nearbyTarget?.id
    };
  }

  private refreshInteractionTarget(): void {
    this.nearbyTarget = findNearestInteractable(
      this.player,
      this.map.npcs,
      this.map.objects,
      INTERACTION_DISTANCE,
      this.quest.phase
    );
  }
}
