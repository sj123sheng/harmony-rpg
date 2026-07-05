# Harmony RPG MVP 实现计划

> **给执行代理的要求：** 必须使用 `superpowers:subagent-driven-development`（推荐）或 `superpowers:executing-plans`，按任务逐步执行本计划。所有步骤使用复选框（`- [ ]`）跟踪进度。

**目标：** 构建一个 HarmonyOS ArkTS 2D RPG MVP，包含小型俯视角村落、虚拟摇杆移动、碰撞、NPC/物件交互、对话和一条短任务。

**架构：** 游戏规则放在 `entry/src/main/ets/game` 下的 ArkTS 模块中，不直接调用 Canvas API。`Index.ets` 负责 ArkUI 输入和 Canvas 画布，`CanvasRenderer.ets` 将 `GameState` 转换为绘制行为，为后续替换成 XComponent/C++ 渲染器保留边界。

**技术栈：** HarmonyOS Stage 模型、ArkTS、ArkUI Canvas，以及用于纯 `.ets` 逻辑模块的轻量 Node 测试。

---

## 文件结构

创建以下文件：

- `AppScope/app.json5`：应用级元数据。
- `build-profile.json5`：项目构建配置。
- `hvigorfile.ts`：根 Hvigor 构建入口。
- `oh-package.json5`：项目包元数据。
- `entry/build-profile.json5`：entry 模块构建配置。
- `entry/hvigorfile.ts`：entry 模块 Hvigor 构建入口。
- `entry/oh-package.json5`：entry 模块包元数据。
- `entry/src/main/module.json5`：HarmonyOS entry ability 声明。
- `entry/src/main/ets/entryability/EntryAbility.ets`：应用 Ability 生命周期。
- `entry/src/main/ets/pages/Index.ets`：游戏页面、Canvas、触控输入和渲染循环。
- `entry/src/main/ets/game/core/GameTypes.ets`：共享的几何、角色、地图、对话、任务和渲染相关类型。
- `entry/src/main/ets/game/core/GameState.ets`：创建并更新世界状态。
- `entry/src/main/ets/game/core/InputController.ets`：虚拟摇杆和交互输入状态。
- `entry/src/main/ets/game/core/GameLoop.ets`：页面循环使用的帧间隔辅助模块。
- `entry/src/main/ets/game/world/VillageMap.ets`：第一张村落地图、NPC、物件、碰撞、对话和任务数据。
- `entry/src/main/ets/game/world/CollisionSystem.ets`：矩形碰撞和移动修正。
- `entry/src/main/ets/game/world/InteractionSystem.ets`：最近可交互对象检测。
- `entry/src/main/ets/game/actors/Player.ets`：玩家创建和移动辅助函数。
- `entry/src/main/ets/game/actors/Npc.ets`：NPC 辅助函数。
- `entry/src/main/ets/game/story/DialogueSystem.ets`：对话状态和事件派发。
- `entry/src/main/ets/game/story/QuestSystem.ets`：任务阶段流转。
- `entry/src/main/ets/game/render/RenderTypes.ets`：渲染器无关的绘制命令类型。
- `entry/src/main/ets/game/render/CanvasRenderer.ets`：Canvas 绘制实现。
- `entry/src/ohosTest/ets/test/CollisionSystem.test.ets`：碰撞测试。
- `entry/src/ohosTest/ets/test/InteractionSystem.test.ets`：交互测试。
- `entry/src/ohosTest/ets/test/QuestSystem.test.ets`：任务测试。
- `tools/logic-tests.mjs`：用于纯 ArkTS 风格模块的 Node 测试运行器。
- `docs/superpowers/plans/2026-07-05-harmony-rpg-mvp.md`：本实现计划。

---

### 任务 1：搭建 HarmonyOS 工程元数据

**文件：**
- 创建：`AppScope/app.json5`
- 创建：`build-profile.json5`
- 创建：`hvigorfile.ts`
- 创建：`oh-package.json5`
- 创建：`entry/build-profile.json5`
- 创建：`entry/hvigorfile.ts`
- 创建：`entry/oh-package.json5`
- 创建：`entry/src/main/module.json5`
- 创建：`entry/src/main/ets/entryability/EntryAbility.ets`
- 创建：`entry/src/main/ets/pages/Index.ets`

- [ ] **步骤 1：创建应用和项目元数据**

创建 `AppScope/app.json5`：

```json5
{
  "app": {
    "bundleName": "com.xiling.harmonyrpg",
    "vendor": "xiling",
    "versionCode": 1000000,
    "versionName": "1.0.0",
    "icon": "$media:app_icon",
    "label": "$string:app_name"
  }
}
```

创建 `build-profile.json5`：

```json5
{
  "app": {
    "signingConfigs": [],
    "products": [
      {
        "name": "default",
        "signingConfig": "default",
        "compatibleSdkVersion": "6.0.0(20)",
        "runtimeOS": "HarmonyOS"
      }
    ],
    "buildModeSet": [
      {
        "name": "debug"
      },
      {
        "name": "release"
      }
    ]
  },
  "modules": [
    {
      "name": "entry",
      "srcPath": "./entry",
      "targets": [
        {
          "name": "default",
          "applyToProducts": [
            "default"
          ]
        }
      ]
    }
  ]
}
```

创建 `hvigorfile.ts`：

```ts
export { appTasks } from '@ohos/hvigor-ohos-plugin';
```

创建 `oh-package.json5`：

```json5
{
  "name": "harmony-rpg",
  "version": "1.0.0",
  "description": "Lightweight HarmonyOS native 2D RPG prototype",
  "main": "",
  "author": "xiling",
  "license": "MIT",
  "dependencies": {},
  "devDependencies": {
    "@ohos/hvigor-ohos-plugin": "latest",
    "@ohos/hvigor": "latest"
  }
}
```

- [ ] **步骤 2：创建 entry 模块元数据**

创建 `entry/build-profile.json5`：

```json5
{
  "apiType": "stageMode",
  "buildOption": {},
  "targets": [
    {
      "name": "default"
    }
  ]
}
```

创建 `entry/hvigorfile.ts`：

```ts
export { hapTasks } from '@ohos/hvigor-ohos-plugin';
```

创建 `entry/oh-package.json5`：

```json5
{
  "name": "entry",
  "version": "1.0.0",
  "description": "Harmony RPG entry module",
  "main": "",
  "author": "xiling",
  "license": "MIT",
  "dependencies": {}
}
```

