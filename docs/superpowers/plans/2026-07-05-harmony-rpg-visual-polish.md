# Harmony RPG Visual Polish Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Upgrade the first-stage Harmony RPG prototype from debug-like geometric placeholders into a readable procedural art prototype without changing the quest flow.

**Architecture:** Keep gameplay state, collision, dialogue, and quest logic unchanged. Refactor `CanvasRenderer` into clearer drawing layers, add small rendering helpers and quest phase presentation helpers, then polish ArkUI overlay controls in `Index.ets`.

**Tech Stack:** HarmonyOS Stage model, ArkTS, ArkUI Canvas, existing lightweight Node logic tests.

---

## File Structure

- Modify: `entry/src/main/ets/game/render/CanvasRenderer.ets`
  - Owns procedural world rendering, render-layer ordering, object state visuals, actor drawing, interaction highlight, and Canvas task hint.
- Modify: `entry/src/main/ets/pages/Index.ets`
  - Owns ArkUI overlay controls: joystick, interaction button, dialogue panel.
- Modify: `tools/logic-tests.mjs`
  - Adds lightweight checks for quest phase display labels so UI copy has a testable fallback contract.
- Modify: `docs/qa/harmony-rpg-mvp-checklist.md`
  - Adds second-stage visual QA checks.

Do not modify gameplay modules unless visual geometry and collision become visibly inconsistent:

- `entry/src/main/ets/game/core/GameState.ets`
- `entry/src/main/ets/game/story/QuestSystem.ets`
- `entry/src/main/ets/game/story/DialogueSystem.ets`
- `entry/src/main/ets/game/world/InteractionSystem.ets`
- `entry/src/main/ets/game/world/CollisionSystem.ets`
- `entry/src/main/ets/game/world/VillageMap.ets`

---

### Task 1: Add Quest Phase Presentation Helper

**Files:**
- Modify: `entry/src/main/ets/game/render/CanvasRenderer.ets`
- Modify: `tools/logic-tests.mjs`

- [ ] **Step 1: Add a failing logic-test section for phase labels**

Append this block before `console.log('logic tests passed');` in `tools/logic-tests.mjs`:

```js
function getQuestPhaseLabel(phase) {
  const labels = {
    notStarted: '询问守灯人',
    askedKeeper: '前往茶铺',
    askedTeaMaster: '寻找井边灵石',
    foundSpiritStone: '点亮村口灵灯',
    completed: '灵灯已点亮'
  };
  return labels[phase] ?? '继续探索';
}

assert.equal(getQuestPhaseLabel('notStarted'), '询问守灯人');
assert.equal(getQuestPhaseLabel('askedKeeper'), '前往茶铺');
assert.equal(getQuestPhaseLabel('askedTeaMaster'), '寻找井边灵石');
assert.equal(getQuestPhaseLabel('foundSpiritStone'), '点亮村口灵灯');
assert.equal(getQuestPhaseLabel('completed'), '灵灯已点亮');
assert.equal(getQuestPhaseLabel('unknownPhase'), '继续探索');
```

- [ ] **Step 2: Run the logic tests**

Run:

```bash
node tools/logic-tests.mjs
```

Expected: `logic tests passed`

This test duplicates a small pure presentation contract because the current Node runner does not import `.ets` modules directly.

- [ ] **Step 3: Add the ArkTS helper**

In `entry/src/main/ets/game/render/CanvasRenderer.ets`, update imports:

```ts
import { GameStateSnapshot, InteractableObjectData, NpcData, QuestPhase, Rect } from '../core/GameTypes';
```

Add this helper near the bottom of the file, before `rectFromNpc`:

```ts
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
```

- [ ] **Step 4: Use the helper in the quest hint**

Replace the final line in `drawQuestHint`:

```ts
context.fillText(`阶段：${phase}`, 42, 67);
```

with:

```ts
context.fillText(getQuestPhaseLabel(phase as QuestPhase), 42, 67);
```

