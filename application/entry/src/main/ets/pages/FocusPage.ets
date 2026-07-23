import { DdlTask } from './AppState';
import { HomePage } from './HomePage';

@Component
export struct FocusPage {
  @Prop focusDuration: number = 0;
  @Prop focusSecondsLeft: number = 0;
  @Prop focusRunning: boolean = false;
  @Prop focusSliderValue: number = 25;
  @Prop focusCustomName: string = '';
  @Prop selectedTaskId: number = -1;
  @Prop focusMinutesToday: number = 0;
  @Prop focusCount: number = 0;
  @Prop doroWords: string = '';
  onSliderChange?: (value: number) => void;
  onToggle?: () => void;
  onReset?: () => void;
  onSelectDdl?: () => void;
  onDdlSelect?: (taskId: number) => void;
  onCustomNameChange?: (value: string) => void;
  onTouchDoro?: () => void;

  build() {
    Scroll() {
      Column({ space: 16 }) {
        this.BrandHeader('专注花园', this.selectedTaskId === -1 ? (this.focusCustomName.length > 0 ? '专注：' + this.focusCustomName : '自定义专注时间') : 'Doro安静陪你完成' + this.focusDuration.toString() + '分钟')

        Column({ space: 8 }) {
          Text('选择时长')
            .width('100%')
            .fontSize(13)
            .fontColor('#9B7D76')
          Slider({
            value: this.focusSliderValue,
            min: 1,
            max: 180,
            step: 1,
            style: SliderStyle.OutSet
          })
            .width('100%')
            .onChange((value: number) => {
              if (this.onSliderChange !== undefined) {
                this.onSliderChange(value);
              }
            })
          Row({ space: 6 }) {
            Text(Math.floor(this.focusSliderValue / 60).toString() + ' 时')
              .fontSize(14)
              .fontColor('#5A403A')
            Text((Math.round(this.focusSliderValue) % 60).toString() + ' 分')
              .fontSize(14)
              .fontColor('#FF7F95')
            Text('共 ' + Math.round(this.focusSliderValue).toString() + ' 分钟')
              .fontSize(13)
              .fontColor('#9B7D76')
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
        }
        .width('100%')

        Column({ space: 8 }) {
          Text('关联DDL')
            .width('100%')
            .fontSize(13)
            .fontColor('#9B7D76')
          Button(this.selectedTaskTitle())
            .width('100%')
            .height(44)
            .fontColor('#5A403A')
            .backgroundColor('#FFFFFC')
            .borderRadius(22)
            .onClick(() => {
              if (!this.focusRunning && this.onSelectDdl !== undefined) {
                this.onSelectDdl();
              }
            })
          if (this.selectedTaskId === -1) {
            TextInput({ placeholder: '输入专注名称...', text: this.focusCustomName })
              .height(42)
              .fontSize(14)
              .backgroundColor('#FFF4F7')
              .borderRadius(21)
              .onChange((value: string) => {
                if (this.onCustomNameChange !== undefined) {
                  this.onCustomNameChange(value);
                }
              })
          }
        }
        .width('100%')

        Text(this.formatTime(this.focusSecondsLeft))
          .width('100%')
          .height(118)
          .textAlign(TextAlign.Center)
          .fontSize(52)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FF7F95')
          .backgroundColor('#FFFFFC')
          .borderRadius(24)
        this.DoroScene('focus')
        Row({ space: 10 }) {
          Button(this.focusRunning ? '暂停专注' : '开始专注')
            .layoutWeight(1)
            .height(48)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
            .backgroundColor('#FF8F9F')
            .borderRadius(24)
            .onClick(() => {
              if (this.onToggle !== undefined) {
                this.onToggle();
              }
            })
          Button('重置')
            .layoutWeight(1)
            .height(48)
            .fontColor('#5A403A')
            .fontWeight(FontWeight.Bold)
            .backgroundColor('#FFFFFC')
            .borderRadius(24)
            .onClick(() => {
              if (this.onReset !== undefined) {
                this.onReset();
              }
            })
        }
        Text('今日累计：' + this.focusMinutesToday.toString() + '分钟 · 番茄钟 ' + this.focusCount.toString() + ' 个')
          .fontSize(14)
          .fontColor('#9B7D76')
          .width('100%')
          .textAlign(TextAlign.Center)
      }
      .padding(16)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  BrandHeader(title: string, subtitle: string) {
    Column({ space: 6 }) {
      Text(title)
        .width('100%')
        .fontSize(27)
        .fontWeight(FontWeight.Bold)
        .fontColor('#5A403A')
      Text(subtitle)
        .width('100%')
        .fontSize(13)
        .fontColor('#8D746D')
    }
    .padding({ left: 18, right: 18, top: 20, bottom: 10 })
  }

  @Builder
  DoroScene(mode: string) {
    Stack({ alignContent: Alignment.Center }) {
      Column() {
        Stack({ alignContent: Alignment.Center }) {
          Circle()
            .width(mode === 'focus' ? 138 : 176)
            .height(mode === 'focus' ? 138 : 176)
            .fill('#FFD9E2')
          Circle()
            .width(mode === 'focus' ? 104 : 132)
            .height(mode === 'focus' ? 104 : 132)
            .fill('#FFF9F4')
          Column({ space: 5 }) {
            Text('Doro')
              .fontSize(mode === 'focus' ? 24 : 31)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FF7F95')
            Text(mode === 'focus' ? '安静陪伴中' : '图片占位')
              .fontSize(12)
              .fontColor('#AD7A72')
          }
        }
        .onClick(() => {
          if (this.onTouchDoro !== undefined) {
            this.onTouchDoro();
          }
        })
      }
    }
    .height(mode === 'focus' ? 246 : 360)
    .width('100%')
    .backgroundColor(mode === 'focus' ? '#FFF0F5' : '#FFEAF0')
    .borderRadius(24)
    .shadow({ radius: 24, color: '#26FF9EAF', offsetX: 0, offsetY: 10 })
  }

  private selectedTaskTitle(): string {
    if (this.selectedTaskId === -1) {
      if (this.focusCustomName.length > 0) {
        return this.focusCustomName;
      }
      return '自定义专注';
    }
    return '选择一个 DDL';
  }

  private pad(value: number): string {
    return value < 10 ? `0${value}` : `${value}`;
  }

  private formatTime(seconds: number): string {
    const m: number = Math.floor(seconds / 60);
    const s: number = seconds % 60;
    return this.pad(m) + ':' + this.pad(s);
  }
}