创建 `entry/src/main/module.json5`：

```json5
{
  "module": {
    "name": "entry",
    "type": "entry",
    "description": "$string:module_desc",
    "mainElement": "EntryAbility",
    "deviceTypes": [
      "phone"
    ],
    "requestPermissions": [],
    "abilities": [
      {
        "name": "EntryAbility",
        "srcEntry": "./ets/entryability/EntryAbility.ets",
        "description": "$string:entryability_desc",
        "icon": "$media:app_icon",
        "label": "$string:app_name",
        "startWindowIcon": "$media:app_icon",
        "startWindowBackground": "$color:start_window_background",
        "exported": true,
        "skills": [
          {
            "entities": [
              "entity.system.home"
            ],
            "actions": [
              "action.system.home"
            ]
          }
        ]
      }
    ]
  }
}
```

- [ ] **步骤 3：创建最小 Ability 和页面**

创建 `entry/src/main/ets/entryability/EntryAbility.ets`：

```ts
import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';

const DOMAIN = 0x0001;

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(DOMAIN, 'HarmonyRpg', 'EntryAbility created');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'HarmonyRpg', 'Failed to load Index: %{public}s', JSON.stringify(err));
      }
    });
  }
}
```

创建 `entry/src/main/ets/pages/Index.ets`：

```ts
@Entry
@Component
struct Index {
  build() {
    Stack() {
      Text('Harmony RPG')
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
        .fontColor('#2A2A2A')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F2E6C9')
  }
}
```

- [ ] **步骤 4：在 DevEco Studio 中打开项目并同步**

在 IDE 中运行 DevEco Studio 同步/构建。预期：项目能作为 HarmonyOS Stage 模型应用打开，并显示 `Harmony RPG` 占位页面。

- [ ] **步骤 5：将工程骨架和设计文档合并提交**

```bash
git add AppScope build-profile.json5 hvigorfile.ts oh-package.json5 entry docs/superpowers/specs/2026-07-05-harmony-rpg-mvp-design.md docs/superpowers/plans/2026-07-05-harmony-rpg-mvp.md
git commit -m "feat: 初始化鸿蒙RPG工程骨架

创建HarmonyOS Stage模型工程元数据、EntryAbility和首页占位。
加入MVP设计文档与实现计划，后续按计划实现游戏核心模块。

Prompt: 用户希望在当前目录开发鸿蒙原生2D轻量RPG，已确认俯视角东方幻想村落MVP。"
```

预期：形成一个干净的初始提交。

---

### 任务 2：添加核心类型与村落数据

**文件：**
- 创建：`entry/src/main/ets/game/core/GameTypes.ets`
- 创建：`entry/src/main/ets/game/world/VillageMap.ets`

- [ ] **步骤 1：添加共享游戏类型**

创建 `entry/src/main/ets/game/core/GameTypes.ets`：

```ts
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

export interface NpcData extends ActorData {
  dialogueByPhase: Partial<Record<QuestPhase, string>>;
  fallbackDialogueId: string;
}

export interface InteractableObjectData {
  id: string;
  name: string;
  kind: 'spiritStone' | 'spiritLamp';
  position: Vector2;
  size: Size;
  dialogueByPhase: Partial<Record<QuestPhase, string>>;
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
  dialogues: Record<string, DialogueData>;
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
```

- [ ] **步骤 2：添加第一张村落地图数据**

创建 `entry/src/main/ets/game/world/VillageMap.ets`：

```ts
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
  dialogues: {
    'keeper-start': {
      id: 'keeper-start',
      event: 'keeperAsked',
      lines: [
        { speaker: '守灯人', text: '村口的灵灯忽然熄了，雾气正从竹林里压过来。' },
        { speaker: '守灯人', text: '去茶铺问问老板吧，她总知道些旧规矩。' }
      ]
    },
    'keeper-remind': {
      id: 'keeper-remind',
      lines: [
        { speaker: '守灯人', text: '先去茶铺问问，别急着碰灵灯。' }
      ]
    },
    'keeper-ready': {
      id: 'keeper-ready',
      lines: [
        { speaker: '守灯人', text: '灵石醒了？那就去点亮村口的灯。' }
      ]
    },
    'keeper-done': {
      id: 'keeper-done',
      lines: [
        { speaker: '守灯人', text: '灯火稳住了。今晚，村子能睡个好觉。' }
      ]
    },
    'keeper-default': {
      id: 'keeper-default',
      lines: [
        { speaker: '守灯人', text: '风里有竹叶声，也有不该来的脚步声。' }
      ]
    },
    'tea-clue': {
      id: 'tea-clue',
      event: 'teaMasterAsked',
      lines: [
        { speaker: '茶铺老板', text: '灵灯要借井边灵石的光。先去古井旁看看。' },
        { speaker: '茶铺老板', text: '若石头发热，就说明它还认得回家的路。' }
      ]
    },
    'tea-after': {
      id: 'tea-after',
      lines: [
        { speaker: '茶铺老板', text: '井边那块石头，小时候我也怕它。' }
      ]
    },
    'tea-done': {
      id: 'tea-done',
      lines: [
        { speaker: '茶铺老板', text: '来喝杯热茶吧，雾散了茶才香。' }
      ]
    },
    'tea-default': {
      id: 'tea-default',
      lines: [
        { speaker: '茶铺老板', text: '茶还没煮开，先去村口看看吧。' }
      ]
    },
    'child-default': {
      id: 'child-default',
      lines: [
        { speaker: '阿梨', text: '竹林今天安静得有点怪。' }
      ]
    },
    'child-hint': {
      id: 'child-hint',
      lines: [
        { speaker: '阿梨', text: '我看见井边闪了一下，好像星星掉进去了。' }
      ]
    },
    'child-lamp': {
      id: 'child-lamp',
      lines: [
        { speaker: '阿梨', text: '快去点灯吧，我想看雾散开的样子。' }
      ]
    },
    'child-done': {
      id: 'child-done',
      lines: [
        { speaker: '阿梨', text: '灯亮起来的时候，竹叶都像在发光。' }
      ]
    },
    'stone-found': {
      id: 'stone-found',
      event: 'spiritStoneFound',
      lines: [
        { speaker: '井边灵石', text: '石面传来温热的光，像有人在远处回应。' }
      ]
    },
    'stone-silent': {
      id: 'stone-silent',
      lines: [
        { speaker: '井边灵石', text: '石头冰凉沉默，还不到唤醒它的时候。' }
      ]
    },
    'stone-quiet': {
      id: 'stone-quiet',
      lines: [
        { speaker: '井边灵石', text: '灵石的光已经回到灯里。' }
      ]
    },
    'lamp-light': {
      id: 'lamp-light',
      event: 'spiritLampLit',
      lines: [
        { speaker: '村口灵灯', text: '你把灵石的光引入灯芯，暖色照亮了雾竹村。' }
      ]
    },
    'lamp-dark': {
      id: 'lamp-dark',
      lines: [
        { speaker: '村口灵灯', text: '灯芯暗着，需要先找到能唤醒它的光。' }
      ]
    },
    'lamp-bright': {
      id: 'lamp-bright',
      lines: [
        { speaker: '村口灵灯', text: '灵灯安静燃烧，雾气不再靠近。' }
      ]
    }
  },
  quest: {
    id: 'light-spirit-lamp',
    title: '点亮村口灵灯',
    phase: 'notStarted'
  }
};
```