- [ ] **Step 5: Run the logic tests again**

Run:

```bash
node tools/logic-tests.mjs
```

Expected: `logic tests passed`

---

### Task 2: Refactor Canvas Rendering Into Stable Layers

**Files:**
- Modify: `entry/src/main/ets/game/render/CanvasRenderer.ets`

- [ ] **Step 1: Replace the render body with explicit layers**

Replace the world drawing block inside `render` with:

```ts
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
```

The resulting `render` method should keep `drawScreenBackground`, `resolveWorldTransform`, `save`, `translate`, `scale`, `restore`, and `drawQuestHint` in the same order.

- [ ] **Step 2: Rename the old background method**

Rename:

```ts
private drawBackground(context: CanvasRenderingContext2D, snapshot: GameStateSnapshot): void {
```

to:

```ts
private drawGroundLayer(context: CanvasRenderingContext2D, snapshot: GameStateSnapshot): void {
```

- [ ] **Step 3: Rename the old map method**

Rename:

```ts
private drawMap(context: CanvasRenderingContext2D, snapshot: GameStateSnapshot): void {
```

to:

```ts
private drawSceneLayer(context: CanvasRenderingContext2D, snapshot: GameStateSnapshot): void {
```

- [ ] **Step 4: Rename object rendering and pass quest phase**

Rename:

```ts
private drawObjects(
  context: CanvasRenderingContext2D,
  objects: InteractableObjectData[],
  nearbyInteractableId: string | undefined,
  lampCompleted: boolean
): void {
```

to:

```ts
private drawQuestObjects(
  context: CanvasRenderingContext2D,
  objects: InteractableObjectData[],
  nearbyInteractableId: string | undefined,
  phase: QuestPhase
): void {
```

Inside the method, add:

```ts
const lampCompleted = phase === 'completed';
```

- [ ] **Step 5: Update the player method signature**

Change:

```ts
private drawPlayer(context: CanvasRenderingContext2D, x: number, y: number, width: number, height: number): void {
```

to:

```ts
private drawPlayer(
  context: CanvasRenderingContext2D,
  x: number,
  y: number,
  width: number,
  height: number,
  direction: string
): void {
```

Keep `direction` unused until Task 4.

- [ ] **Step 6: Run the logic tests**

Run:

```bash
node tools/logic-tests.mjs
```

Expected: `logic tests passed`

---

### Task 3: Upgrade Ground And Static Scene Rendering

**Files:**
- Modify: `entry/src/main/ets/game/render/CanvasRenderer.ets`

- [ ] **Step 1: Add scene color constants**

Add these constants after `WorldTransform`:

```ts
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
```

- [ ] **Step 2: Update the screen background**

Replace `drawScreenBackground` body with:

```ts
context.fillStyle = COLORS.screen;
context.fillRect(0, 0, viewport.width, viewport.height);
```

- [ ] **Step 3: Replace the ground layer**

Replace `drawGroundLayer` body with:

```ts
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
```

- [ ] **Step 4: Replace the scene layer**

Replace `drawSceneLayer` body with:

```ts
context.fillStyle = COLORS.grassDeep;
context.fillRect(0, 0, 90, snapshot.map.size.height);
context.fillStyle = '#C9DFAA';
context.fillRect(0, 0, snapshot.map.size.width, 70);

this.drawBambooBorder(context);
this.drawTeaHouse(context);
this.drawWell(context);
```

- [ ] **Step 5: Add static scene helper methods**

Add these methods inside `CanvasRenderer`, before `drawQuestObjects`:

```ts
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
```

- [ ] **Step 6: Run the logic tests**

Run:

```bash
node tools/logic-tests.mjs
```

Expected: `logic tests passed`

---

### Task 4: Upgrade Quest Object And Actor Rendering

**Files:**
- Modify: `entry/src/main/ets/game/render/CanvasRenderer.ets`

