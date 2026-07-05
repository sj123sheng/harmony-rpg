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