- [ ] **步骤 3：在 DevEco Studio 中做语法检查**

在 DevEco Studio 中打开 `VillageMap.ets` 和 `GameTypes.ets`。预期：这两个文件没有未解析导入，也没有类型错误。

- [ ] **步骤 4：提交核心数据**

```bash
git add entry/src/main/ets/game/core/GameTypes.ets entry/src/main/ets/game/world/VillageMap.ets
git commit -m "feat: 添加村落地图与核心数据类型

定义角色、地图、交互、对话和任务数据结构。
加入雾竹村MVP地图、NPC、物件和点亮灵灯剧情数据。

Prompt: 用户确认第一版为东方幻想村落剧情小样，并要求预留C++渲染边界。"
```

---

### 任务 3：实现碰撞与交互逻辑

**文件：**
- 创建：`entry/src/main/ets/game/world/CollisionSystem.ets`
- 创建：`entry/src/main/ets/game/world/InteractionSystem.ets`
- 创建：`tools/logic-tests.mjs`

- [ ] **步骤 1：编写轻量逻辑测试运行器**

创建 `tools/logic-tests.mjs`：

```js
import assert from 'node:assert/strict';

function rectsOverlap(a, b) {
  return a.x < b.x + b.width &&
    a.x + a.width > b.x &&
    a.y < b.y + b.height &&
    a.y + a.height > b.y;
}

function resolveMovement(actor, desiredPosition, collisions, bounds) {
  const nextX = { ...actor, x: desiredPosition.x, y: actor.y };
  let resolvedX = desiredPosition.x;
  if (nextX.x < 0 || nextX.x + nextX.width > bounds.width || collisions.some((rect) => rectsOverlap(nextX, rect))) {
    resolvedX = actor.x;
  }

  const nextY = { ...actor, x: resolvedX, y: desiredPosition.y };
  let resolvedY = desiredPosition.y;
  if (nextY.y < 0 || nextY.y + nextY.height > bounds.height || collisions.some((rect) => rectsOverlap(nextY, rect))) {
    resolvedY = actor.y;
  }

  return { x: resolvedX, y: resolvedY };
}

function distanceBetweenCenters(a, b) {
  const ax = a.position.x + a.size.width / 2;
  const ay = a.position.y + a.size.height / 2;
  const bx = b.position.x + b.size.width / 2;
  const by = b.position.y + b.size.height / 2;
  return Math.hypot(ax - bx, ay - by);
}

function findNearestInteractable(player, npcs, objects, maxDistance, phase) {
  const candidates = [
    ...npcs.map((npc) => ({
      id: npc.id,
      kind: 'npc',
      name: npc.name,
      dialogueId: npc.dialogueByPhase[phase] ?? npc.fallbackDialogueId,
      distance: distanceBetweenCenters(player, npc)
    })),
    ...objects.map((object) => ({
      id: object.id,
      kind: 'object',
      name: object.name,
      dialogueId: object.dialogueByPhase[phase] ?? object.fallbackDialogueId,
      distance: distanceBetweenCenters(player, object)
    }))
  ];

  return candidates
    .filter((candidate) => candidate.distance <= maxDistance)
    .sort((a, b) => a.distance - b.distance)[0];
}

const actor = { x: 20, y: 20, width: 20, height: 20 };
const wall = { id: 'wall', x: 45, y: 10, width: 20, height: 60 };
assert.deepEqual(resolveMovement(actor, { x: 35, y: 20 }, [wall], { width: 200, height: 200 }), { x: 20, y: 20 });
assert.deepEqual(resolveMovement(actor, { x: 20, y: 45 }, [wall], { width: 200, height: 200 }), { x: 20, y: 45 });

const player = { position: { x: 100, y: 100 }, size: { width: 40, height: 50 } };
const nearNpc = {
  id: 'keeper',
  name: '守灯人',
  position: { x: 135, y: 100 },
  size: { width: 40, height: 50 },
  dialogueByPhase: { notStarted: 'keeper-start' },
  fallbackDialogueId: 'keeper-default'
};
const farObject = {
  id: 'lamp',
  name: '灵灯',
  position: { x: 300, y: 300 },
  size: { width: 60, height: 80 },
  dialogueByPhase: {},
  fallbackDialogueId: 'lamp-dark'
};
assert.equal(findNearestInteractable(player, [nearNpc], [farObject], 90, 'notStarted').id, 'keeper');
assert.equal(findNearestInteractable(player, [], [farObject], 90, 'notStarted'), undefined);

console.log('logic tests passed');
```

- [ ] **步骤 2：运行测试并确认通过**

运行：

```bash
node tools/logic-tests.mjs
```

预期：

```text
logic tests passed
```

- [ ] **步骤 3：实现碰撞系统**

创建 `entry/src/main/ets/game/world/CollisionSystem.ets`：