- [ ] **Step 1: Replace quest object rendering**

Replace the body of `drawQuestObjects` with:

```ts
const lampCompleted = phase === 'completed';
objects.forEach((object) => {
  const highlighted = nearbyInteractableId === object.id;
  if (object.kind === 'spiritStone') {
    this.drawSpiritStone(context, object, highlighted, phase);
  } else {
    this.drawSpiritLamp(context, object, highlighted, lampCompleted, phase);
  }
});
```

- [ ] **Step 2: Add quest object helpers**

Add these methods inside `CanvasRenderer`, before `drawNpcs`:

```ts
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
```

- [ ] **Step 3: Replace NPC rendering**

Replace the body of `drawNpcs` with:

```ts
npcs.forEach((npc) => {
  const highlighted = nearbyInteractableId === npc.id;
  this.drawNpc(context, npc, highlighted);
});
```

- [ ] **Step 4: Add actor helpers**

Add these methods inside `CanvasRenderer`, before `drawPlayer`:

```ts
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
```

- [ ] **Step 5: Replace player rendering**

Replace `drawPlayer` body with:

```ts
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
```

- [ ] **Step 6: Run the logic tests**

Run:

```bash
node tools/logic-tests.mjs
```

Expected: `logic tests passed`

---

### Task 5: Polish Canvas Quest Hint

**Files:**
- Modify: `entry/src/main/ets/game/render/CanvasRenderer.ets`

- [ ] **Step 1: Replace quest hint drawing**

Replace the body of `drawQuestHint` with:

```ts
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
context.fillText(getQuestPhaseLabel(phase as QuestPhase), 42, 70);
```

- [ ] **Step 2: Run the logic tests**

Run:

```bash
node tools/logic-tests.mjs
```

Expected: `logic tests passed`

---

### Task 6: Polish ArkUI Overlay Controls

**Files:**
- Modify: `entry/src/main/ets/pages/Index.ets`

- [ ] **Step 1: Replace the interaction button style**

Replace the `Button(...)` chain inside the interaction button block with:

```ts
Button(this.dialogueText.length > 0 ? '继续' : '交互')
  .fontSize(18)
  .fontWeight(FontWeight.Bold)
  .fontColor('#3D321E')
  .backgroundColor('rgba(245, 210, 107, 0.94)')
  .width(96)
  .height(96)
  .borderRadius(48)
  .border({ width: 3, color: 'rgba(255, 246, 196, 0.92)' })
  .shadow({ radius: 16, color: 'rgba(66, 47, 20, 0.24)', offsetX: 0, offsetY: 5 })
  .position({ x: this.viewport.width - 140, y: this.viewport.height - 142 })
  .onClick(() => {
    this.input.pressInteraction();
    this.tick(16);
  })
```

- [ ] **Step 2: Replace the dialogue panel style**

Replace the dialogue `Column()` style chain after the two `Text` nodes with:

```ts
.alignItems(HorizontalAlign.Start)
.padding({ left: 26, right: 26, top: 16, bottom: 16 })
.width(Math.max(420, this.viewport.width - 330))
.height(124)
.backgroundColor('rgba(42, 34, 28, 0.90)')
.border({ width: 1, color: 'rgba(247, 232, 199, 0.24)' })
.borderRadius(8)
.shadow({ radius: 18, color: 'rgba(32, 24, 18, 0.26)', offsetX: 0, offsetY: 4 })
.position({ x: 150, y: this.viewport.height - 148 })
```

- [ ] **Step 3: Update dialogue text sizing**

Within the dialogue panel, keep the speaker text at 18 and change the body text chain to:

```ts
Text(this.dialogueText)
  .fontSize(21)
  .fontColor('#FFF9EA')
  .lineHeight(30)
  .maxLines(2)
  .width('100%')
```

- [ ] **Step 4: Replace the joystick visuals**

In `Joystick()`, replace the two `Circle()` style chains with:

