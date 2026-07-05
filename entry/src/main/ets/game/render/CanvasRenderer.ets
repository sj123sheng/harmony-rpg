import { Direction, GameStateSnapshot, InteractableObjectData, NpcData, QuestPhase, Rect } from '../core/GameTypes';

export interface Viewport {
  width: number;
  height: number;
}

interface WorldTransform {
  scale: number;
  offsetX: number;
  offsetY: number;
}

const COLORS = {
  screen: '#DCE8BF',
  grass: '#DDE9BC',
  grassDeep: '#BDD19A',
  grassLight: '#EAF2CB',
  road: '#EED8A5',
  roadShade: '#DFC286',
  bamboo: '#6D9A6B',
  bambooDark: '#4F7F58',
  bambooStem: '#7FA36A',
  teaWall: '#B86E4B',
  teaWallShade: '#99543E',
  teaRoof: '#7D3F32',
  teaRoofDark: '#5F2E28',
  wellStone: '#7A8E96',
  wellInner: '#4C5E66',
  wood: '#9A6A42'
};

export class CanvasRenderer {
  render(context: CanvasRenderingContext2D, snapshot: GameStateSnapshot, viewport: Viewport): void {
    context.clearRect(0, 0, viewport.width, viewport.height);
    this.drawScreenBackground(context, viewport);

    const transform = this.resolveWorldTransform(snapshot, viewport);
    context.save();
    context.translate(transform.offsetX, transform.offsetY);
    context.scale(transform.scale, transform.scale);

    this.drawGroundLayer(context, snapshot);
    this.drawSceneLayer(context, snapshot);
    this.drawQuestObjects(context, snapshot.map.objects, snapshot.nearbyInteractableId, snapshot.quest.phase);
    this.drawNpcs(context, snapshot.map.npcs, snapshot.nearbyInteractableId);
    this.drawPlayer(
      context,
      snapshot.player.position.x,
      snapshot.player.position.y,
      snapshot.player.size.width,
      snapshot.player.size.height,
      snapshot.player.direction
    );
    context.restore();

    this.drawQuestHint(context, snapshot.quest.title, snapshot.quest.phase, viewport);
  }

  private resolveWorldTransform(snapshot: GameStateSnapshot, viewport: Viewport): WorldTransform {
    const scaleX = viewport.width / snapshot.map.size.width;
    const scaleY = viewport.height / snapshot.map.size.height;
    const scale = Math.min(scaleX, scaleY);
    const drawnWidth = snapshot.map.size.width * scale;
    const drawnHeight = snapshot.map.size.height * scale;
    return {
      scale: scale,
      offsetX: (viewport.width - drawnWidth) / 2,
      offsetY: (viewport.height - drawnHeight) / 2
    };
  }

  private drawScreenBackground(context: CanvasRenderingContext2D, viewport: Viewport): void {
    context.fillStyle = COLORS.screen;
    context.fillRect(0, 0, viewport.width, viewport.height);
  }

  private drawGroundLayer(context: CanvasRenderingContext2D, snapshot: GameStateSnapshot): void {
    context.fillStyle = COLORS.grass;
    context.fillRect(0, 0, snapshot.map.size.width, snapshot.map.size.height);

    context.fillStyle = COLORS.grassLight;
    context.fillRect(96, 80, snapshot.map.size.width - 192, snapshot.map.size.height - 150);

    context.fillStyle = COLORS.road;
    context.fillRect(90, 112, 1120, 220);
    context.fillRect(90, 520, 1120, 145);

    context.fillStyle = COLORS.roadShade;
    for (let x = 120; x < 1180; x += 70) {
      context.fillRect(x, 628, 38, 7);
    }

    context.fillStyle = 'rgba(93, 117, 70, 0.18)';
    for (let x = 135; x < snapshot.map.size.width - 80; x += 95) {
      for (let y = 95; y < snapshot.map.size.height - 85; y += 80) {
        context.fillRect(x, y, 4, 2);
      }
    }

    context.fillStyle = COLORS.wood;
    context.fillRect(0, snapshot.map.size.height - 55, snapshot.map.size.width, 55);
    context.fillStyle = 'rgba(72, 48, 30, 0.32)';
    for (let x = 0; x < snapshot.map.size.width; x += 72) {
      context.fillRect(x, snapshot.map.size.height - 52, 8, 50);
    }
  }

