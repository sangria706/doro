import { TopStatus } from './components/TopStatus';

@Component
export struct HomePage {
  @Prop mood: number = 0;
  @Prop satiety: number = 0;
  @Prop coins: number = 0;
  @Prop feedback: string = '';
  @Prop comfort: number = 0;
  @Prop pendingCount: number = 0;
  @Prop overdueCount: number = 0;
  @Prop doroWords: string = '';
  onFeed?: () => void;
  onTouchDoro?: () => void;
  onDress?: () => void;
  onDialogue?: () => void;

  build() {
    Column() {
      TopStatus({ mood: this.mood, satiety: this.satiety, coins: this.coins, feedback: this.feedback })
      Scroll() {
        Column({ space: 14 }) {
          this.DoroScene('home')
          Row({ space: 10 }) {
            Button('喂食')
              .layoutWeight(1)
              .height(48)
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Bold)
              .backgroundColor('#FF8F9F')
              .borderRadius(24)
              .onClick(() => {
                if (this.onFeed !== undefined) {
                  this.onFeed();
                }
              })
            Button('抚摸')
              .layoutWeight(1)
              .height(48)
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Bold)
              .backgroundColor('#BBA6E8')
              .borderRadius(24)
              .onClick(() => {
                if (this.onTouchDoro !== undefined) {
                  this.onTouchDoro();
                }
              })
            Button('装扮')
              .layoutWeight(1)
              .height(48)
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Bold)
              .backgroundColor('#8BC8A5')
              .borderRadius(24)
              .onClick(() => {
                if (this.onDress !== undefined) {
                  this.onDress();
                }
              })
            Button('对话')
              .layoutWeight(1)
              .height(48)
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Bold)
              .backgroundColor('#F5A6C8')
              .borderRadius(24)
              .onClick(() => {
                if (this.onDialogue !== undefined) {
                  this.onDialogue();
                }
              })
          }
          this.SpeechCard()
          Row({ space: 10 }) {
            this.HomeStat('舒适度', `${this.comfort} 星`, '#BBA6E8')
            this.HomeStat('待办DDL', `${this.pendingCount} 个`, '#FF8F9F')
            this.HomeStat('逾期', `${this.overdueCount} 个`, '#F59A7A')
          }
        }
        .padding({ left: 16, right: 16, bottom: 24 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  DoroScene(mode: string) {
    Stack({ alignContent: Alignment.Center }) {
      Column() {
        Row() {
          Text('沙发')
            .fontSize(15)
            .fontColor('#AD7A72')
          Blank()
          Text('绿植')
            .fontSize(15)
            .fontColor('#79B58F')
          Blank()
          Text('相框')
            .fontSize(15)
            .fontColor('#9B7DCE')
        }
        .width('78%')
        .margin({ bottom: 18 })

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

        Row({ space: 8 }) {
          Text('花瓣')
            .fontSize(12)
            .fontColor('#C08490')
          Text('星星')
            .fontSize(12)
            .fontColor('#C08490')
          Text('光点')
            .fontSize(12)
            .fontColor('#C08490')
        }
        .margin({ top: 18 })
      }
    }
    .height(mode === 'home' ? 360 : 246)
    .width('100%')
    .backgroundColor(mode === 'focus' ? '#FFF0F5' : '#FFEAF0')
    .borderRadius(24)
    .shadow({ radius: 24, color: '#26FF9EAF', offsetX: 0, offsetY: 10 })
  }

  @Builder
  SpeechCard() {
    Column({ space: 8 }) {
      Text('Doro说')
        .fontSize(12)
        .fontColor('#9B7D76')
      Text(`"${this.doroWords}"`)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#5A403A')
        .lineHeight(27)
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .padding(18)
    .backgroundColor('#FFFFFC')
    .borderRadius(22)
    .shadow({ radius: 18, color: '#22FF9EAF', offsetX: 0, offsetY: 6 })
  }

  @Builder
  HomeStat(label: string, value: string, color: string) {
    Column({ space: 6 }) {
      Text(label)
        .fontSize(12)
        .fontColor('#9B7D76')
      Text(value)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
    }
    .alignItems(HorizontalAlign.Start)
    .layoutWeight(1)
    .padding(14)
    .backgroundColor('#FFFFFC')
    .borderRadius(20)
  }
}
