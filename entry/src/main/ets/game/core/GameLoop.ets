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