  private drawSceneLayer(context: CanvasRenderingContext2D, snapshot: GameStateSnapshot): void {
    context.fillStyle = COLORS.grassDeep;
    context.fillRect(0, 0, 90, snapshot.map.size.height);
    context.fillStyle = '#C9DFAA';
    context.fillRect(0, 0, snapshot.map.size.width, 70);

    this.drawBambooBorder(context);
    this.drawTeaHouse(context);
    this.drawWell(context);
  }

  private drawBambooBorder(context: CanvasRenderingContext2D): void {
    for (let y = 95; y < 620; y += 82) {
      context.fillStyle = COLORS.bambooStem;
      context.fillRect(39, y - 38, 7, 76);
      context.fillStyle = COLORS.bamboo;
      context.beginPath();
      context.ellipse(45, y, 25, 43, 0.24, 0, Math.PI * 2);
      context.fill();
      context.fillStyle = COLORS.bambooDark;
      context.beginPath();
      context.ellipse(55, y + 5, 13, 32, 0.24, 0, Math.PI * 2);
      context.fill();
    }
  }

  private drawTeaHouse(context: CanvasRenderingContext2D): void {
    context.fillStyle = 'rgba(67, 37, 30, 0.18)';
    context.fillRect(752, 292, 290, 22);
    this.roundRect(context, { id: 'tea-house-wall', x: 740, y: 118, width: 320, height: 192 }, COLORS.teaWall, 14);
    context.fillStyle = COLORS.teaWallShade;
    context.fillRect(780, 118, 8, 192);
    context.fillRect(1018, 118, 8, 192);
    this.roundRect(context, { id: 'tea-roof', x: 710, y: 70, width: 380, height: 82 }, COLORS.teaRoof, 18);
    context.fillStyle = COLORS.teaRoofDark;
    context.fillRect(710, 128, 380, 24);
    context.fillStyle = '#F0D8A8';
    context.fillRect(830, 178, 70, 132);
    context.fillStyle = '#6E3E32';
    context.fillRect(850, 198, 30, 112);
    context.fillStyle = '#F3E0B6';
    context.fillRect(928, 176, 62, 44);
    context.fillStyle = 'rgba(92, 50, 35, 0.42)';
    context.fillRect(928, 197, 62, 5);
  }

  private drawWell(context: CanvasRenderingContext2D): void {
    context.fillStyle = 'rgba(45, 57, 61, 0.22)';
    context.beginPath();
    context.ellipse(605, 462, 62, 18, 0, 0, Math.PI * 2);
    context.fill();
    this.roundRect(context, { id: 'well-base', x: 550, y: 360, width: 110, height: 96 }, COLORS.wellStone, 16);
    context.fillStyle = COLORS.wellInner;
    context.beginPath();
    context.ellipse(605, 392, 38, 24, 0, 0, Math.PI * 2);
    context.fill();
    context.fillStyle = '#AFC1C6';
    context.beginPath();
    context.ellipse(605, 386, 42, 20, 0, 0, Math.PI * 2);
    context.fill();
    context.fillStyle = COLORS.wellInner;
    context.beginPath();
    context.ellipse(605, 386, 28, 12, 0, 0, Math.PI * 2);
    context.fill();
  }

  private drawQuestObjects(
    context: CanvasRenderingContext2D,
    objects: InteractableObjectData[],
    nearbyInteractableId: string | undefined,
    phase: QuestPhase
  ): void {
    const lampCompleted = phase === 'completed';
    objects.forEach((object) => {
      const highlighted = nearbyInteractableId === object.id;
      if (object.kind === 'spiritStone') {
        this.drawSpiritStone(context, object, highlighted, phase);
      } else {
        this.drawSpiritLamp(context, object, highlighted, lampCompleted, phase);
      }
    });
  }

