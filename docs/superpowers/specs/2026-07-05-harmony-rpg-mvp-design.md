# Harmony RPG MVP 设计

## 背景

本项目目标是在当前目录下开发一款面向 HarmonyOS 原生系统的轻量 2D RPG 游戏。
第一版不追求完整商业化内容，而是先完成一个可玩的剧情小样，验证移动、碰撞、
对话、任务推进和基础渲染链路。

## 已确认方向

- 平台：HarmonyOS 原生工程。
- 技术：ArkTS / ArkUI 起步，使用 Canvas 自绘。
- 架构：ArkTS 逻辑 + C++ 渲染预留。
- 类型：俯视角 2D RPG。
- 风格：手绘卡通风。
- 屏幕：横屏。
- 操作：左下角虚拟摇杆，四方向自由移动。
- MVP：剧情小样，而不是纯技术 Demo 或完整演示关。
- 世界观：东方幻想村落。

## MVP 玩法范围

第一版实现一个小型村落场景：

- 一个可移动主角。
- 2-3 个 NPC。
- 若干障碍物，例如房屋、树、石灯、围栏。
- 1-2 个可交互物件。
- 靠近 NPC 或物件时显示交互按钮。
- 通过对话和调查推进一个短任务。

第一版暂不包含：

- 背包、装备、角色养成。
- 战斗系统。
- 多地图切换。
- 存档系统。
- 网络、账号、排行榜。
- 外部地图编辑器。

## 剧情小样

建议第一条任务为“点亮村口灵灯”：

1. 玩家和村口守灯人对话，得知村口灵灯熄灭。
2. 玩家去茶铺老板处询问线索。
3. 玩家调查古井旁的灵石。
4. 玩家回到村口点亮石灯，任务完成。

这个流程覆盖第一版需要验证的核心 RPG 能力：移动、碰撞、靠近交互、对话、
任务阶段推进、物件状态变化。

## 工程结构

建议初始工程结构如下：

```text
entry/src/main/ets/
  pages/
    Index.ets
  game/
    core/
      GameLoop.ets
      GameState.ets
      InputController.ets
    world/
      VillageMap.ets
      CollisionSystem.ets
      InteractionSystem.ets
    actors/
      Player.ets
      Npc.ets
    story/
      DialogueSystem.ets
      QuestSystem.ets
    render/
      CanvasRenderer.ets
      RenderTypes.ets
```

职责说明：

- `Index.ets`：游戏入口页面，负责横屏容器、Canvas、触控输入绑定。
- `GameLoop.ets`：驱动每帧更新和渲染。
- `GameState.ets`：保存当前世界状态，包括玩家、NPC、任务、对话状态。
- `InputController.ets`：处理虚拟摇杆和交互按钮输入。
- `VillageMap.ets`：提供第一张村落地图配置。
- `CollisionSystem.ets`：负责碰撞检测和位置修正。
- `InteractionSystem.ets`：负责检测当前可交互 NPC 或物件。
- `Player.ets` / `Npc.ets`：定义角色状态和基础行为。
- `DialogueSystem.ets`：管理对话展示和对话事件。
- `QuestSystem.ets`：管理任务阶段推进。
- `CanvasRenderer.ets`：当前 Canvas 渲染实现。
- `RenderTypes.ets`：定义渲染指令结构，为未来替换为 C++ 渲染层预留边界。

## 架构原则

玩法逻辑不直接依赖 Canvas API。逻辑层更新 `GameState`，渲染层读取世界快照或渲染
指令并绘制画面。这样第一版仍然轻量，但后续可以将渲染层替换为
`XComponent` / C++，而不重写任务、碰撞和交互逻辑。

## 数据结构

第一版使用 ArkTS 对象配置，不急于引入外部 JSON。这样可以获得更直接的类型检查，
也便于在 DevEco Studio 中快速修改。

核心数据包括：

```text
MapData
- 地图尺寸、瓦片尺寸
- 背景层/装饰层
- 碰撞矩形
- NPC 列表
- 可交互物件列表
- 出生点

NpcData
- id、名字、位置、朝向
- 默认对话
- 任务阶段相关对话

QuestData
- id、当前阶段
- 触发条件
- 完成条件
- 阶段变化后解锁的新对话/交互

DialogueData
- 对话 id
- 说话人
- 文本数组
- 结束后触发的事件
```

## 运行数据流

```text
触控输入
 -> InputController 计算摇杆方向/交互按钮
 -> GameLoop 每帧 update
 -> Player 根据输入尝试移动
 -> CollisionSystem 修正位置，避免穿墙
 -> InteractionSystem 判断附近 NPC/物件
 -> DialogueSystem / QuestSystem 推进剧情状态
 -> GameState 产出当前世界快照
 -> CanvasRenderer 根据快照绘制画面
```

## UI 设计

第一版 UI 保持克制：

- 左下角：虚拟摇杆。
- 右下角：靠近对象时显示交互按钮。
- 底部：对话框，显示角色名和文本。
- 画面主体：村落地图、主角、NPC、物件。

不在第一版加入复杂菜单、背包、装备面板或存档界面。

## 异常与边界处理

- 找不到对话或任务配置时，游戏不中断，显示默认提示。
- 玩家移动到障碍物边缘时，进行位置回退或滑动修正，避免卡住。
- 多个交互对象重叠时，选择距离最近的对象。
- 画布尺寸变化时，重新计算缩放和虚拟摇杆位置，保证横屏适配。
- 第一版不接网络，不处理服务端状态。

## 验证方式

- 对碰撞、距离判定、任务阶段推进做轻量测试。
- 在真机或模拟器上手动验证移动、碰撞、NPC 对话、物件交互和任务完成流程。
- 检查横屏 UI 是否遮挡地图主体、NPC、交互按钮和对话框。

## 后续扩展

在 MVP 稳定后，可以按优先级逐步扩展：

1. 替换占位图形为正式手绘素材。
2. 增加多地图和场景切换。
3. 增加简单背包和任务日志。
4. 增加轻量战斗或事件解谜。
5. 评估是否将渲染层下沉为 `XComponent` / C++。
