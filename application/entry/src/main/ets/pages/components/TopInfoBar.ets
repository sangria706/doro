@Component
export struct TopInfoBar {
  @Prop username: string = '';
  @Prop level: number = 1;
  @Prop expProgress: number = 0;
  @Prop coins: number = 0;
  @Prop gems: number = 0;
  @Prop claimableAchievementCount: number = 0;
  onAvatarClick?: () => void;
  onShopClick?: () => void;
  onAchievementClick?: () => void;
  onDashboardClick?: () => void;

  build() {
    Column() {
      Row() {
        Circle()
          .width(40)
          .height(40)
          .fill('#FFD9E2')
          .onClick(() => {
            if (this.onAvatarClick !== undefined) {
              this.onAvatarClick();
            }
          })
        Column({ space: 3 }) {
          Text(this.username.length > 0 ? this.username : '玩家')
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .fontColor('#5A403A')
          Row({ space: 6 }) {
            Text('Lv.' + this.level.toString())
              .fontSize(11)
              .fontColor('#FF7F95')
            Progress({ value: this.expProgress, total: 5, type: ProgressType.Linear })
              .height(5)
              .width(64)
              .color('#FF8F9F')
              .backgroundColor('#F3DDE3')
          }
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 8 })
        .layoutWeight(1)
        Row({ space: 8 }) {
          Text(this.coins.toString() + ' 叶')
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor('#8A5A4F')
            .padding({ left: 10, right: 10, top: 4, bottom: 4 })
            .backgroundColor('#FFF0C9')
            .borderRadius(14)
          Text(this.gems.toString() + ' 钻')
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor('#7C6FCB')
            .padding({ left: 10, right: 10, top: 4, bottom: 4 })
            .backgroundColor('#F3EFFF')
            .borderRadius(14)
        }
      }
      .width('100%')
      .padding({ top: 6, bottom: 6 })
      Row({ space: 6 }) {
        Text('看板')
          .fontSize(12)
          .fontColor('#FFFFFF')
          .padding({ left: 12, right: 12, top: 5, bottom: 5 })
          .backgroundColor('#FF8F9F')
          .borderRadius(14)
          .onClick(() => {
            if (this.onDashboardClick !== undefined) {
              this.onDashboardClick();
            }
          })
        this.IconBtn('设置')
        this.IconBtn('音效')
        this.IconBtn('更多')
        Blank()
          .layoutWeight(1)
        Stack() {
          Text('商城')
            .fontSize(12)
            .fontColor('#FFFFFF')
            .padding({ left: 12, right: 12, top: 5, bottom: 5 })
            .backgroundColor('#FF8F9F')
            .borderRadius(14)
        }
        .onClick(() => {
          if (this.onShopClick !== undefined) {
            this.onShopClick();
          }
        })
      }
      .width('100%')
    }
    .width('100%')
    .padding({ left: 14, right: 14, top: 8, bottom: 6 })
    .backgroundColor('#FFFFFC')
    .borderRadius({ topLeft: 0, topRight: 0, bottomLeft: 20, bottomRight: 20 })
    .shadow({ radius: 14, color: '#18FF9EAF', offsetX: 0, offsetY: 4 })
  }

  @Builder
  IconBtn(label: string) {
    Text(label)
      .fontSize(11)
      .fontColor('#9B7D76')
      .padding({ left: 10, right: 10, top: 5, bottom: 5 })
      .backgroundColor('#FFF4F7')
      .borderRadius(14)
  }
}
