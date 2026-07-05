import { MapData } from '../core/GameTypes';

export const VILLAGE_MAP: MapData = {
  id: 'mist-village',
  name: '雾竹村',
  size: { width: 1280, height: 720 },
  tileSize: 40,
  spawnPoint: { x: 240, y: 520 },
  collisions: [
    { id: 'tea-house', x: 760, y: 120, width: 280, height: 190 },
    { id: 'bamboo-left', x: 0, y: 0, width: 90, height: 720 },
    { id: 'bamboo-top', x: 0, y: 0, width: 1280, height: 70 },
    { id: 'well', x: 560, y: 380, width: 90, height: 90 },
    { id: 'stone-lamp-base', x: 1010, y: 470, width: 80, height: 80 },
    { id: 'fence-bottom', x: 0, y: 665, width: 1280, height: 55 }
  ],
  npcs: [
    {
      id: 'keeper',
      name: '守灯人',
      position: { x: 930, y: 500 },
      size: { width: 42, height: 58 },
      direction: 'left',
      fallbackDialogueId: 'keeper-default',
      dialogueByPhase: {
        notStarted: 'keeper-start',
        askedKeeper: 'keeper-remind',
        askedTeaMaster: 'keeper-remind',
        foundSpiritStone: 'keeper-ready',
        completed: 'keeper-done'
      }
    },
    {
      id: 'tea-master',
      name: '茶铺老板',
      position: { x: 820, y: 340 },
      size: { width: 44, height: 56 },
      direction: 'down',
      fallbackDialogueId: 'tea-default',
      dialogueByPhase: {
        notStarted: 'tea-default',
        askedKeeper: 'tea-clue',
        askedTeaMaster: 'tea-after',
        foundSpiritStone: 'tea-after',
        completed: 'tea-done'
      }
    },
    {
      id: 'child',
      name: '阿梨',
      position: { x: 390, y: 310 },
      size: { width: 38, height: 50 },
      direction: 'right',
      fallbackDialogueId: 'child-default',
      dialogueByPhase: {
        notStarted: 'child-default',
        askedKeeper: 'child-hint',
        askedTeaMaster: 'child-hint',
        foundSpiritStone: 'child-lamp',
        completed: 'child-done'
      }
    }
  ],
  objects: [
    {
      id: 'spirit-stone',
      name: '井边灵石',
      kind: 'spiritStone',
      position: { x: 615, y: 350 },
      size: { width: 52, height: 42 },
      fallbackDialogueId: 'stone-silent',
      dialogueByPhase: {
        askedTeaMaster: 'stone-found',
        foundSpiritStone: 'stone-found',
        completed: 'stone-quiet'
      }
    },
    {
      id: 'spirit-lamp',
      name: '村口灵灯',
      kind: 'spiritLamp',
      position: { x: 1045, y: 440 },
      size: { width: 60, height: 80 },
      fallbackDialogueId: 'lamp-dark',
      dialogueByPhase: {
        foundSpiritStone: 'lamp-light',
        completed: 'lamp-bright'
      }
    }
  ],
  dialogues: [
    {
      id: 'keeper-start',
      event: 'keeperAsked',
      lines: [
        { speaker: '守灯人', text: '村口的灵灯忽然熄了，雾气正从竹林里压过来。' },
        { speaker: '守灯人', text: '去茶铺问问老板吧，她总知道些旧规矩。' }
      ]
    },
    {
      id: 'keeper-remind',
      lines: [
        { speaker: '守灯人', text: '先去茶铺问问，别急着碰灵灯。' }
      ]
    },
    {
      id: 'keeper-ready',
      lines: [
        { speaker: '守灯人', text: '灵石醒了？那就去点亮村口的灯。' }
      ]
    },
    {
      id: 'keeper-done',
      lines: [
        { speaker: '守灯人', text: '灯火稳住了。今晚，村子能睡个好觉。' }
      ]
    },
    {
      id: 'keeper-default',
      lines: [
        { speaker: '守灯人', text: '风里有竹叶声，也有不该来的脚步声。' }
      ]
    },
    {
      id: 'tea-clue',
      event: 'teaMasterAsked',
      lines: [
        { speaker: '茶铺老板', text: '灵灯要借井边灵石的光。先去古井旁看看。' },
        { speaker: '茶铺老板', text: '若石头发热，就说明它还认得回家的路。' }
      ]
    },
    {
      id: 'tea-after',
      lines: [
        { speaker: '茶铺老板', text: '井边那块石头，小时候我也怕它。' }
      ]
    },
    {
      id: 'tea-done',
      lines: [
        { speaker: '茶铺老板', text: '来喝杯热茶吧，雾散了茶才香。' }
      ]
    },
    {
      id: 'tea-default',
      lines: [
        { speaker: '茶铺老板', text: '茶还没煮开，先去村口看看吧。' }
      ]
    },
    {
      id: 'child-default',
      lines: [
        { speaker: '阿梨', text: '竹林今天安静得有点怪。' }
      ]
    },
    {
      id: 'child-hint',
      lines: [
        { speaker: '阿梨', text: '我看见井边闪了一下，好像星星掉进去了。' }
      ]
    },
    {
      id: 'child-lamp',
      lines: [
        { speaker: '阿梨', text: '快去点灯吧，我想看雾散开的样子。' }
      ]
    },
    {
      id: 'child-done',
      lines: [
        { speaker: '阿梨', text: '灯亮起来的时候，竹叶都像在发光。' }
      ]
    },
    {
      id: 'stone-found',
      event: 'spiritStoneFound',
      lines: [
        { speaker: '井边灵石', text: '石面传来温热的光，像有人在远处回应。' }
      ]
    },
    {
      id: 'stone-silent',
      lines: [
        { speaker: '井边灵石', text: '石头冰凉沉默，还不到唤醒它的时候。' }
      ]
    },
    {
      id: 'stone-quiet',
      lines: [
        { speaker: '井边灵石', text: '灵石的光已经回到灯里。' }
      ]
    },
    {
      id: 'lamp-light',
      event: 'spiritLampLit',
      lines: [
        { speaker: '村口灵灯', text: '你把灵石的光引入灯芯，暖色照亮了雾竹村。' }
      ]
    },
    {
      id: 'lamp-dark',
      lines: [
        { speaker: '村口灵灯', text: '灯芯暗着，需要先找到能唤醒它的光。' }
      ]
    },
    {
      id: 'lamp-bright',
      lines: [
        { speaker: '村口灵灯', text: '灵灯安静燃烧，雾气不再靠近。' }
      ]
    }
  ],
  quest: {
    id: 'light-spirit-lamp',
    title: '点亮村口灵灯',
    phase: 'notStarted'
  }
};
