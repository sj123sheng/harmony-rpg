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
  if (isOutOfBounds(nextX, bounds) || collisions.some((rect) => rectsOverlap(nextX, rect))) {
    resolvedX = actor.x;
  }

  const nextY = { ...actor, x: resolvedX, y: desiredPosition.y };
  let resolvedY = desiredPosition.y;
  if (isOutOfBounds(nextY, bounds) || collisions.some((rect) => rectsOverlap(nextY, rect))) {
    resolvedY = actor.y;
  }

  return { x: resolvedX, y: resolvedY };
}

function isOutOfBounds(rect, bounds) {
  return rect.x < 0 ||
    rect.y < 0 ||
    rect.x + rect.width > bounds.width ||
    rect.y + rect.height > bounds.height;
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
assert.deepEqual(resolveMovement(actor, { x: -5, y: 20 }, [], { width: 200, height: 200 }), { x: 20, y: 20 });
assert.deepEqual(resolveMovement(actor, { x: 35, y: 80 }, [wall], { width: 200, height: 200 }), { x: 20, y: 80 });

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

console.log('logic tests passed');
