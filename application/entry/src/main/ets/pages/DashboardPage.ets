import { DdlTask, AchievementItem } from './AppState';
import { AchievementClaimResult } from './AchievementSystem';

@Component
export struct DashboardPage {
  @Prop tasks: DdlTask[] = [];
  @Prop focusCount: number = 0;
  @Prop focusMinutesToday: number = 0;
  @Prop mood: number = 0;
  @Prop satiety: number = 0;
  @Prop coins: number = 0;
  @Prop comfort: number = 0;
  @Prop achievements: AchievementItem[] = [];
  @Prop currentLevel: number = 1;
  @Prop expProgress: number = 0;
  @State showRewardOverlay: boolean = false;
  @State rewardGems: number = 0;
  @State rewardCoins: number = 0;
  @State rewardName: string = '';
  onClaimAchievement?: (achievementId: string) => AchievementClaimResult | undefined;

  private totalDdlCount(): number {
    return this.tasks.length;
  }

  private doneDdlCount(): number {
    let count: number = 0;
    for (let i: number = 0; i < this.tasks.length; i++) {
      if (this.tasks[i].done) {
        count++;
      }
    }
    return count;
  }

  private ddlRate(): number {
    const total: number = this.totalDdlCount();
    if (total === 0) {
      return 0;
    }
    return Math.round(this.doneDdlCount() / total * 100);
  }

  private achUnlocked(): number {
    let count: number = 0;
    for (let i: number = 0; i < this.achievements.length; i++) {
      if (this.achievements[i].completed) {
        count++;
      }
    }
    return count;
  }

  private achTotal(): number {
    return this.achievements.length;
  }

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

  private onClaim(item: AchievementItem): void {
    if (this.onClaimAchievement !== undefined) {
      const result: AchievementClaimResult | undefined = this.onClaimAchievement(item.id);
      if (result !== undefined) {
        this.rewardName = item.name;
        this.rewardGems = result.rewardGems;
        this.rewardCoins = result.rewardCoins;
        this.showRewardOverlay = true;
      }
    }
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: 14 }) {
          this.BrandHeader('数据看板', '你的每一份努力都在这里')
          this.SectionTitle('📊 今日总览')
          Row({ space: 10 }) {
            this.StatCard('⏱', '专注', this.focusMinutesToday.toString() + 'min', '#FF8F9F')
            this.StatCard('💖', '心情', this.mood.toString(), '#F5A6C8')
          }
          Row({ space: 10 }) {
            this.StatCard('🍚', '饱腹', this.satiety.toString(), '#8BC8A5')
            this.StatCard('🪙', '金币', this.coins.toString(), '#FFC857')
          }
          this.SectionTitle('📋 DDL 统计')
          this.ProgressCard(
            '任务完成率',
            this.doneDdlCount().toString() + ' / ' + this.totalDdlCount().toString(),
            this.ddlRate(),
            '#FF8F9F'
          )
          Row({ space: 10 }) {
            this.LabelCard('📌 总计', this.totalDdlCount().toString() + ' 个', '#9B7D76')
            this.LabelCard('✅ 完成', this.doneDdlCount().toString() + ' 个', '#8BC8A5')
          }
          this.SectionTitle('🎯 成长轨迹')
          Row({ space: 10 }) {
            this.LabelCard('Lv.' + this.currentLevel.toString(), '当前等级', '#FF7F95')
            this.LabelCard(this.focusCount.toString() + ' 次', '累计专注', '#BBA6E8')
          }
          Column({ space: 6 }) {
            Text('下一级还需 ' + (5 - this.expProgress).toString() + ' 次专注')
              .fontSize(12)
              .fontColor('#9B7D76')
              .width('100%')
            Progress({ value: this.expProgress, total: 5, type: ProgressType.Linear })
              .height(10)
              .width('100%')
              .color('#FF8F9F')
              .backgroundColor('#F3DDE3')
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFC')
          .borderRadius(20)

          this.SectionTitle('🏆 成就')
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
        .padding({ left: 16, right: 16, bottom: 24 })
      }
      .width('100%')
      .height('100%')

      if (this.showRewardOverlay) {
        Column() {
          Column({ space: 10 }) {
            Text(this.rewardName + ' 奖励')
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
  SectionTitle(title: string) {
    Text(title)
      .width('100%')
      .fontSize(18)
      .fontWeight(FontWeight.Bold)
      .fontColor('#5A403A')
  }

  @Builder
  StatCard(icon: string, label: string, value: string, color: string) {
    Column({ space: 8 }) {
      Text(icon)
        .fontSize(26)
      Text(value)
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
      Text(label)
        .fontSize(12)
        .fontColor('#9B7D76')
    }
    .alignItems(HorizontalAlign.Center)
    .layoutWeight(1)
    .padding(14)
    .backgroundColor('#FFFFFC')
    .borderRadius(20)
  }

  @Builder
  ProgressCard(title: string, subtitle: string, progress: number, color: string) {
    Column({ space: 8 }) {
      Row() {
        Text(title + ' ' + subtitle)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#5A403A')
      }
      .width('100%')
      Progress({ value: progress, total: 100, type: ProgressType.Linear })
        .height(12)
        .width('100%')
        .color(color)
        .backgroundColor('#F3DDE3')
      Text(progress.toString() + '%')
        .fontSize(12)
        .fontColor(color)
        .width('100%')
        .textAlign(TextAlign.End)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFC')
    .borderRadius(20)
  }

  @Builder
  LabelCard(label: string, desc: string, color: string) {
    Column({ space: 4 }) {
      Text(label)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
      Text(desc)
        .fontSize(12)
        .fontColor('#9B7D76')
    }
    .alignItems(HorizontalAlign.Center)
    .layoutWeight(1)
    .padding(14)
    .backgroundColor('#FFFFFC')
    .borderRadius(20)
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
            this.onClaim(item);
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
    .opacity((!item.completed && !item.claimed) ? 0.7 : 1)
  }
}
