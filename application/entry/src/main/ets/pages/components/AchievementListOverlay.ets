import { AchievementItem } from '../AppState';
import { AchievementClaimResult } from '../AchievementSystem';

@Component
export struct AchievementListOverlay {
  @Prop achievements: AchievementItem[] = [];
  onClaim?: (achievementId: string) => AchievementClaimResult | undefined;
  onClose?: () => void;
  @State showRewardPopup: boolean = false;
  @State showRewardOverlay: boolean = false;
  @State rewardGems: number = 0;
  @State rewardCoins: number = 0;
  @State rewardName: string = '';

  /** 仅 UI 排序：可领取 → 未解锁 → 已领取 */
  private sortedAchievements(): AchievementItem[] {
    const claimable: AchievementItem[] = [];
    const locked: AchievementItem[] = [];
    const claimed: AchievementItem[] = [];
    for (let i: number = 0; i < this.achievements.length; i++) {
      const item: AchievementItem = this.achievements[i];
      if (item.completed && !item.claimed) {
        claimable.push(item);
      } else if (!item.completed) {
        locked.push(item);
      } else {
        claimed.push(item);
      }
    }
    return claimable.concat(locked).concat(claimed);
  }

  private hasClaimable(): boolean {
    for (let i: number = 0; i < this.achievements.length; i++) {
      const item: AchievementItem = this.achievements[i];
      if (item.completed && !item.claimed) {
        return true;
      }
    }
    return false;
  }

  build() {
    Stack() {
      Column() {
        Column({ space: 14 }) {
          Row() {
            Text('我的成就')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#5A403A')
              .layoutWeight(1)
            Button('关闭')
              .height(36)
              .fontSize(12)
              .fontColor('#7D6862')
              .backgroundColor('#FFF4F7')
              .borderRadius(18)
              .onClick(() => {
                if (this.onClose !== undefined) {
                  this.onClose();
                }
              })
          }
          .width('100%')

          Scroll() {
            Column({ space: 12 }) {
              if (this.hasClaimable()) {
                Text('可领取')
                  .width('100%')
                  .fontSize(15)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FF4757')
              }
              ForEach(this.sortedAchievements(), (item: AchievementItem) => {
                this.AchievementRow(item)
              }, (item: AchievementItem) => item.id)
            }
            .width('100%')
          }
          .layoutWeight(1)
          .width('100%')
          .constraintSize({ maxHeight: 420 })
        }
        .width('88%')
        .height('78%')
        .padding(20)
        .backgroundColor('#FFFFFC')
        .borderRadius(24)
        .shadow({ radius: 30, color: '#33FF9EAF', offsetX: 0, offsetY: 10 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#AAFFEAF0')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)

      if (this.showRewardOverlay) {
        this.RewardOverlay()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  AchievementRow(item: AchievementItem) {
    Column({ space: 8 }) {
      Row() {
        Column({ space: 4 }) {
          Text(item.name)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#5A403A')
          Text(item.desc)
            .fontSize(13)
            .fontColor('#9B7D76')
            .lineHeight(18)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        Column({ space: 4 }) {
          Text('+' + item.rewardGems.toString() + ' 宝石')
            .fontSize(12)
            .fontColor('#7C6FCB')
          Text('+' + item.rewardCoins.toString() + ' 金币')
            .fontSize(12)
            .fontColor('#FF8F9F')
        }
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')

      if (item.completed && !item.claimed) {
        Button('领取')
          .width('100%')
          .height(40)
          .fontSize(14)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
          .backgroundColor('#FF8F9F')
          .borderRadius(20)
          .onClick(() => {
            if (this.onClaim !== undefined) {
              const result: AchievementClaimResult | undefined = this.onClaim(item.id);
              if (result !== undefined) {
                this.rewardName = item.name;
                this.rewardGems = result.rewardGems;
                this.rewardCoins = result.rewardCoins;
                this.showRewardOverlay = true;
              }
            }
          })
      } else if (item.claimed) {
        Button('已领取')
          .width('100%')
          .height(40)
          .enabled(false)
          .fontSize(14)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
          .backgroundColor('#B8ABA7')
          .borderRadius(20)
      } else {
        Button('未解锁')
          .width('100%')
          .height(40)
          .enabled(false)
          .fontSize(14)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
          .backgroundColor('#FF8F9F')
          .borderRadius(20)
      }
    }
    .width('100%')
    .padding(14)
    .backgroundColor('#FFF0F5')
    .borderRadius(18)
    // 未解锁：仅 opacity 0.7 弱化，不加灰色遮罩；已领取：仅按钮置灰，内容保持正常可读
    .opacity((!item.completed && !item.claimed) ? 0.7 : 1)
  }

  @Builder
  RewardOverlay() {
    Column() {
      Column({ space: 10 }) {
        Text('奖励文本预留位置')
          .fontSize(18)
          .fontColor('#5A403A')
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
        Text(this.rewardGems.toString() + ' 宝石  ·  ' + this.rewardCoins.toString() + ' 金币')
          .fontSize(14)
          .fontColor('#8D746D')
          .textAlign(TextAlign.Center)
      }
      .width('82%')
      .padding(20)
      .backgroundColor('#FFFFFC')
      .borderRadius(24)
      .shadow({ radius: 30, color: '#33FF9EAF', offsetX: 0, offsetY: 10 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#66000000')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      this.showRewardOverlay = false;
    })
  }
}