  private drawSpiritStone(
    context: CanvasRenderingContext2D,
    object: InteractableObjectData,
    highlighted: boolean,
    phase: QuestPhase
  ): void {
    const centerX = object.position.x + object.size.width / 2;
    const centerY = object.position.y + object.size.height / 2;
    const active = phase === 'askedTeaMaster' || phase === 'foundSpiritStone';
    context.fillStyle = 'rgba(45, 67, 82, 0.22)';
    context.beginPath();
    context.ellipse(centerX, object.position.y + object.size.height + 5, 33, 9, 0, 0, Math.PI * 2);
    context.fill();
    if (active) {
      context.fillStyle = highlighted ? 'rgba(153, 220, 255, 0.48)' : 'rgba(120, 190, 230, 0.28)';
      context.beginPath();
      context.arc(centerX, centerY, highlighted ? 42 : 32, 0, Math.PI * 2);
      context.fill();
    }
    context.fillStyle = active ? '#87B5C8' : '#738A95';
    context.beginPath();
    context.moveTo(centerX, object.position.y);
    context.lineTo(object.position.x + object.size.width, centerY + 4);
    context.lineTo(centerX + 10, object.position.y + object.size.height);
    context.lineTo(object.position.x + 7, centerY + 8);
    context.closePath();
    context.fill();
    if (highlighted) {
      this.drawInteractionHighlight(context, centerX, centerY, 42);
    }
  }

  private drawSpiritLamp(
    context: CanvasRenderingContext2D,
    object: InteractableObjectData,
    highlighted: boolean,
    lampCompleted: boolean,
    phase: QuestPhase
  ): void {
    const centerX = object.position.x + object.size.width / 2;
    const flameY = object.position.y + 18;
    const ready = phase === 'foundSpiritStone';
    if (lampCompleted) {
      context.fillStyle = 'rgba(246, 200, 95, 0.30)';
      context.beginPath();
      context.arc(centerX, flameY + 8, 64, 0, Math.PI * 2);
      context.fill();
    }
    context.fillStyle = '#5E4A3A';
    context.fillRect(centerX - 6, object.position.y + 28, 12, 46);
    context.fillStyle = '#6B5A4A';
    context.fillRect(object.position.x + 8, object.position.y + 62, object.size.width - 16, 16);
    context.fillStyle = lampCompleted ? '#F6C85F' : ready ? '#D9A95A' : '#3F3A34';
    context.beginPath();
    context.ellipse(centerX, flameY, 15, 22, 0, 0, Math.PI * 2);
    context.fill();
    context.fillStyle = lampCompleted ? '#FFF0A5' : ready ? '#F5D28A' : '#2F302C';
    context.beginPath();
    context.ellipse(centerX, flameY, 7, 12, 0, 0, Math.PI * 2);
    context.fill();
    if (highlighted) {
      this.drawInteractionHighlight(context, centerX, object.position.y + 38, 45);
    }
  }

  private drawNpcs(context: CanvasRenderingContext2D, npcs: NpcData[], nearbyInteractableId: string | undefined): void {
    npcs.forEach((npc) => {
      const highlighted = nearbyInteractableId === npc.id;
      this.drawNpc(context, npc, highlighted);
    });
  }

  private drawNpc(context: CanvasRenderingContext2D, npc: NpcData, highlighted: boolean): void {
    const color = this.getNpcColor(npc.id);
    const x = npc.position.x;
    const y = npc.position.y;
    const width = npc.size.width;
    const height = npc.size.height;
    context.fillStyle = 'rgba(35, 31, 24, 0.22)';
    context.beginPath();
    context.ellipse(x + width / 2, y + height + 4, width / 2, 8, 0, 0, Math.PI * 2);
    context.fill();
    if (highlighted) {
      this.drawInteractionHighlight(context, x + width / 2, y + height / 2, 38);
    }
    this.roundRect(context, { id: `${npc.id}-body`, x, y: y + 18, width, height: height - 12 }, color, 12);
    context.fillStyle = '#F2CDAA';
    context.beginPath();
    context.arc(x + width / 2, y + 15, 13, 0, Math.PI * 2);
    context.fill();
    context.fillStyle = 'rgba(39, 30, 24, 0.45)';
    context.fillRect(x + 9, y + 12, width - 18, 4);
    context.fillStyle = 'rgba(54, 38, 30, 0.58)';
    if (npc.direction === 'left') {
      context.fillRect(x + 9, y + 17, 4, 3);
    } else if (npc.direction === 'right') {
      context.fillRect(x + width - 13, y + 17, 4, 3);
    } else {
      const faceY = npc.direction === 'up' ? y + 12 : y + 18;
      context.fillRect(x + width / 2 - 2, faceY, 4, 3);
    }
  }