```ts
Circle()
  .width(132)
  .height(132)
  .fill('rgba(47, 51, 38, 0.20)')
  .stroke('rgba(255, 255, 255, 0.45)')
  .strokeWidth(2)
Circle()
  .width(58)
  .height(58)
  .fill('rgba(255, 249, 234, 0.90)')
  .stroke('rgba(64, 70, 50, 0.25)')
  .strokeWidth(2)
  .shadow({ radius: 10, color: 'rgba(32, 32, 24, 0.18)', offsetX: 0, offsetY: 3 })
  .translate({ x: this.joystickKnobOffsetX, y: this.joystickKnobOffsetY })
```

- [ ] **Step 5: Run the logic tests**

Run:

```bash
node tools/logic-tests.mjs
```

Expected: `logic tests passed`

---

### Task 7: Update QA Checklist

**Files:**
- Modify: `docs/qa/harmony-rpg-mvp-checklist.md`

- [ ] **Step 1: Append second-stage visual QA checks**

Append this section to the end of `docs/qa/harmony-rpg-mvp-checklist.md`:

```md

## 第二阶段视觉升级

- 地图能清楚区分草地、土路、竹林、茶铺、古井和底部围栏。
- 玩家和 3 个 NPC 都具备身体、头部、阴影和基础朝向提示。
- 靠近 NPC、井边灵石或村口灵灯时，当前目标出现统一高亮。
- 灵石在可调查阶段出现冷色微光。
- 灵灯在任务完成后出现稳定暖色光晕。
- 左上任务提示显示中文阶段文案，而不是内部阶段枚举名。
- 交互按钮、摇杆和对话框在横屏下不互相遮挡。
```

- [ ] **Step 2: Run the logic tests**

Run:

```bash
node tools/logic-tests.mjs
```

Expected: `logic tests passed`

---

### Task 8: Final Verification And Optional Single Commit

**Files:**
- Verify all modified files.

- [ ] **Step 1: Inspect changed files**

Run:

```bash
git status --short
```

Expected: changed files include only the visual polish plan/spec, renderer, page, logic tests, and QA checklist unless the implementer intentionally changed collision geometry.

- [ ] **Step 2: Run logic tests**

Run:

```bash
node tools/logic-tests.mjs
```

Expected:

```text
logic tests passed
```

- [ ] **Step 3: Run Harmony build when DevEco CLI is available**

If using the checked-in DevEco/Hvigor environment, run:

```bash
/Applications/DevEco-Studio.app/Contents/tools/node/bin/node /Applications/DevEco-Studio.app/Contents/tools/hvigor/bin/hvigorw.js --mode module -p module=entry@default assembleHap
```

Expected: build completes without ArkTS syntax errors.

- [ ] **Step 4: Manual visual QA**

Open the app on a HarmonyOS phone or simulator in landscape and verify:

```text
地图对象可辨识
玩家和 NPC 不再是纯矩形
当前交互目标高亮准确
灵石和灵灯随任务阶段变化
UI 不遮挡主要玩法区域
对话文本不溢出
```

- [ ] **Step 5: Optional single commit only after review**

Only commit if the user asks for it. Use one consolidated commit:

```bash
git add entry/src/main/ets/game/render/CanvasRenderer.ets entry/src/main/ets/pages/Index.ets tools/logic-tests.mjs docs/qa/harmony-rpg-mvp-checklist.md docs/superpowers/specs/2026-07-05-harmony-rpg-visual-polish-design.md docs/superpowers/plans/2026-07-05-harmony-rpg-visual-polish.md
git commit -m "style: 优化RPG程序化视觉表现

升级村落地图、角色、任务物件、交互高亮和横屏UI表现。
保持第一阶段任务流程不变，并补充第二阶段视觉QA清单。

Prompt: 用户确认第一阶段设计基本符合要求，要求开始第二阶段并选择视觉升级优先。"
```
