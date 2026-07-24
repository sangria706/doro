interface AudioLoadOptions {
  filePath: string;
}

interface AudioPlayOptions {
  loop: number;
  priority: number;
  volume: number;
  rate: number;
}

interface SoundPoolCreateOptions {
  maxStreams: number;
  streamType: number;
}

interface SoundPoolApi {
  load(options: AudioLoadOptions, callback: () => void): void;
  play(id: number, count: number, options: AudioPlayOptions): void;
}

interface AudioModuleApi {
  createSoundPool(options: SoundPoolCreateOptions): SoundPoolApi;
}

@Component
export struct AchievementUnlockOverlay {
  @Prop title: string = '';
  @Prop completedText: string = '已完成';
  onOpen?: () => void;
  onClose?: () => void;

  private autoCloseTimer: number = -1;

  aboutToAppear(): void {
    this.playUnlockTone();
    this.autoCloseTimer = setTimeout(() => {
      if (this.onClose !== undefined) {
        this.onClose();
      }
    }, 3000) as number;
  }

  aboutToDisappear(): void {
    if (this.autoCloseTimer !== -1) {
      clearTimeout(this.autoCloseTimer);
      this.autoCloseTimer = -1;
    }
  }

  private playUnlockTone(): void {
    try {
      const audioModule: AudioModuleApi | null = globalThis.requireNapi('audio') as AudioModuleApi;
      if (audioModule === null) {
        return;
      }
      const createOptions: SoundPoolCreateOptions = { maxStreams: 1, streamType: 3 };
      const soundPool: SoundPoolApi = audioModule.createSoundPool(createOptions);
      const loadOptions: AudioLoadOptions = {
        filePath: 'common/achievement_unlock.wav'
      };
      const playOptions: AudioPlayOptions = {
        loop: 0,
        priority: 1,
        volume: 1,
        rate: 1.0
      };
      soundPool.load(loadOptions, () => {
        soundPool.play(0, 1, playOptions);
      });
    } catch (_error) {
    }
  }

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#00000000')
        .onClick(() => {
          if (this.onOpen !== undefined) {
            this.onOpen();
          }
        })

      Column({ space: 10 }) {
        Text('成就解锁')
          .fontSize(12)
          .fontColor('#FF8F9F')
          .fontWeight(FontWeight.Bold)
        Text(this.title)
          .fontSize(22)
          .fontColor('#5A403A')
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
        Text(this.completedText)
          .fontSize(14)
          .fontColor('#8D746D')
        Text('点击查看成就页')
          .fontSize(12)
          .fontColor('#BBA6E8')
      }
      .width('82%')
      .padding(20)
      .backgroundColor('#FFFFFC')
      .borderRadius(24)
      .shadow({ radius: 30, color: '#33FF9EAF', offsetX: 0, offsetY: 10 })
      .onClick(() => {
        if (this.onOpen !== undefined) {
          this.onOpen();
        }
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#66000000')
    .alignContent(Alignment.Center)
  }
}