```ts
import { Rect, Size, Vector2 } from '../core/GameTypes';

export function rectsOverlap(a: Rect, b: Rect): boolean {
  return a.x < b.x + b.width &&
    a.x + a.width > b.x &&
    a.y < b.y + b.height &&
    a.y + a.height > b.y;
}

export function resolveMovement(actor: Rect, desiredPosition: Vector2, collisions: Rect[], bounds: Size): Vector2 {
  const nextX: Rect = {
    ...actor,
    x: desiredPosition.x,
    y: actor.y
  };

  let resolvedX = desiredPosition.x;
  if (isOutOfBounds(nextX, bounds) || collisions.some((rect) => rectsOverlap(nextX, rect))) {
    resolvedX = actor.x;
  }

  const nextY: Rect = {
    ...actor,
    x: resolvedX,
    y: desiredPosition.y
  };

  let resolvedY = desiredPosition.y;
  if (isOutOfBounds(nextY, bounds) || collisions.some((rect) => rectsOverlap(nextY, rect))) {
    resolvedY = actor.y;
  }

  return { x: resolvedX, y: resolvedY };
}

function isOutOfBounds(rect: Rect, bounds: Size): boolean {
  return rect.x < 0 ||
    rect.y < 0 ||
    rect.x + rect.width > bounds.width ||
    rect.y + rect.height > bounds.height;
}
```

- [ ] **步骤 4：实现交互系统**

创建 `entry/src/main/ets/game/world/InteractionSystem.ets`：

```ts
import {
  InteractionTarget,
  InteractableObjectData,
  NpcData,
  PlayerData,
  QuestPhase
} from '../core/GameTypes';

export function findNearestInteractable(
  player: PlayerData,
  npcs: NpcData[],
  objects: InteractableObjectData[],
  maxDistance: number,
  phase: QuestPhase
): InteractionTarget | undefined {
  const npcTargets: InteractionTarget[] = npcs.map((npc) => ({
    id: npc.id,
    kind: 'npc',
    name: npc.name,
    dialogueId: npc.dialogueByPhase[phase] ?? npc.fallbackDialogueId,
    distance: distanceBetweenCenters(player, npc)
  }));

  const objectTargets: InteractionTarget[] = objects.map((object) => ({
    id: object.id,
    kind: 'object',
    name: object.name,
    dialogueId: object.dialogueByPhase[phase] ?? object.fallbackDialogueId,
    distance: distanceBetweenCenters(player, object)
  }));

  return [...npcTargets, ...objectTargets]
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
```

- [ ] **步骤 5：再次运行测试**

运行：

```bash
node tools/logic-tests.mjs
```

预期：

```text
logic tests passed
```

- [ ] **步骤 6：提交系统模块**

```bash
git add tools/logic-tests.mjs entry/src/main/ets/game/world/CollisionSystem.ets entry/src/main/ets/game/world/InteractionSystem.ets
git commit -m "feat: 实现碰撞与交互判定

加入矩形碰撞、移动修正和最近交互对象检测。
补充轻量逻辑测试覆盖穿墙修正与交互距离选择。

Prompt: 用户确认第一版需要自由移动、碰撞、靠近NPC或物件交互。"
```

---

### 任务 4：实现玩家、对话、任务和游戏状态

**文件：**
- 创建：`entry/src/main/ets/game/actors/Player.ets`
- 创建：`entry/src/main/ets/game/actors/Npc.ets`
- 创建：`entry/src/main/ets/game/story/QuestSystem.ets`
- 创建：`entry/src/main/ets/game/story/DialogueSystem.ets`
- 创建：`entry/src/main/ets/game/core/GameState.ets`
- 修改：`tools/logic-tests.mjs`

- [ ] **步骤 1：扩展逻辑测试，覆盖任务流转**

在 `tools/logic-tests.mjs` 中，将以下代码追加到 `console.log('logic tests passed');` 之前：

```js
function advanceQuestPhase(currentPhase, event) {
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

assert.equal(advanceQuestPhase('notStarted', 'keeperAsked'), 'askedKeeper');
assert.equal(advanceQuestPhase('askedKeeper', 'teaMasterAsked'), 'askedTeaMaster');
assert.equal(advanceQuestPhase('askedTeaMaster', 'spiritStoneFound'), 'foundSpiritStone');
assert.equal(advanceQuestPhase('foundSpiritStone', 'spiritLampLit'), 'completed');
assert.equal(advanceQuestPhase('notStarted', 'spiritLampLit'), 'notStarted');
```

- [ ] **步骤 2：运行测试**

运行：

```bash
node tools/logic-tests.mjs
```

预期：

```text
logic tests passed
```

- [ ] **步骤 3：实现玩家辅助模块**

创建 `entry/src/main/ets/game/actors/Player.ets`：

```ts
import { Direction, PlayerData, Rect, Vector2 } from '../core/GameTypes';

export function createPlayer(spawnPoint: Vector2): PlayerData {
  return {
    id: 'player',
    name: '旅人',
    position: { ...spawnPoint },
    size: { width: 38, height: 54 },
    direction: 'down',
    speed: 180
  };
}

export function getPlayerRect(player: PlayerData): Rect {
  return {
    id: player.id,
    x: player.position.x,
    y: player.position.y,
    width: player.size.width,
    height: player.size.height
  };
}

export function directionFromVector(vector: Vector2, fallback: Direction): Direction {
  if (Math.abs(vector.x) > Math.abs(vector.y)) {
    return vector.x >= 0 ? 'right' : 'left';
  }

  if (Math.abs(vector.y) > 0) {
    return vector.y >= 0 ? 'down' : 'up';
  }

  return fallback;
}
```

- [ ] **步骤 4：实现 NPC 辅助模块**

创建 `entry/src/main/ets/game/actors/Npc.ets`：

```ts
import { NpcData, QuestPhase } from '../core/GameTypes';

export function resolveNpcDialogueId(npc: NpcData, phase: QuestPhase): string {
  return npc.dialogueByPhase[phase] ?? npc.fallbackDialogueId;
}
```

- [ ] **步骤 5：实现任务系统**

创建 `entry/src/main/ets/game/story/QuestSystem.ets`：

```ts
import { DialogueEvent, QuestData, QuestPhase } from '../core/GameTypes';

export function createQuestState(template: QuestData): QuestData {
  return {
    ...template
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
```

- [ ] **步骤 6：实现对话系统**

创建 `entry/src/main/ets/game/story/DialogueSystem.ets`：

```ts
import { ActiveDialogue, DialogueData, DialogueEvent, MapData } from '../core/GameTypes';

export function startDialogue(dialogueId: string, map: MapData): ActiveDialogue {
  if (map.dialogues[dialogueId] === undefined) {
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

  return map.dialogues[activeDialogue.id] ?? {
    id: 'missing-dialogue',
    lines: [
      {
        speaker: '旁白',
        text: '这里暂时没有可用的对话。'
      }
    ]
  };
}

export function advanceDialogue(activeDialogue: ActiveDialogue, map: MapData): {
  nextDialogue?: ActiveDialogue;
  event?: DialogueEvent;
} {
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
```

