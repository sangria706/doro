import { ChatMessage } from './AppState';
import { CatNPC, getAffectionLevel, getAffectionColor, getAffectionLevelEmoji, isCatAwake, getCatById, BENTO_LIST } from './CatNPCSystem';

@Component
export struct CatDetailPage {
  @Prop selectedCatEmoji: string = '';
  @Prop selectedCatName: string = '';
  @Prop selectedCatAwake: boolean = true;
  @Prop selectedCatPersonality: string = '';
  @Prop selectedCatAwakeTime: string = '';
  @Prop selectedCatSleepTime: string = '';
  @Prop selectedCatId: string = '';
  @Prop selectedCatLikedBento: string[] = [];
  @Prop catChatMessages: ChatMessage[] = [];
  @Prop catChatShowOptions: boolean = false;
  @Prop catChatDone: boolean = false;
  onClose?: () => void;
  onChatOption?: (optionIndex: number) => void;
  onOpenBentoPicker?: () => void;

  build() {
    Column() {
      if (this.selectedCatId.length > 0) {
        Column({ space: 0 }) {
          Row({ space: 8 }) {
            Button('←')
              .width(36)
              .height(36)
              .fontSize(16)
              .fontColor('#7D6862')
              .backgroundColor('#FFF4F7')
              .borderRadius(18)
              .onClick(() => {
                if (this.onClose !== undefined) {
                  this.onClose();
                }
              })
            Text(this.selectedCatEmoji)
              .fontSize(22)
            Text(this.selectedCatName)
              .fontSize(17)
              .fontWeight(FontWeight.Bold)
              .fontColor('#5A403A')
            Blank()
            Column()
              .width(36)
          }
          .width('100%')
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          .backgroundColor('#FFFFFC')

          if (!this.selectedCatAwake) {
            Column() {
              Blank()
              Text('💤 ' + this.selectedCatName + '正在睡觉')
                .fontSize(18)
                .fontColor('#CBBFBC')
              Text('活跃时间：' + this.selectedCatAwakeTime + ' · 睡觉时间：' + this.selectedCatSleepTime)
                .fontSize(14)
                .fontColor('#DDBFBC')
              Blank()
            }
            .width('100%')
            .layoutWeight(1)
          } else {
            Scroll() {
              Column({ space: 10 }) {
                ForEach(this.catChatMessages, (msg: ChatMessage, idx: number) => {
                  Row() {
                    if (msg.fromMe) {
                      Blank()
                    } else {
                      Text(this.selectedCatEmoji)
                        .fontSize(28)
                        .margin({ right: 6 })
                    }
                    Column({ space: 4 }) {
                      Text(msg.text)
                        .fontSize(15)
                        .fontColor(msg.fromMe ? '#FFFFFF' : '#5A403A')
                        .padding({ left: 14, right: 14, top: 10, bottom: 10 })
                        .backgroundColor(msg.fromMe ? '#FF8F9F' : '#FFFFFC')
                        .borderRadius(18)
                      Text(msg.time)
                        .fontSize(11)
                        .fontColor('#CBBFBC')
                    }
                    .alignItems(msg.fromMe ? HorizontalAlign.End : HorizontalAlign.Start)
                    .constraintSize({ maxWidth: '75%' })
                    if (!msg.fromMe) {
                      Blank()
                    }
                  }
                  .width('100%')
                  .justifyContent(msg.fromMe ? FlexAlign.End : FlexAlign.Start)
                  .padding({ left: 12, right: 12 })
                }, (msg: ChatMessage, idx: number) => 'catmsg-' + idx.toString())
                Blank()
                  .height(20)
              }
              .width('100%')
              .padding({ top: 12 })
            }
            .layoutWeight(1)
            .width('100%')

            if (this.catChatShowOptions) {
              Column({ space: 6 }) {
                ForEach(this.getResponseOptions(), (optText: string, idx: number) => {
                  Button(optText)
                    .width('100%')
                    .height(40)
                    .fontSize(13)
                    .fontColor('#FFFFFF')
                    .fontWeight(FontWeight.Bold)
                    .backgroundColor('#FF8F9F')
                    .borderRadius(20)
                    .onClick(() => {
                      if (this.onChatOption !== undefined) {
                        this.onChatOption(idx);
                      }
                    })
                }, (optText: string, idx: number) => 'opt-' + idx.toString())
              }
              .width('100%')
              .padding({ left: 14, right: 14, top: 8, bottom: 14 })
              .backgroundColor('#FFF4F7')
            }
          }

        }
        .width('100%')
        .height('100%')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFF4F7')
  }

  private getResponseOptions(): string[] {
    const personality: string = this.selectedCatPersonality;
    if (personality === '焦虑') {
      return ['别担心，有我呢！', '今天天气超好的~', '摸摸头冷静一下'];
    }
    if (personality === '优雅') {
      return ['你今天也好优雅~', '请多指教！', '一起喝杯茶吧'];
    }
    if (personality === '佛系') {
      return ['醒醒！太阳晒屁股了', '你继续睡吧~', '要不要吃点什么？'];
    }
    if (personality === '严肃') {
      return ['今天也很自律呢！', '我马上去写计划！', '不要太严格啦~'];
    }
    if (personality === '害羞') {
      return ['你好可爱呀！', '不要怕，我不会伤害你的', '慢慢来不着急'];
    }
    if (personality === '话痨') {
      return ['然后呢然后呢？', '哈哈哈好好笑', '你听我说！'];
    }
    if (personality === '迷糊') {
      return ['你又忘了什么呀？', '我帮你找找！', '小迷糊最可爱了'];
    }
    if (personality === '暴躁') {
      return ['你好凶哦…', '给你顺顺毛~', '要不要一起玩游戏？'];
    }
    if (personality === '文艺') {
      return ['好有意境的话呀', '我也喜欢~', '今天灵感怎么样？'];
    }
    if (personality === '贪吃') {
      return ['带好吃的了！', '你又胖了哈哈哈', '一起吃吧~'];
    }
    if (personality === '傲娇') {
      return ['你也很可爱啦！', '我才不是在夸你~', '今天特别好看哦'];
    }
    if (personality === '温柔') {
      return ['你太暖了！', '今天也辛苦了~', '抱抱！'];
    }
    return ['你好呀！', '今天怎么样？', '一起加油吧~'];
  }
}
