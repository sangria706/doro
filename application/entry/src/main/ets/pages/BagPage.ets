import { InventoryItem } from './AppState';

@Component
export struct BagPage {
  @Prop bagTab: number = 0;
  @Prop outfits: InventoryItem[] = [];
  @Prop foods: InventoryItem[] = [];
  @Prop furnitures: InventoryItem[] = [];
  onTabChange?: (index: number) => void;
  onUseFood?: (index: number) => void;

  build() {
    Column({ space: 12 }) {
      this.BrandHeader('背包', '装扮、食物与家具')
      Row({ space: 8 }) {
        this.BagTab('装扮', 0)
        this.BagTab('食物', 1)
        this.BagTab('家具', 2)
      }
      .padding({ left: 16, right: 16 })
      Scroll() {
        Column({ space: 12 }) {
          if (this.bagTab === 0) {
            this.InventoryList(this.outfits, false)
          } else if (this.bagTab === 1) {
            this.InventoryList(this.foods, true)
          } else {
            this.InventoryList(this.furnitures, false)
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
  BagTab(label: string, index: number) {
    Button(label)
      .layoutWeight(1)
      .height(38)
      .fontSize(12)
      .fontColor(this.bagTab === index ? '#FFFFFF' : '#7D6862')
      .backgroundColor(this.bagTab === index ? '#FF8F9F' : '#FFFFFC')
      .borderRadius(19)
      .onClick(() => {
        if (this.onTabChange !== undefined) {
          this.onTabChange(index);
        }
      })
  }

  @Builder
  InventoryList(items: InventoryItem[], canUse: boolean) {
    ForEach(items, (item: InventoryItem, index: number) => {
      Row() {
        Column({ space: 6 }) {
          Text(item.name)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#5A403A')
          Text(item.desc)
            .fontSize(13)
            .fontColor('#9B7D76')
            .lineHeight(20)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        if (canUse) {
          Button(`用 x${item.count}`)
            .width(78)
            .height(34)
            .fontSize(12)
            .fontColor('#FFFFFF')
            .backgroundColor(item.count > 0 ? '#FF8F9F' : '#CBBFBC')
            .borderRadius(17)
            .onClick(() => {
              if (this.onUseFood !== undefined) {
                this.onUseFood(index);
              }
            })
        } else {
          Text(`x${item.count}`)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(item.count > 0 ? '#FF7F95' : '#CBBFBC')
        }
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFC')
      .borderRadius(22)
    }, (item: InventoryItem) => item.name)
  }
}