- [ ] **步骤 7：实现游戏状态**

创建 `entry/src/main/ets/game/core/GameState.ets`：

```ts
import { createPlayer, directionFromVector, getPlayerRect } from '../actors/Player';
import { MapData, GameStateSnapshot, InteractionTarget, PlayerData, QuestData, Vector2, ActiveDialogue } from './GameTypes';
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
      const normalized = {
        x: moveVector.x / length,
        y: moveVector.y / length
      };
      const desiredPosition = {
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

  getCurrentDialogueLine(): { speaker: string; text: string } | undefined {
    const dialogue = getDialogue(this.activeDialogue, this.map);
    if (!dialogue || !this.activeDialogue) {
      return undefined;
    }
    return dialogue.lines[this.activeDialogue.lineIndex];
  }

  snapshot(): GameStateSnapshot {
    return {
      map: this.map,
      player: this.player,
      quest: this.quest,
      activeDialogue: this.activeDialogue,
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
```

- [ ] **步骤 8：再次运行测试**

运行：

```bash
node tools/logic-tests.mjs
```

预期：

```text
logic tests passed
```

- [ ] **步骤 9：检查 DevEco 类型诊断**

在 DevEco Studio 中打开变更过的 `.ets` 文件。预期：导入可解析，游戏逻辑模块没有 ArkTS 类型错误。

- [ ] **步骤 10：提交状态模块**

```bash
git add tools/logic-tests.mjs entry/src/main/ets/game/actors entry/src/main/ets/game/story entry/src/main/ets/game/core/GameState.ets
git commit -m "feat: 实现游戏状态与剧情推进

加入玩家、NPC、对话、任务阶段和GameState更新逻辑。
任务流程覆盖守灯人、茶铺、灵石和灵灯的剧情链路。

Prompt: 用户确认MVP需要2-3个NPC、可交互物件和短任务流程。"
```

---

### 任务 5：实现输入控制器和游戏循环

**文件：**
- 创建：`entry/src/main/ets/game/core/InputController.ets`
- 创建：`entry/src/main/ets/game/core/GameLoop.ets`

- [ ] **步骤 1：实现输入控制器**

创建 `entry/src/main/ets/game/core/InputController.ets`：

```ts
import { Vector2 } from './GameTypes';

export interface JoystickLayout {
  center: Vector2;
  radius: number;
  knobRadius: number;
}

export class InputController {
  private joystickPointerId: number = -1;
  private joystickVector: Vector2 = { x: 0, y: 0 };
  private interactionPressed: boolean = false;

  setJoystick(pointerId: number, point: Vector2, layout: JoystickLayout): void {
    if (this.joystickPointerId === -1) {
      this.joystickPointerId = pointerId;
    }
    if (this.joystickPointerId !== pointerId) {
      return;
    }

    const dx = point.x - layout.center.x;
    const dy = point.y - layout.center.y;
    const distance = Math.hypot(dx, dy);
    if (distance === 0) {
      this.joystickVector = { x: 0, y: 0 };
      return;
    }

    const clamped = Math.min(distance, layout.radius);
    this.joystickVector = {
      x: (dx / distance) * (clamped / layout.radius),
      y: (dy / distance) * (clamped / layout.radius)
    };
  }

  releaseJoystick(pointerId: number): void {
    if (this.joystickPointerId === pointerId) {
      this.joystickPointerId = -1;
      this.joystickVector = { x: 0, y: 0 };
    }
  }

  getMoveVector(): Vector2 {
    return { ...this.joystickVector };
  }

  pressInteraction(): void {
    this.interactionPressed = true;
  }

  consumeInteractionPress(): boolean {
    const pressed = this.interactionPressed;
    this.interactionPressed = false;
    return pressed;
  }
}
```

- [ ] **步骤 2：实现游戏循环辅助模块**

创建 `entry/src/main/ets/game/core/GameLoop.ets`：

```ts
export class GameLoop {
  private lastTimestamp: number = 0;

  nextDelta(timestamp: number): number {
    if (this.lastTimestamp === 0) {
      this.lastTimestamp = timestamp;
      return 0;
    }

    const deltaSeconds = Math.min((timestamp - this.lastTimestamp) / 1000, 0.05);
    this.lastTimestamp = timestamp;
    return deltaSeconds;
  }

  reset(): void {
    this.lastTimestamp = 0;
  }
}
```

- [ ] **步骤 3：检查 DevEco 类型诊断**

在 DevEco Studio 中打开这两个文件。预期：没有类型错误。

- [ ] **步骤 4：提交输入和循环模块**

```bash
git add entry/src/main/ets/game/core/InputController.ets entry/src/main/ets/game/core/GameLoop.ets
git commit -m "feat: 添加摇杆输入与游戏循环辅助

实现虚拟摇杆向量、交互按键消费和帧间隔计算。
为ArkUI页面接入Canvas游戏循环做准备。

Prompt: 用户选择横屏、左下角虚拟摇杆和四方向自由移动。"
```

---

### 任务 6：添加渲染类型和 Canvas 渲染器

**文件：**
- 创建：`entry/src/main/ets/game/render/RenderTypes.ets`
- 创建：`entry/src/main/ets/game/render/CanvasRenderer.ets`

- [ ] **步骤 1：添加渲染器无关的绘制类型**

创建 `entry/src/main/ets/game/render/RenderTypes.ets`：

```ts
import { Rect } from '../core/GameTypes';

export type DrawCommand =
  | FillRectCommand
  | FillCircleCommand
  | TextCommand;

export interface FillRectCommand {
  type: 'fillRect';
  rect: Rect;
  color: string;
  radius?: number;
}

export interface FillCircleCommand {
  type: 'fillCircle';
  x: number;
  y: number;
  radius: number;
  color: string;
}

export interface TextCommand {
  type: 'text';
  text: string;
  x: number;
  y: number;
  color: string;
  size: number;
}
```

- [ ] **步骤 2：实现 Canvas 渲染器**

创建 `entry/src/main/ets/game/render/CanvasRenderer.ets`：

