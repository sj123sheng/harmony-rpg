export type Direction = 'down' | 'left' | 'right' | 'up';
export type InteractableKind = 'npc' | 'object';
export type QuestPhase = 'notStarted' | 'askedKeeper' | 'askedTeaMaster' | 'foundSpiritStone' | 'completed';

export interface Vector2 {
  x: number;
  y: number;
}

export interface Size {
  width: number;
  height: number;
}

export interface Rect {
  id: string;
  x: number;
  y: number;
  width: number;
  height: number;
}

export interface ActorData {
  id: string;
  name: string;
  position: Vector2;
  size: Size;
  direction: Direction;
}

export interface PlayerData extends ActorData {
  speed: number;
}

export interface DialogueByPhase {
  notStarted?: string;
  askedKeeper?: string;
  askedTeaMaster?: string;
  foundSpiritStone?: string;
  completed?: string;
}

export interface NpcData extends ActorData {
  dialogueByPhase: DialogueByPhase;
  fallbackDialogueId: string;
}

export interface InteractableObjectData {
  id: string;
  name: string;
  kind: 'spiritStone' | 'spiritLamp';
  position: Vector2;
  size: Size;
  dialogueByPhase: DialogueByPhase;
  fallbackDialogueId: string;
}

export interface DialogueLine {
  speaker: string;
  text: string;
}

export interface DialogueData {
  id: string;
  lines: DialogueLine[];
  event?: DialogueEvent;
}

export type DialogueEvent =
  | 'keeperAsked'
  | 'teaMasterAsked'
  | 'spiritStoneFound'
  | 'spiritLampLit';

export interface QuestData {
  id: string;
  title: string;
  phase: QuestPhase;
}

export interface MapData {
  id: string;
  name: string;
  size: Size;
  tileSize: number;
  spawnPoint: Vector2;
  collisions: Rect[];
  npcs: NpcData[];
  objects: InteractableObjectData[];
  dialogues: DialogueData[];
  quest: QuestData;
}

export interface ActiveDialogue {
  id: string;
  lineIndex: number;
}

export interface GameStateSnapshot {
  map: MapData;
  player: PlayerData;
  quest: QuestData;
  activeDialogue?: ActiveDialogue;
  nearbyInteractableId?: string;
}

export interface InteractionTarget {
  id: string;
  kind: InteractableKind;
  name: string;
  dialogueId: string;
  distance: number;
}

export interface DialogueAdvanceResult {
  nextDialogue?: ActiveDialogue;
  event?: DialogueEvent;
}

export interface DialogueLineView {
  speaker: string;
  text: string;
}

export interface RenderObjectSource {
  id: string;
  position: Vector2;
  size: Size;
}
