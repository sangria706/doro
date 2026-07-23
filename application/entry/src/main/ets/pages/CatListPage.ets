import { CatNPC, ALL_CATS, getAffectionLevel, getAffectionColor, getAffectionLevelEmoji, isCatAwake } from './CatNPCSystem';

@Component
export struct CatListPage {
  getAffection?: (catId: string) => number;
  onVisitCat?: (catId: string) => void;

  build() {
    Column({ space: 10 }) {
      Text('🐱 猫猫好友')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor('#5A403A')
        .width('100%')
        .padding({ left: 4, top: 8 })
      Text('小镇上有12只性格各异的猫咪在等你认识~')
        .fontSize(13)
        .fontColor('#9B7D76')
        .width('100%')
        .padding({ left: 4 })
      Scroll() {
        Column({ space: 8 }) {
          ForEach(ALL_CATS, (cat: CatNPC) => {
            Column() {
              Row({ space: 10 }) {
                Text(cat.emoji)
                  .fontSize(30)
                  .opacity(isCatAwake(cat) ? 1.0 : 0.5)
                Column({ space: 3 }) {
                  Row({ space: 6 }) {
                    Text(cat.name)
                      .fontSize(16)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(isCatAwake(cat) ? '#5A403A' : '#CBBFBC')
                    Text('#' + cat.personality)
                      .fontSize(11)
                      .fontColor('#FFFFFF')
                      .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                      .backgroundColor(isCatAwake(cat) ? '#BBA6E8' : '#DDBFBC')
                      .borderRadius(10)
                  }
                  Row({ space: 6 }) {
                    Text(getAffectionLevelEmoji(getAffectionLevel(this.getAffection !== undefined ? this.getAffection(cat.id) : 0)) + ' ' + getAffectionLevel(this.getAffection !== undefined ? this.getAffection(cat.id) : 0))
                      .fontSize(12)
                      .fontColor(getAffectionColor(this.getAffection !== undefined ? this.getAffection(cat.id) : 0))
                    Progress({ value: this.getAffection !== undefined ? this.getAffection(cat.id) : 0, total: 100, type: ProgressType.Linear })
                      .height(5)
                      .width(80)
                      .color(getAffectionColor(this.getAffection !== undefined ? this.getAffection(cat.id) : 0))
                      .backgroundColor('#F3DDE3')
                  }
                  if (!isCatAwake(cat)) {
                    Text('💤 睡觉中')
                      .fontSize(12)
                      .fontColor('#CBBFBC')
                  }
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
              }
              .width('100%')
              .padding(12)
            }
            .width('100%')
            .backgroundColor('#FFFFFC')
            .borderRadius(18)
            .opacity(isCatAwake(cat) ? 1.0 : 0.6)
            .onClick(() => {
              if (this.onVisitCat !== undefined) {
                this.onVisitCat(cat.id);
              }
            })
          }, (cat: CatNPC) => cat.id)
        }
        .width('100%')
        .padding({ bottom: 8 })
      }
      .layoutWeight(1)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .padding({ left: 14, right: 14, top: 4 })
  }
}