```ts
import { CanvasRenderingContext2D } from '@kit.ArkUI';
import { GameStateSnapshot, InteractableObjectData, NpcData, Rect } from '../core/GameTypes';

export interface Viewport {
  width: number;
  height: number;
}

export class CanvasRenderer {
  render(context: CanvasRenderingContext2D, snapshot: GameStateSnapshot, viewport: Viewport): void {
    context.clearRect(0, 0, viewport.width, viewport.height);
    this.drawBackground(context, snapshot, viewport);
    this.drawMap(context, snapshot);
    this.drawObjects(context, snapshot.map.objects, snapshot.nearbyInteractableId, snapshot.quest.phase === 'completed');
    this.drawNpcs(context, snapshot.map.npcs, snapshot.nearbyInteractableId);
    this.drawPlayer(context, snapshot.player.position.x, snapshot.player.position.y, snapshot.player.size.width, snapshot.player.size.height);
    this.drawQuestHint(context, snapshot.quest.title, snapshot.quest.phase);
  }

  private drawBackground(context: CanvasRenderingContext2D, snapshot: GameStateSnapshot, viewport: Viewport): void {
    const gradient = context.createLinearGradient(0, 0, viewport.width, viewport.height);
    gradient.addColorStop(0, '#F7E7C8');
    gradient.addColorStop(1, '#DCE8BF');
    context.fillStyle = gradient;
    context.fillRect(0, 0, viewport.width, viewport.height);

    context.fillStyle = '#D8C08A';
    context.fillRect(0, snapshot.map.size.height - 55, snapshot.map.size.width, 55);
  }

  private drawMap(context: CanvasRenderingContext2D, snapshot: GameStateSnapshot): void {
    context.fillStyle = '#BFD199';
    context.fillRect(0, 0, 90, snapshot.map.size.height);
    context.fillStyle = '#C9DFAA';
    context.fillRect(0, 0, snapshot.map.size.width, 70);

    this.roundRect(context, { id: 'tea-house-draw', x: 740, y: 95, width: 320, height: 230 }, '#B86E4B', 18);
    this.roundRect(context, { id: 'tea-roof', x: 710, y: 70, width: 380, height: 80 }, '#7D3F32', 22);
    this.roundRect(context, { id: 'well-draw', x: 550, y: 360, width: 110, height: 105 }, '#7A8E96', 16);

    context.fillStyle = '#6D9A6B';
    for (let y = 95; y < 620; y += 85) {
      context.beginPath();
      context.ellipse(45, y, 26, 42, 0.2, 0, Math.PI * 2);
      context.fill();
    }
  }

  private drawObjects(
    context: CanvasRenderingContext2D,
    objects: InteractableObjectData[],
    nearbyInteractableId: string | undefined,
    lampCompleted: boolean
  ): void {
    objects.forEach((object) => {
      const highlighted = nearbyInteractableId === object.id;
      if (object.kind === 'spiritStone') {
        this.roundRect(context, rectFromObject(object), highlighted ? '#BDE7FF' : '#92A8B8', 12);
      } else {
        this.roundRect(context, rectFromObject(object), lampCompleted ? '#F6C85F' : '#6B5A4A', 12);
        if (lampCompleted) {
          context.fillStyle = 'rgba(246, 200, 95, 0.28)';
          context.beginPath();
          context.arc(object.position.x + 30, object.position.y + 20, 52, 0, Math.PI * 2);
          context.fill();
        }
      }
    });
  }

  private drawNpcs(context: CanvasRenderingContext2D, npcs: NpcData[], nearbyInteractableId: string | undefined): void {
    const colors: Record<string, string> = {
      keeper: '#4D6C8B',
      'tea-master': '#8A5A44',
      child: '#D47A76'
    };

    npcs.forEach((npc) => {
      const highlighted = nearbyInteractableId === npc.id;
      this.roundRect(context, rectFromObject(npc), colors[npc.id] ?? '#6C6C6C', 14);
      if (highlighted) {
        context.strokeStyle = '#FFF4B8';
        context.lineWidth = 3;
        context.strokeRect(npc.position.x - 4, npc.position.y - 4, npc.size.width + 8, npc.size.height + 8);
      }
    });
  }

  private drawPlayer(context: CanvasRenderingContext2D, x: number, y: number, width: number, height: number): void {
    this.roundRect(context, { id: 'player-draw', x, y, width, height }, '#3F7F76', 16);
    context.fillStyle = '#F7D7B5';
    context.beginPath();
    context.arc(x + width / 2, y + 13, 13, 0, Math.PI * 2);
    context.fill();
  }

  private drawQuestHint(context: CanvasRenderingContext2D, title: string, phase: string): void {
    context.fillStyle = 'rgba(255, 255, 255, 0.78)';
    context.fillRect(24, 20, 270, 52);
    context.fillStyle = '#2F3326';
    context.font = '18px sans-serif';
    context.fillText(title, 40, 42);
    context.font = '14px sans-serif';
    context.fillText(`阶段：${phase}`, 40, 62);
  }

  private roundRect(context: CanvasRenderingContext2D, rect: Rect, color: string, radius: number): void {
    context.fillStyle = color;
    context.beginPath();
    context.roundRect(rect.x, rect.y, rect.width, rect.height, radius);
    context.fill();
  }
}

function rectFromObject(object: { id: string; position: { x: number; y: number }; size: { width: number; height: number } }): Rect {
  return {
    id: object.id,
    x: object.position.x,
    y: object.position.y,
    width: object.size.width,
    height: object.size.height
  };
}
```

- [ ] **步骤 3：检查 DevEco 类型诊断**

打开 `CanvasRenderer.ets`。预期：`CanvasRenderingContext2D` 能解析。如果目标 SDK 不支持 `roundRect`，在保持方法签名不变的前提下，把 `this.roundRect(...)` 的内部实现替换为 `context.fillRect(...)`。

- [ ] **步骤 4：提交渲染器**

```bash
git add entry/src/main/ets/game/render
git commit -m "feat: 添加Canvas渲染层

定义渲染指令类型并实现当前CanvasRenderer。
渲染村落背景、建筑、NPC、主角、物件和任务提示。

Prompt: 用户选择ArkUI Canvas自绘，并要求逻辑与渲染边界清晰。"
```

---

### 任务 7：集成 ArkUI 页面、Canvas、摇杆和对话 UI

**文件：**
- 修改：`entry/src/main/ets/pages/Index.ets`

