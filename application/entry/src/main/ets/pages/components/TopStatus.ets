@Component
export struct TopStatus {
  @Prop mood: number = 0;
  @Prop satiety: number = 0;
  @Prop coins: number = 0;
  @Prop feedback: string = '';

  build() {
    Column({ space: 8 }) {
      Row({ space: 10 }) {
        this.MiniMeter('心情', this.mood, '#FF8F9F')
        this.MiniMeter('饱腹', this.satiety, '#8BC8A5')
        Text(`${this.coins} 叶`)
          .height(36)
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor('#8A5A4F')
          .padding({ left: 13, right: 13 })
          .backgroundColor('#FFF0C9')
          .borderRadius(18)
      }
      if (this.feedback.length > 0) {
        Text(this.feedback)
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FF6F87')
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor('#FFFFFC')
          .borderRadius(16)
      }
    }
    .width('100%')
    .padding({ left: 14, right: 14, top: 12, bottom: 8 })
  }

  @Builder
  MiniMeter(label: string, value: number, color: string) {
    Column({ space: 4 }) {
      Row() {
        Text(label)
          .fontSize(11)
          .fontColor('#7D6862')
        Text(`${value}`)
          .fontSize(11)
          .fontWeight(FontWeight.Bold)
          .fontColor(color)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      Progress({ value, total: 100, type: ProgressType.Linear })
        .height(7)
        .width('100%')
        .color(color)
        .backgroundColor('#F3DDE3')
    }
    .height(38)
    .layoutWeight(1)
    .padding({ left: 10, right: 10, top: 5, bottom: 5 })
    .backgroundColor('#FFFFFC')
    .borderRadius(18)
  }
}
