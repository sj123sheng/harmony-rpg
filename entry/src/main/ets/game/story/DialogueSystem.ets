import { ActiveDialogue, DialogueAdvanceResult, DialogueData, MapData } from '../core/GameTypes';

export function startDialogue(dialogueId: string, map: MapData): ActiveDialogue {
  if (findDialogue(dialogueId, map) === undefined) {
    return {
      id: 'missing-dialogue',
      lineIndex: 0
    };
  }

  return {
    id: dialogueId,
    lineIndex: 0
  };
}

export function getDialogue(activeDialogue: ActiveDialogue | undefined, map: MapData): DialogueData | undefined {
  if (!activeDialogue) {
    return undefined;
  }

  const dialogue = findDialogue(activeDialogue.id, map);
  if (dialogue !== undefined) {
    return dialogue;
  }

  return {
    id: 'missing-dialogue',
    lines: [
      {
        speaker: '旁白',
        text: '这里暂时没有可用的对话。'
      }
    ]
  };
}

export function advanceDialogue(activeDialogue: ActiveDialogue, map: MapData): DialogueAdvanceResult {
  const dialogue = getDialogue(activeDialogue, map);
  if (!dialogue) {
    return {};
  }

  const nextIndex = activeDialogue.lineIndex + 1;
  if (nextIndex < dialogue.lines.length) {
    return {
      nextDialogue: {
        id: activeDialogue.id,
        lineIndex: nextIndex
      }
    };
  }

  return {
    event: dialogue.event
  };
}

function findDialogue(dialogueId: string, map: MapData): DialogueData | undefined {
  for (let index = 0; index < map.dialogues.length; index++) {
    if (map.dialogues[index].id === dialogueId) {
      return map.dialogues[index];
    }
  }
  return undefined;
}
