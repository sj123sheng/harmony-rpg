import { GameLoop } from '../game/core/GameLoop';
import { GameState } from '../game/core/GameState';
import { Vector2 } from '../game/core/GameTypes';
import { getInteractionActionText } from '../game/core/InteractionFeedback';
import { InputController, JoystickLayout } from '../game/core/InputController';
import { CanvasRenderer, Viewport } from '../game/render/CanvasRenderer';

const JOYSTICK_TOUCH_SIZE: number = 240;
const JOYSTICK_VISUAL_SIZE: number = 132;
const JOYSTICK_KNOB_SIZE: number = 58;

@Entry
@Component
struct Index {
  private readonly gameState: GameState = new GameState();
  private readonly input: InputController = new InputController();
  private readonly loop: GameLoop = new GameLoop();
  private readonly renderer: CanvasRenderer = new CanvasRenderer();
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(new RenderingContextSettings(true));
  private timerId: number = -1;
  @State private viewport: Viewport = { width: 1280, height: 720 };
  @State private joystickKnobOffsetX: number = 0;
  @State private joystickKnobOffsetY: number = 0;
  @State private dialogueSpeaker: string = '';
  @State private dialogueText: string = '';
  @State private showInteractionButton: boolean = false;
  @State private interactionButtonText: string = '交互';

  aboutToAppear(): void {
    this.loop.reset();
  }

  aboutToDisappear(): void {
    if (this.timerId >= 0) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }

  build() {
    Stack() {
      Canvas(this.context)
        .width('100%')
        .height('100%')
        .onReady(() => {
          this.startLoop();
        })
        .onTouch((event: TouchEvent) => {
          this.handleCanvasTouch(event);
        })

      this.Joystick()

      if (this.showInteractionButton || this.dialogueText.length > 0) {
        Button(this.dialogueText.length > 0 ? '继续' : this.interactionButtonText)
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
      }

      if (this.dialogueText.length > 0) {
        Column() {
          Text(this.dialogueSpeaker)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#F7E8C7')
            .width('100%')
          Text(this.dialogueText)
            .fontSize(21)
            .fontColor('#FFF9EA')
            .lineHeight(30)
            .maxLines(2)
            .width('100%')
        }
        .alignItems(HorizontalAlign.Start)
        .padding({ left: 26, right: 26, top: 16, bottom: 16 })
        .width(this.viewport.width < 600 ? Math.max(180, this.viewport.width - 48) : Math.max(360, this.viewport.width - 420))
        .height(124)
        .backgroundColor('rgba(42, 34, 28, 0.90)')
        .border({ width: 1, color: 'rgba(247, 232, 199, 0.24)' })
        .borderRadius(8)
        .shadow({ radius: 18, color: 'rgba(32, 24, 18, 0.26)', offsetX: 0, offsetY: 4 })
        .position({ x: this.viewport.width < 600 ? 24 : 210, y: this.viewport.width < 600 ? 12 : this.viewport.height - 148 })
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
        .width(JOYSTICK_VISUAL_SIZE)
        .height(JOYSTICK_VISUAL_SIZE)
        .fill('rgba(47, 51, 38, 0.20)')
        .stroke('rgba(255, 255, 255, 0.45)')
        .strokeWidth(2)
      Circle()
        .width(JOYSTICK_KNOB_SIZE)
        .height(JOYSTICK_KNOB_SIZE)
        .fill('rgba(255, 249, 234, 0.90)')
        .stroke('rgba(64, 70, 50, 0.25)')
        .strokeWidth(2)
        .shadow({ radius: 10, color: 'rgba(32, 32, 24, 0.18)', offsetX: 0, offsetY: 3 })
        .translate({ x: this.joystickKnobOffsetX, y: this.joystickKnobOffsetY })
    }
    .width(JOYSTICK_TOUCH_SIZE)
    .height(JOYSTICK_TOUCH_SIZE)
    .backgroundColor('rgba(0, 0, 0, 0.001)')
    .position(this.getJoystickTouchOrigin())
    .onTouch((event: TouchEvent) => {
      this.handleJoystickTouch(event);
    })
  }

  private handleCanvasTouch(event: TouchEvent): void {
    const layout = this.getJoystickLayout();
    event.touches.forEach((touch) => {
      if (event.type === TouchType.Down || event.type === TouchType.Move) {
        if (this.isInsideJoystickTouchArea(touch.x, touch.y)) {
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

  private handleJoystickTouch(event: TouchEvent): void {
    const origin = this.getJoystickTouchOrigin();
    const layout = this.getJoystickLayout();
    event.touches.forEach((touch) => {
      if (event.type === TouchType.Down || event.type === TouchType.Move) {
        this.input.setJoystick(touch.id, { x: origin.x + touch.x, y: origin.y + touch.y }, layout);
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

  private getJoystickTouchOrigin(): Vector2 {
    const layout = this.getJoystickLayout();
    return {
      x: layout.center.x - JOYSTICK_TOUCH_SIZE / 2,
      y: layout.center.y - JOYSTICK_TOUCH_SIZE / 2
    };
  }

  private isInsideJoystickTouchArea(x: number, y: number): boolean {
    const origin = this.getJoystickTouchOrigin();
    return x >= origin.x &&
      x <= origin.x + JOYSTICK_TOUCH_SIZE &&
      y >= origin.y &&
      y <= origin.y + JOYSTICK_TOUCH_SIZE;
  }

  private startLoop(): void {
    if (this.timerId >= 0) {
      return;
    }
    this.loop.reset();
    this.timerId = setInterval(() => {
      this.renderFrame(Date.now());
    }, 16);
  }

  private renderFrame(timestamp: number): void {
    let delta = this.loop.nextDelta(timestamp);
    if (delta === 0) {
      delta = 0.016;
    }
    this.tick(delta * 1000);
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
    this.interactionButtonText = getInteractionActionText(snapshot.nearbyInteractable);
    this.renderer.render(this.context, snapshot, this.viewport);
  }
}
