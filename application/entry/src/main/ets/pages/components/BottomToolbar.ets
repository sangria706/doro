@Component
export struct BottomToolbar {
  @Prop activeTab: number = 0;
  @Prop pendingCount: number = 0;
  onTabChange?: (index: number) => void;

  build() {
    Row({ space: 4 }) {
      this.ToolItem('家园', 0)
      this.ToolItem('任务', 1)
      this.ToolItem('专注', 2)
      this.ToolItem('背包', 3)
      this.ToolItem('猫猫', 4)
    }
    .width('100%')
    .height(62)
    .padding({ left: 6, right: 6, top: 4, bottom: 4 })
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#FFFFFC')
    .borderRadius(22)
    .shadow({ radius: 16, color: '#22FF9EAF', offsetX: 0, offsetY: -4 })
    .margin({ left: 10, right: 10, bottom: 20 })
  }

  @Builder
  ToolItem(label: string, index: number) {
    Stack() {
      Column({ space: 2 }) {
        Text(label)
          .fontSize(12)
          .fontWeight(this.activeTab === index ? FontWeight.Bold : FontWeight.Regular)
          .fontColor(this.activeTab === index ? '#FFFFFF' : '#9B7D76')
      }
      .height(50)
      .justifyContent(FlexAlign.Center)
      .padding({ left: 12, right: 12 })
      .backgroundColor(this.activeTab === index ? '#FF8F9F' : '#00000000')
      .borderRadius(16)
      .onClick(() => {
        if (this.onTabChange !== undefined) {
          this.onTabChange(index);
        }
      })
      if ((index === 1 && this.pendingCount > 0)) {
        Circle()
          .width(8)
          .height(8)
          .fill('#FF4757')
          .align(Alignment.TopEnd)
          .offset({ x: -2, y: 2 })
      }
    }
  }
}