- [ ] **步骤 1：用游戏页面替换占位页面**

将 `entry/src/main/ets/pages/Index.ets` 替换为：

```ts
import { CanvasRenderer, Viewport } from '../game/render/CanvasRenderer';
import { GameLoop } from '../game/core/GameLoop';
import { GameState } from '../game/core/GameState';
import { InputController, JoystickLayout } from '../game/core/InputController';

@Entry
@Component
struct Index {
  private readonly gameState: GameState = new GameState();
  private readonly input: InputController = new InputController();
  private readonly loop: GameLoop = new GameLoop();
  private readonly renderer: CanvasRenderer = new CanvasRenderer();
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(new RenderingContextSettings(true));
  @State private viewport: Viewport = { width: 1280, height: 720 };
  @State private joystickKnobOffsetX: number = 0;
  @State private joystickKnobOffsetY: number = 0;
  @State private dialogueSpeaker: string = '';
  @State private dialogueText: string = '';
  @State private showInteractionButton: boolean = false;

  aboutToAppear(): void {
    this.loop.reset();
  }

  build() {
    Stack() {
      Canvas(this.context)
        .width('100%')
        .height('100%')
        .onReady(() => {
          this.renderFrame(0);
        })
        .onTouch((event: TouchEvent) => {
          this.handleCanvasTouch(event);
        })

      this.Joystick()

      if (this.showInteractionButton || this.dialogueText.length > 0) {
        Button(this.dialogueText.length > 0 ? '继续' : '交互')
          .fontSize(18)
          .fontColor('#2E2A23')
          .backgroundColor('#F5D26B')
          .width(104)
          .height(104)
          .borderRadius(52)
          .position({ x: this.viewport.width - 148, y: this.viewport.height - 150 })
          .onClick(() => {
            this.input.pressInteraction();
            this.tick(16);
          })
      }

      if (this.dialogueText.length > 0) {
        Column() {
          Text(this.dialogueSpeaker)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#F7E8C7')
            .width('100%')
          Text(this.dialogueText)
            .fontSize(22)
            .fontColor('#FFF9EA')
            .lineHeight(32)
            .width('100%')
        }
        .alignItems(HorizontalAlign.Start)
        .padding({ left: 28, right: 28, top: 18, bottom: 18 })
        .width(this.viewport.width - 300)
        .height(126)
        .backgroundColor('rgba(42, 34, 28, 0.88)')
        .borderRadius(8)
        .position({ x: 150, y: this.viewport.height - 150 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F2E6C9')
    .onAreaChange((oldArea: Area, newArea: Area) => {
      this.viewport = {
        width: Number(newArea.width),
        height: Number(newArea.height)
      };
    })
  }

  @Builder
  Joystick() {
    Stack() {
      Circle()
        .width(132)
        .height(132)
        .fill('rgba(47, 51, 38, 0.22)')
      Circle()
        .width(58)
        .height(58)
        .fill('rgba(255, 249, 234, 0.86)')
        .translate({ x: this.joystickKnobOffsetX, y: this.joystickKnobOffsetY })
    }
    .width(132)
    .height(132)
    .position({ x: 54, y: this.viewport.height - 178 })
  }

  private handleCanvasTouch(event: TouchEvent): void {
    const layout = this.getJoystickLayout();
    event.touches.forEach((touch) => {
      if (event.type === TouchType.Down || event.type === TouchType.Move) {
        if (touch.x <= 240 && touch.y >= this.viewport.height - 240) {
          this.input.setJoystick(touch.id, { x: touch.x, y: touch.y }, layout);
        }
      }
      if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.input.releaseJoystick(touch.id);
      }
    });

    const move = this.input.getMoveVector();
    this.joystickKnobOffsetX = move.x * layout.radius;
    this.joystickKnobOffsetY = move.y * layout.radius;
    this.tick(16);
  }

  private getJoystickLayout(): JoystickLayout {
    return {
      center: { x: 120, y: this.viewport.height - 112 },
      radius: 52,
      knobRadius: 29
    };
  }

  private renderFrame(timestamp: number): void {
    const delta = this.loop.nextDelta(timestamp);
    this.tick(delta * 1000);
    requestAnimationFrame((nextTimestamp: number) => {
      this.renderFrame(nextTimestamp);
    });
  }

  private tick(deltaMs: number): void {
    if (this.input.consumeInteractionPress()) {
      this.gameState.interact();
    }

    this.gameState.update(deltaMs / 1000, this.input.getMoveVector());
    const snapshot = this.gameState.snapshot();
    const dialogueLine = this.gameState.getCurrentDialogueLine();
    this.dialogueSpeaker = dialogueLine?.speaker ?? '';
    this.dialogueText = dialogueLine?.text ?? '';
    this.showInteractionButton = snapshot.nearbyInteractableId !== undefined;
    this.renderer.render(this.context, snapshot, this.viewport);
  }
}
```

- [ ] **步骤 2：检查 DevEco 类型诊断并适配 API 名称**

打开 `Index.ets`。预期：大部分符号能解析。如果 DevEco 提示 Canvas context 构造器或 `requestAnimationFrame` 签名与当前 SDK 不一致，只适配这些 API 调用，保持页面职责不变。

- [ ] **步骤 3：在模拟器或手机上运行**

从 DevEco Studio 运行应用。预期：

- 应用以横屏打开。
- 能看到村落背景。
- 左侧摇杆可以移动玩家。
- 玩家不能穿过房屋、古井、竹林边界、灵灯底座或底部围栏。
- 靠近 NPC 和物件时会出现交互按钮。
- 底部出现对话框，并可通过按钮推进。

- [ ] **步骤 4：提交页面集成**

```bash
git add entry/src/main/ets/pages/Index.ets
git commit -m "feat: 接入Canvas游戏页面

将首页替换为横屏游戏画面，接入虚拟摇杆、交互按钮和对话框。
页面驱动GameState更新并通过CanvasRenderer绘制村落场景。

Prompt: 用户确认第一版需要横屏、Canvas自绘、虚拟摇杆和对话交互。"
```

---

### 任务 8：添加 ohos 测试文件和手动验收清单

**文件：**
- 创建：`entry/src/ohosTest/ets/test/CollisionSystem.test.ets`
- 创建：`entry/src/ohosTest/ets/test/InteractionSystem.test.ets`
- 创建：`entry/src/ohosTest/ets/test/QuestSystem.test.ets`
- 创建：`docs/qa/harmony-rpg-mvp-checklist.md`