  private drawInteractionHighlight(context: CanvasRenderingContext2D, centerX: number, centerY: number, radius: number): void {
    context.strokeStyle = 'rgba(255, 244, 184, 0.92)';
    context.lineWidth = 4;
    context.beginPath();
    context.arc(centerX, centerY, radius, 0, Math.PI * 2);
    context.stroke();
    context.strokeStyle = 'rgba(255, 255, 255, 0.68)';
    context.lineWidth = 2;
    context.beginPath();
    context.arc(centerX, centerY, radius + 6, 0, Math.PI * 2);
    context.stroke();
  }

  private drawPlayer(
    context: CanvasRenderingContext2D,
    x: number,
    y: number,
    width: number,
    height: number,
    direction: Direction
  ): void {
    context.fillStyle = 'rgba(35, 31, 24, 0.24)';
    context.beginPath();
    context.ellipse(x + width / 2, y + height + 4, width / 2, 9, 0, 0, Math.PI * 2);
    context.fill();

    this.roundRect(context, { id: 'player-body', x, y: y + 20, width, height: height - 16 }, '#3F7F76', 14);
    context.fillStyle = '#F7D7B5';
    const headOffsetX = direction === 'left' ? -3 : direction === 'right' ? 3 : 0;
    const headOffsetY = direction === 'up' ? -2 : direction === 'down' ? 3 : 0;
    context.beginPath();
    context.arc(x + width / 2 + headOffsetX, y + 14 + headOffsetY, 14, 0, Math.PI * 2);
    context.fill();

    context.fillStyle = '#234E49';
    if (direction === 'left') {
      context.fillRect(x + 9, y + 15, 4, 3);
    } else if (direction === 'right') {
      context.fillRect(x + width - 13, y + 15, 4, 3);
    } else {
      context.fillRect(x + width / 2 - 2, y + 16 + headOffsetY, 4, 3);
    }
  }

  private drawQuestHint(context: CanvasRenderingContext2D, title: string, phase: QuestPhase, viewport: Viewport): void {
    const panelWidth = Math.min(310, Math.max(240, viewport.width - 56));
    context.fillStyle = 'rgba(255, 252, 238, 0.82)';
    context.fillRect(24, 20, panelWidth, 66);
    context.strokeStyle = 'rgba(94, 78, 47, 0.20)';
    context.lineWidth = 1;
    context.strokeRect(24, 20, panelWidth, 66);
    context.fillStyle = '#2F3326';
    context.font = '18px sans-serif';
    context.fillText(title, 42, 47);
    context.fillStyle = '#596044';
    context.font = '14px sans-serif';
    context.fillText(getQuestPhaseLabel(phase), 42, 70);
  }

  private roundRect(context: CanvasRenderingContext2D, rect: Rect, color: string, radius: number): void {
    context.fillStyle = color;
    context.fillRect(rect.x, rect.y, rect.width, rect.height);
  }

  private getNpcColor(npcId: string): string {
    if (npcId === 'keeper') {
      return '#4D6C8B';
    }
    if (npcId === 'tea-master') {
      return '#8A5A44';
    }
    if (npcId === 'child') {
      return '#D47A76';
    }
    return '#6C6C6C';
  }
}

function getQuestPhaseLabel(phase: QuestPhase): string {
  const labels: Record<string, string> = {
    notStarted: '询问守灯人',
    askedKeeper: '前往茶铺',
    askedTeaMaster: '寻找井边灵石',
    foundSpiritStone: '点亮村口灵灯',
    completed: '灵灯已点亮'
  };
  return labels[phase] ?? '继续探索';
}
