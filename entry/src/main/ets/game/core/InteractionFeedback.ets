import { InteractionTarget } from './GameTypes';

export function getInteractionActionText(target: InteractionTarget | undefined): string {
  if (!target) {
    return '交互';
  }

  if (target.kind === 'npc') {
    return '交谈';
  }

  if (target.id === 'spirit-lamp') {
    return '点亮';
  }

  return '查看';
}

export function getInteractionPromptText(target: InteractionTarget | undefined): string {
  if (!target) {
    return '';
  }

  return `${getInteractionActionText(target)} ${target.name}`;
}