- [ ] **步骤 1：添加 ohos 测试文件，便于后续迁移到 IDE 测试**

创建 `entry/src/ohosTest/ets/test/CollisionSystem.test.ets`：

```ts
import { describe, expect, it } from '@ohos/hypium';
import { resolveMovement } from '../../../main/ets/game/world/CollisionSystem';

export default function collisionSystemTest() {
  describe('CollisionSystem', () => {
    it('blocks movement when the player would overlap an obstacle', 0, () => {
      const result = resolveMovement(
        { id: 'player', x: 20, y: 20, width: 20, height: 20 },
        { x: 35, y: 20 },
        [{ id: 'wall', x: 45, y: 10, width: 20, height: 60 }],
        { width: 200, height: 200 }
      );
      expect(result.x).assertEqual(20);
      expect(result.y).assertEqual(20);
    });
  });
}
```

创建 `entry/src/ohosTest/ets/test/InteractionSystem.test.ets`：

```ts
import { describe, expect, it } from '@ohos/hypium';
import { findNearestInteractable } from '../../../main/ets/game/world/InteractionSystem';

export default function interactionSystemTest() {
  describe('InteractionSystem', () => {
    it('selects the closest interactable inside the distance limit', 0, () => {
      const target = findNearestInteractable(
        {
          id: 'player',
          name: '旅人',
          position: { x: 100, y: 100 },
          size: { width: 40, height: 50 },
          direction: 'down',
          speed: 180
        },
        [
          {
            id: 'keeper',
            name: '守灯人',
            position: { x: 135, y: 100 },
            size: { width: 40, height: 50 },
            direction: 'left',
            dialogueByPhase: { notStarted: 'keeper-start' },
            fallbackDialogueId: 'keeper-default'
          }
        ],
        [],
        90,
        'notStarted'
      );
      expect(target?.id).assertEqual('keeper');
    });
  });
}
```

创建 `entry/src/ohosTest/ets/test/QuestSystem.test.ets`：

```ts
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
```

- [ ] **步骤 2：添加手动 QA 验收清单**

创建 `docs/qa/harmony-rpg-mvp-checklist.md`：

```md
# Harmony RPG MVP QA Checklist

## Device

- HarmonyOS phone or emulator.
- Landscape orientation.

## Movement

- Player moves continuously with the left joystick.
- Player faces left, right, up, or down based on movement direction.
- Releasing the joystick stops movement.

## Collision

- Player cannot cross the left bamboo border.
- Player cannot cross the top bamboo border.
- Player cannot enter the tea house.
- Player cannot pass through the well.
- Player cannot pass through the spirit lamp base.
- Player cannot leave through the bottom fence.

## Interaction

- Interaction button appears near 守灯人.
- Interaction button appears near 茶铺老板.
- Interaction button appears near 阿梨.
- Interaction button appears near 井边灵石.
- Interaction button appears near 村口灵灯.
- If multiple objects are close, the nearest one is selected.

## Quest

- 守灯人 starts the quest.
- 茶铺老板 gives the well clue after the quest starts.
- 井边灵石 advances the quest after the tea clue.
- 村口灵灯 completes the quest after the spirit stone is found.
- Completed lamp renders as lit.

## UI

- Joystick stays in the lower-left corner.
- Interaction button stays in the lower-right corner.
- Dialogue box does not cover the joystick or interaction button.
- Text fits inside the dialogue box on the target phone.
```

- [ ] **步骤 3：运行逻辑测试**

运行：

```bash
node tools/logic-tests.mjs
```

预期：

```text
logic tests passed
```

- [ ] **步骤 4：如果测试运行器已配置，运行 DevEco ohos 测试**

从 DevEco Studio 运行模块测试目标。预期：碰撞、交互和任务测试通过。如果默认工程骨架缺少 Hypium runner 入口，记录 Node 逻辑测试是当前 MVP 的有效自动化验证方式，并保留 ohos 测试文件作为后续迁移目标。

- [ ] **步骤 5：提交测试文档**

```bash
git add entry/src/ohosTest docs/qa/harmony-rpg-mvp-checklist.md
git commit -m "test: 补充MVP测试与验收清单

加入碰撞、交互和任务推进的ohos测试文件。
补充真机或模拟器手动验收清单，覆盖移动、碰撞、交互、剧情和UI。

Prompt: 用户确认需要第一版剧情小样，并要求后续可验证移动、NPC对话和任务完成。"
```

---

### 任务 9：最终验证和清理

**文件：**
- 按需修改：仅限前面任务已经触碰过的文件。

- [ ] **步骤 1：运行自动化逻辑测试**

运行：

```bash
node tools/logic-tests.mjs
```

预期：

```text
logic tests passed
```

- [ ] **步骤 2：使用 DevEco Studio 构建**

运行默认 debug 构建。预期：应用构建成功，没有 ArkTS 或模块元数据错误。

- [ ] **步骤 3：完成模拟器或真机手动验收**

使用 `docs/qa/harmony-rpg-mvp-checklist.md`。预期：所有必要验收项通过。

- [ ] **步骤 4：检查 git 状态**

运行：

```bash
git status --short
```

预期：工作区干净，或只剩有意保留的最终修复。

- [ ] **步骤 5：仅在需要时提交最终修复**

如果步骤 2 或步骤 3 需要修改，提交这些修复：

```bash
git add <changed-files>
git commit -m "fix: 修正MVP运行验收问题

根据DevEco构建和真机验收结果修正首版RPG原型问题。

Prompt: 用户要求开发鸿蒙原生2D轻量RPG，并完成第一版可玩剧情小样。"
```

如果没有修复，不要创建空提交。

---

## 自查

- 规格覆盖：计划覆盖 HarmonyOS 工程骨架、ArkTS 逻辑模块、Canvas 渲染器、摇杆移动、碰撞、NPC/物件交互、对话、任务推进、手动 QA，以及通过渲染器无关类型预留的 C++ 渲染边界。
- 范围检查：战斗、背包、存档、网络、多地图和外部编辑器仍按要求保持在范围外。
- 占位扫描：计划没有开放式实现占位；DevEco 相关适配步骤只限定在 SDK API 名称差异。
- 类型一致性：任务阶段、对话事件、地图 ID、NPC ID 和文件路径在各任务之间保持一致。
