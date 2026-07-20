class DdlTask {
  id: number = 0;
  title: string = '';
  deadline: string = '';
  difficulty: string = '';
  progress: number = 0;
  done: boolean = false;

  constructor(id: number, title: string, deadline: string, difficulty: string, progress: number, done: boolean) {
    this.id = id;
    this.title = title;
    this.deadline = deadline;
    this.difficulty = difficulty;
    this.progress = progress;
    this.done = done;
  }
}

class InventoryItem {
  name: string = '';
  desc: string = '';
  count: number = 0;

  constructor(name: string, desc: string, count: number) {
    this.name = name;
    this.desc = desc;
    this.count = count;
  }
}

const DAY_MS: number = 24 * 60 * 60 * 1000;

@Entry
@Component
struct Index {
  @State activeTab: number = 0;
  @State ddlStep: number = 0;
  @State townMode: number = 0;
  @State bagTab: number = 0;
  @State focusRunning: boolean = false;
  @State selectedTaskId: number = 1;
  @State newTitle: string = '';
  @State newDeadline: string = '2026-07-21 14:00';
  @State newDifficulty: string = '困难';
  @State mood: number = 76;
  @State satiety: number = 68;
  @State coins: number = 328;
  @State comfort: number = 13;
  @State focusMinutesToday: number = 75;
  @State focusCount: number = 3;
  @State doroWords: string = '今天天气真好，一起加油吧！';
  @State tasks: DdlTask[] = [
    new DdlTask(1, '提交项目方案', '2026-07-21 14:00', '困难', 80, false),
    new DdlTask(2, '回教授邮件', '2026-07-19 18:00', '简单', 30, false),
    new DdlTask(3, '复习期末重点', '2026-07-18 20:00', '普通', 65, false),
    new DdlTask(4, '整理第一份 DDL', '2026-07-17 16:30', '简单', 100, true)
  ];
  @State foods: InventoryItem[] = [
    new InventoryItem('普通便当', '免费，适合送给好友的日常关心', 1),
    new InventoryItem('热牛奶', '饱腹度 +12，Doro 会露出安心表情', 2),
    new InventoryItem('草莓软糖', '心情值 +8，适合逾期后安抚', 3)
  ];
  @State outfits: InventoryItem[] = [
    new InventoryItem('小围巾', '相遇纪念装扮', 1),
    new InventoryItem('专注之星碎片', '集齐 4 片可兑换头饰', 2),
    new InventoryItem('铃铛发带', '重逢剧情纪念物', 0)
  ];
  @State furnitures: InventoryItem[] = [
    new InventoryItem('软垫沙发', '舒适度 +4', 1),
    new InventoryItem('绿植角落', '舒适度 +3', 1),
    new InventoryItem('暖光小灯', '舒适度 +5', 0)
  ];

  private clamp(value: number): number {
    if (value < 0) {
      return 0;
    }
    if (value > 100) {
      return 100;
    }
    return value;
  }

  private pendingCount(): number {
    return this.tasks.filter((task: DdlTask) => !task.done && !this.isOverdue(task)).length;
  }

  private doneCount(): number {
    return this.tasks.filter((task: DdlTask) => task.done).length;
  }

  private overdueCount(): number {
    return this.tasks.filter((task: DdlTask) => !task.done && this.isOverdue(task)).length;
  }

  private isOverdue(task: DdlTask): boolean {
    return new Date(this.normalizeDeadline(task.deadline)).getTime() < new Date().getTime();
  }

  private normalizeDeadline(value: string): string {
    return value.replace(' ', 'T');
  }

  private dateText(deadline: string): string {
    const target: Date = new Date(this.normalizeDeadline(deadline));
    const now: Date = new Date();
    const targetDay: Date = new Date(target.getFullYear(), target.getMonth(), target.getDate());
    const nowDay: Date = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const left: number = Math.ceil((targetDay.getTime() - nowDay.getTime()) / DAY_MS);
    const timeText: string = `${this.pad(target.getHours())}:${this.pad(target.getMinutes())}`;
    if (left < 0) {
      return `已逾期 ${Math.abs(left)} 天 ${timeText}`;
    }
    if (left === 0) {
      return `今天 ${timeText}`;
    }
    if (left === 1) {
      return `明天 ${timeText}`;
    }
    return `${target.getMonth() + 1}月${target.getDate()}日 ${timeText}`;
  }

  private pad(value: number): string {
    return value < 10 ? `0${value}` : `${value}`;
  }

  private difficultyColor(difficulty: string): string {
    if (difficulty === '简单') {
      return '#2D8C66';
    }
    if (difficulty === '普通') {
      return '#5078C8';
    }
    if (difficulty === '困难') {
      return '#D26A5B';
    }
    return '#8D5AB8';
  }

  private doroReaction(difficulty: string): string {
    if (difficulty === '简单') {
      return 'Doro 轻松微笑：这个我们稳稳拿下。';
    }
    if (difficulty === '普通') {
      return 'Doro 点点头：拆成小块就不怕。';
    }
    if (difficulty === '困难') {
      return 'Doro 擦汗：这个有点难哦，我陪你。';
    }
    return 'Doro 睁大眼睛：史诗任务！要签很认真的约定。';
  }

  private selectedTaskTitle(): string {
    const selected: DdlTask[] = this.tasks.filter((task: DdlTask) => task.id === this.selectedTaskId);
    if (selected.length === 0) {
      return '选择一个 DDL';
    }
    return selected[0].title;
  }

  private addTask(): void {
    const title: string = this.newTitle.trim();
    if (title.length === 0) {
      this.doroWords = '契约要先写下名字哦。';
      this.ddlStep = 0;
      return;
    }
    if (!/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}$/.test(this.newDeadline)) {
      this.doroWords = '日期格式写成 2026-07-21 14:00。';
      this.ddlStep = 1;
      return;
    }
    const task: DdlTask = new DdlTask(
      Date.now(),
      title,
      this.newDeadline,
      this.newDifficulty,
      0,
      false
    );
    this.tasks = [task, ...this.tasks];
    this.selectedTaskId = task.id;
    this.newTitle = '';
    this.ddlStep = 0;
    this.coins += 3;
    this.doroWords = '契约成立！Doro 盖上了小爪印。';
  }

  private finishTask(taskId: number): void {
    let reward: number = 0;
    let late: boolean = false;
    this.tasks = this.tasks.map((task: DdlTask) => {
      if (task.id === taskId && !task.done) {
        late = this.isOverdue(task);
        reward = late ? 6 : 18;
        return new DdlTask(task.id, task.title, task.deadline, task.difficulty, 100, true);
      }
      return task;
    });
    if (reward > 0) {
      this.coins += reward;
      this.mood = this.clamp(this.mood + (late ? 2 : 8));
      this.satiety = this.clamp(this.satiety - 2);
      this.doroWords = late ? '虽然晚了一点，Doro 还是松了一口气。' : '提前完成！Doro 开心得转了一圈。';
    }
  }

  private touchDoro(): void {
    this.mood = this.clamp(this.mood + 1);
    const words: string[] = [
      '嘿嘿，被你发现我在等你。',
      '摸摸头成功，今日心情 +1。',
      'Doro 跳了一下，然后认真坐好。',
      '一起把最难的那件事拆小一点吧。'
    ];
    this.doroWords = words[Math.floor(Math.random() * words.length)];
  }

  private feedDoro(): void {
    if (this.coins < 8) {
      this.doroWords = 'Doro币不够啦，先完成一个 DDL 吧。';
      return;
    }
    this.coins -= 8;
    this.satiety = this.clamp(this.satiety + 14);
    this.mood = this.clamp(this.mood + 4);
    this.doroWords = 'Doro 抱着碗晃了晃，好像很满足。';
  }

  private dressDoro(): void {
    this.doroWords = 'Doro 试戴了小围巾，站在镜子前转了一圈。';
  }

  private startFocus(): void {
    this.focusRunning = !this.focusRunning;
    this.doroWords = this.focusRunning ? 'Doro 安静坐在旁边看书。' : 'Doro 伸了个懒腰，等你继续。';
  }

  private completeFocus(): void {
    this.focusRunning = false;
    this.focusMinutesToday += 25;
    this.focusCount += 1;
    this.coins += 5;
    this.mood = this.clamp(this.mood + 2);
    if (this.focusCount % 4 === 0) {
      this.outfits = this.outfits.map((item: InventoryItem) => {
        if (item.name === '专注之星碎片') {
          return new InventoryItem(item.name, item.desc, item.count + 1);
        }
        return item;
      });
      this.doroWords = '四个番茄钟完成！Doro 送来一片专注之星。';
      return;
    }
    this.doroWords = '25 分钟完成，Doro 给你递来小纸条。';
  }

  private leaveBento(): void {
    if (this.foods[0].count <= 0) {
      this.doroWords = '今天的普通便当已经送出去了。';
      return;
    }
    this.foods = this.foods.map((item: InventoryItem, index: number) => {
      if (index === 0) {
        return new InventoryItem(item.name, item.desc, item.count - 1);
      }
      return item;
    });
    this.doroWords = '便当旁边留下了你家 Doro 的小爪印。';
  }

  @Builder
  TopStatus() {
    Row({ space: 10 }) {
      this.MiniMeter('心情', this.mood, '#DB6A5A')
      this.MiniMeter('饱腹', this.satiety, '#2D8C66')
      Text(`${this.coins} 币`)
        .height(34)
        .fontSize(13)
        .fontWeight(FontWeight.Bold)
        .fontColor('#7B5521')
        .padding({ left: 12, right: 12 })
        .backgroundColor('#FFF1CF')
        .borderRadius(17)
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
          .fontColor('#52605B')
        Text(`${value}`)
          .fontSize(11)
          .fontWeight(FontWeight.Bold)
          .fontColor(color)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Progress({ value, total: 100, type: ProgressType.Linear })
        .height(6)
        .width('100%')
        .color(color)
        .backgroundColor('#E9E4DA')
    }
    .height(34)
    .layoutWeight(1)
    .padding({ left: 10, right: 10, top: 5, bottom: 5 })
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
  }

  @Builder
  DoroScene(mode: string) {
    Stack({ alignContent: Alignment.Center }) {
      Column() {
        Row() {
          Text('🛋️')
            .fontSize(28)
          Blank()
          Text('🪴')
            .fontSize(30)
          Blank()
          Text('🖼️')
            .fontSize(28)
        }
        .width('78%')
        .margin({ bottom: 16 })

        Stack({ alignContent: Alignment.Center }) {
          Circle()
            .width(mode === 'focus' ? 130 : 164)
            .height(mode === 'focus' ? 130 : 164)
            .fill('#F8D7D1')
          Circle()
            .width(mode === 'focus' ? 96 : 122)
            .height(mode === 'focus' ? 96 : 122)
            .fill('#FFF7F1')
          Column({ space: 4 }) {
            Text('Doro')
              .fontSize(mode === 'focus' ? 24 : 30)
              .fontWeight(FontWeight.Bold)
              .fontColor('#BA6D64')
            Text(mode === 'focus' ? '安静陪伴中' : '图片占位')
              .fontSize(12)
              .fontColor('#B8867D')
          }
        }
        .onClick(() => this.touchDoro())
      }
    }
    .height(mode === 'home' ? 350 : 250)
    .width('100%')
    .backgroundColor('#F5E5D9')
    .borderRadius(8)
  }

  @Builder
  HomePage() {
    Column() {
      this.TopStatus()

      Scroll() {
        Column({ space: 14 }) {
          this.DoroScene('home')

          Row({ space: 10 }) {
            Button('喂食')
              .layoutWeight(1)
              .height(42)
              .fontColor('#FFFFFF')
              .backgroundColor('#D26A5B')
              .borderRadius(8)
              .onClick(() => this.feedDoro())
            Button('抚摸')
              .layoutWeight(1)
              .height(42)
              .fontColor('#FFFFFF')
              .backgroundColor('#2F6F62')
              .borderRadius(8)
              .onClick(() => this.touchDoro())
            Button('装扮')
              .layoutWeight(1)
              .height(42)
              .fontColor('#FFFFFF')
              .backgroundColor('#5078C8')
              .borderRadius(8)
              .onClick(() => this.dressDoro())
          }

          Column({ space: 8 }) {
            Text('Doro说')
              .fontSize(12)
              .fontColor('#687076')
            Text(`“${this.doroWords}”`)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#20302A')
              .lineHeight(26)
          }
          .alignItems(HorizontalAlign.Start)
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(8)

          Row({ space: 10 }) {
            this.HomeStat('家园舒适度', `${this.comfort} 星`, '#8D5AB8')
            this.HomeStat('逾期记录', `${this.overdueCount()} 次`, '#C84D4D')
          }
          .width('100%')
        }
        .padding({ left: 16, right: 16, bottom: 24 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  HomeStat(label: string, value: string, color: string) {
    Column({ space: 6 }) {
      Text(label)
        .fontSize(12)
        .fontColor('#687076')
      Text(value)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
    }
    .alignItems(HorizontalAlign.Start)
    .layoutWeight(1)
    .padding(14)
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
  }

  @Builder
  DdlPage() {
    Scroll() {
      Column({ space: 14 }) {
        this.ContractCreator()
        this.TaskSection('进行中', false, false)
        this.TaskSection('已完成', true, false)
        this.TaskSection('已逾期', false, true)
      }
      .padding({ left: 16, right: 16, top: 16, bottom: 24 })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  ContractCreator() {
    Column({ space: 12 }) {
      Row() {
        Text('+ 新建DDL')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#20302A')
        Blank()
        Text(`步骤 ${this.ddlStep + 1}/4`)
          .fontSize(12)
          .fontColor('#687076')
      }
      .width('100%')

      if (this.ddlStep === 0) {
        TextInput({ placeholder: '请输入DDL内容...', text: this.newTitle })
          .height(44)
          .backgroundColor('#F4F7F4')
          .borderRadius(8)
          .onChange((value: string) => {
            this.newTitle = value;
          })
      } else if (this.ddlStep === 1) {
        TextInput({ placeholder: '2026-07-21 14:00', text: this.newDeadline })
          .height(44)
          .backgroundColor('#F4F7F4')
          .borderRadius(8)
          .onChange((value: string) => {
            this.newDeadline = value;
          })
      } else if (this.ddlStep === 2) {
        Column({ space: 10 }) {
          Row({ space: 8 }) {
            this.DifficultyChip('简单')
            this.DifficultyChip('普通')
            this.DifficultyChip('困难')
            this.DifficultyChip('史诗')
          }
          Text(this.doroReaction(this.newDifficulty))
            .fontSize(14)
            .fontColor('#5F6D68')
            .lineHeight(21)
        }
      } else {
        Column({ space: 8 }) {
          Text('📜 契约成立！')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#7B5521')
          Text(`你承诺在 ${this.newDeadline} 前完成“${this.newTitle.length > 0 ? this.newTitle : '未命名DDL'}”。`)
            .fontSize(14)
            .fontColor('#4E5963')
            .lineHeight(22)
          Text('Doro 伸出小爪子，盖了个爪印。')
            .fontSize(14)
            .fontColor('#BA6D64')
        }
        .width('100%')
        .padding(14)
        .backgroundColor('#FFF7E6')
        .borderRadius(8)
      }

      Row({ space: 10 }) {
        Button('上一步')
          .layoutWeight(1)
          .height(38)
          .enabled(this.ddlStep > 0)
          .fontColor('#53645D')
          .backgroundColor('#EDF2EF')
          .borderRadius(8)
          .onClick(() => {
            if (this.ddlStep > 0) {
              this.ddlStep -= 1;
            }
          })
        Button(this.ddlStep === 3 ? '我承诺' : '下一步')
          .layoutWeight(1)
          .height(38)
          .fontColor('#FFFFFF')
          .backgroundColor('#2F6F62')
          .borderRadius(8)
          .onClick(() => {
            if (this.ddlStep === 3) {
              this.addTask();
            } else {
              this.ddlStep += 1;
            }
          })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
  }

  @Builder
  DifficultyChip(label: string) {
    Button(label)
      .layoutWeight(1)
      .height(36)
      .fontSize(12)
      .fontColor(this.newDifficulty === label ? '#FFFFFF' : '#53645D')
      .backgroundColor(this.newDifficulty === label ? this.difficultyColor(label) : '#EDF2EF')
      .borderRadius(8)
      .onClick(() => {
        this.newDifficulty = label;
      })
  }

  @Builder
  TaskSection(title: string, done: boolean, overdueOnly: boolean) {
    Column({ space: 10 }) {
      Text(`${title} (${this.sectionCount(done, overdueOnly)})`)
        .width('100%')
        .fontSize(17)
        .fontWeight(FontWeight.Bold)
        .fontColor(overdueOnly ? '#C84D4D' : '#20302A')
      ForEach(this.filteredTasks(done, overdueOnly), (task: DdlTask) => {
        this.TaskCard(task)
      }, (task: DdlTask) => `${task.id}-${title}`)
    }
    .width('100%')
  }

  private filteredTasks(done: boolean, overdueOnly: boolean): DdlTask[] {
    return this.tasks.filter((task: DdlTask) => this.shouldShowTask(task, done, overdueOnly));
  }

  private shouldShowTask(task: DdlTask, done: boolean, overdueOnly: boolean): boolean {
    if (overdueOnly) {
      return !task.done && this.isOverdue(task);
    }
    if (done) {
      return task.done;
    }
    return !task.done && !this.isOverdue(task);
  }

  private sectionCount(done: boolean, overdueOnly: boolean): number {
    return this.tasks.filter((task: DdlTask) => this.shouldShowTask(task, done, overdueOnly)).length;
  }

  @Builder
  TaskCard(task: DdlTask) {
    Column({ space: 10 }) {
      Row() {
        Text(`📝 ${task.title}`)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(task.done ? '#8A9691' : '#20302A')
          .maxLines(2)
          .layoutWeight(1)
        Text(task.difficulty)
          .fontSize(12)
          .fontColor('#FFFFFF')
          .padding({ left: 9, right: 9, top: 4, bottom: 4 })
          .backgroundColor(this.difficultyColor(task.difficulty))
          .borderRadius(12)
      }
      .width('100%')

      Text(`⏰ ${this.dateText(task.deadline)}`)
        .fontSize(13)
        .fontColor(this.isOverdue(task) && !task.done ? '#C84D4D' : '#687076')
        .width('100%')

      Progress({ value: task.progress, total: 100, type: ProgressType.Linear })
        .height(8)
        .width('100%')
        .color(this.difficultyColor(task.difficulty))
        .backgroundColor('#E9EDF0')

      Row() {
        Text(task.done ? 'Doro 保存了这段回忆' : 'Doro在旁边打气')
          .fontSize(13)
          .fontColor('#69746F')
        Blank()
        if (!task.done) {
          Button('标记完成')
            .height(34)
            .fontSize(12)
            .fontColor('#FFFFFF')
            .backgroundColor('#2F6F62')
            .borderRadius(8)
            .onClick(() => this.finishTask(task.id))
        }
      }
      .width('100%')
    }
    .width('100%')
    .padding(14)
    .backgroundColor(task.done ? '#F2F4F3' : '#FFFFFF')
    .borderRadius(8)
    .border({ width: 1, color: this.isOverdue(task) && !task.done ? '#F1B8B8' : '#E9E2D6' })
  }

  @Builder
  FocusPage() {
    Scroll() {
      Column({ space: 16 }) {
        Text('专注')
          .width('100%')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#20302A')

        Column({ space: 8 }) {
          Text('选择一个DDL关联')
            .width('100%')
            .fontSize(13)
            .fontColor('#687076')
          Button(this.selectedTaskTitle())
            .width('100%')
            .height(42)
            .fontColor('#20302A')
            .backgroundColor('#FFFFFF')
            .borderRadius(8)
            .onClick(() => {
              const pending: DdlTask[] = this.tasks.filter((task: DdlTask) => !task.done);
              if (pending.length > 0) {
                const currentIndex: number = pending.findIndex((task: DdlTask) => task.id === this.selectedTaskId);
                const nextIndex: number = currentIndex < 0 || currentIndex === pending.length - 1 ? 0 : currentIndex + 1;
                this.selectedTaskId = pending[nextIndex].id;
              }
            })
        }
        .width('100%')

        Text(this.focusRunning ? '25:00' : '25:00')
          .width('100%')
          .height(112)
          .textAlign(TextAlign.Center)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2F6F62')
          .backgroundColor('#FFFFFF')
          .borderRadius(8)

        this.DoroScene('focus')

        Row({ space: 10 }) {
          Button(this.focusRunning ? '暂停专注' : '开始专注')
            .layoutWeight(1)
            .height(44)
            .fontColor('#FFFFFF')
            .backgroundColor('#2F6F62')
            .borderRadius(8)
            .onClick(() => this.startFocus())
          Button('完成25分钟')
            .layoutWeight(1)
            .height(44)
            .fontColor('#FFFFFF')
            .backgroundColor('#D26A5B')
            .borderRadius(8)
            .onClick(() => this.completeFocus())
        }

        Text(`今日累计：${this.focusMinutesToday}分钟 · 已完成番茄钟 ${this.focusCount} 个`)
          .fontSize(14)
          .fontColor('#687076')
          .width('100%')
          .textAlign(TextAlign.Center)
      }
      .padding(16)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  TownPage() {
    Scroll() {
      Column({ space: 14 }) {
        if (this.townMode === 0) {
          this.TownMap()
        } else if (this.townMode === 1) {
          this.TownSquare()
        } else {
          this.FriendHome()
        }
      }
      .padding({ left: 16, right: 16, top: 16, bottom: 24 })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  TownMap() {
    Column({ space: 14 }) {
      Row() {
        Text('Doro小镇')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#20302A')
        Blank()
        Text('☁️ ☁️ ☀️')
          .fontSize(20)
      }
      .width('100%')

      Stack({ alignContent: Alignment.Center }) {
        Column({ space: 12 }) {
          Row() {
            this.HouseButton('小蓝', 2)
            Blank()
            this.HouseButton('阿禾', 2)
            Blank()
            this.HouseButton('栗子', 2)
          }
          .width('88%')

          Text('🌳  广场  🌳')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#2F6F62')
            .padding(18)
            .backgroundColor('#FFFFFF')
            .borderRadius(8)
            .onClick(() => {
              this.townMode = 1;
            })

          Row() {
            this.HouseButton('沐沐', 2)
            Blank()
            this.HouseButton('我的家', 0)
            Blank()
            this.HouseButton('小北', 2)
          }
          .width('88%')
        }
      }
      .height(330)
      .width('100%')
      .backgroundColor('#DDEEDB')
      .borderRadius(8)

      Column({ space: 7 }) {
        Text('广场公告板')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#20302A')
        Text('“期末月boss战进行中！全镇累计完成 186 个 DDL，下一档奖励还差 14 个。”')
          .fontSize(14)
          .fontColor('#5F6D68')
          .lineHeight(22)
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')
      .padding(14)
      .backgroundColor('#FFFFFF')
      .borderRadius(8)

      Row({ space: 10 }) {
        this.TownJump('去广场', 1)
        this.TownJump('去商店', 0)
      }
      Row({ space: 10 }) {
        this.TownJump('我的家', 0)
        this.TownJump('好友列表', 2)
      }
    }
    .width('100%')
  }

  @Builder
  HouseButton(name: string, mode: number) {
    Column({ space: 4 }) {
      Text('🏠')
        .fontSize(34)
      Text(name)
        .fontSize(11)
        .fontColor('#52605B')
    }
    .onClick(() => {
      this.townMode = mode;
    })
  }

  @Builder
  TownJump(label: string, mode: number) {
    Button(label)
      .layoutWeight(1)
      .height(42)
      .fontColor('#FFFFFF')
      .backgroundColor(mode === 1 ? '#2F6F62' : '#5078C8')
      .borderRadius(8)
      .onClick(() => {
        this.townMode = mode;
      })
  }

  @Builder
  TownSquare() {
    Column({ space: 14 }) {
      Row() {
        Button('返回')
          .width(72)
          .height(34)
          .fontSize(12)
          .fontColor('#53645D')
          .backgroundColor('#EDF2EF')
          .borderRadius(8)
          .onClick(() => {
            this.townMode = 0;
          })
        Text('小镇广场')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#20302A')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Blank()
          .width(72)
      }
      .width('100%')

      Column({ space: 12 }) {
        Text('在线Doro剪影')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#20302A')
        Row({ space: 12 }) {
          this.DoroShadow('看书')
          this.DoroShadow('打盹')
          this.DoroShadow('递纸条')
        }
        Row({ space: 12 }) {
          this.DoroShadow('转圈')
          this.DoroShadow('浇花')
          this.DoroShadow('发呆')
        }
      }
      .width('100%')
      .padding(14)
      .backgroundColor('#FFFFFF')
      .borderRadius(8)

      Column({ space: 8 }) {
        Text('礼物树')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#20302A')
        Text('每天可以摘一个小礼物送给好友，不显示排行榜，也不会制造访问压力。')
          .fontSize(14)
          .fontColor('#5F6D68')
          .lineHeight(22)
        Button('摘一个随机礼物')
          .width('100%')
          .height(42)
          .fontColor('#FFFFFF')
          .backgroundColor('#D26A5B')
          .borderRadius(8)
          .onClick(() => {
            this.coins += 2;
            this.doroWords = '礼物树掉下了一枚小星星。';
          })
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')
      .padding(14)
      .backgroundColor('#FFF7E6')
      .borderRadius(8)
    }
  }

  @Builder
  DoroShadow(action: string) {
    Column({ space: 6 }) {
      Circle()
        .width(54)
        .height(54)
        .fill('#B8C7BD')
      Text(action)
        .fontSize(12)
        .fontColor('#53645D')
    }
    .layoutWeight(1)
    .padding(10)
    .backgroundColor('#F4F7F4')
    .borderRadius(8)
  }

  @Builder
  FriendHome() {
    Column({ space: 14 }) {
      Row() {
        Button('返回')
          .width(72)
          .height(34)
          .fontSize(12)
          .fontColor('#53645D')
          .backgroundColor('#EDF2EF')
          .borderRadius(8)
          .onClick(() => {
            this.townMode = 0;
          })
        Text('小蓝的家')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#20302A')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Text('···')
          .width(72)
          .fontSize(22)
          .fontColor('#687076')
          .textAlign(TextAlign.End)
      }
      .width('100%')

      Stack({ alignContent: Alignment.Center }) {
        Column({ space: 10 }) {
          Text('小蓝的Doro')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#4C669B')
          Text('正在睡觉')
            .fontSize(14)
            .fontColor('#687076')
          Text('🛏️  📚  🧸')
            .fontSize(30)
        }
      }
      .height(280)
      .width('100%')
      .backgroundColor('#E8ECF6')
      .borderRadius(8)

      Row({ space: 10 }) {
        Button('留便当')
          .layoutWeight(1)
          .height(42)
          .fontColor('#FFFFFF')
          .backgroundColor('#D26A5B')
          .borderRadius(8)
          .onClick(() => this.leaveBento())
        Button('留言')
          .layoutWeight(1)
          .height(42)
          .fontColor('#FFFFFF')
          .backgroundColor('#5078C8')
          .borderRadius(8)
          .onClick(() => {
            this.doroWords = '留言贴纸已贴上：今天也要开心。';
          })
      }

      Text('你的Doro说：“他家好漂亮，我们也把小灯摆出来吧。”')
        .fontSize(15)
        .fontColor('#20302A')
        .lineHeight(23)
        .padding(14)
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
    }
  }

  @Builder
  BagPage() {
    Column({ space: 12 }) {
      Text('背包')
        .width('100%')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#20302A')
        .padding({ left: 16, right: 16, top: 16 })

      Row({ space: 8 }) {
        this.BagTab('装扮', 0)
        this.BagTab('食物', 1)
        this.BagTab('家具', 2)
        this.BagTab('回忆录', 3)
      }
      .padding({ left: 16, right: 16 })

      Scroll() {
        Column({ space: 12 }) {
          if (this.bagTab === 0) {
            this.InventoryList(this.outfits)
          } else if (this.bagTab === 1) {
            this.InventoryList(this.foods)
          } else if (this.bagTab === 2) {
            this.InventoryList(this.furnitures)
          } else {
            this.Memoirs()
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
  BagTab(label: string, index: number) {
    Button(label)
      .layoutWeight(1)
      .height(36)
      .fontSize(12)
      .fontColor(this.bagTab === index ? '#FFFFFF' : '#53645D')
      .backgroundColor(this.bagTab === index ? '#2F6F62' : '#FFFFFF')
      .borderRadius(8)
      .onClick(() => {
        this.bagTab = index;
      })
  }

  @Builder
  InventoryList(items: InventoryItem[]) {
    ForEach(items, (item: InventoryItem) => {
      Row() {
        Column({ space: 6 }) {
          Text(item.name)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#20302A')
          Text(item.desc)
            .fontSize(13)
            .fontColor('#687076')
            .lineHeight(20)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        Text(`x${item.count}`)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(item.count > 0 ? '#2F6F62' : '#A8B0AD')
      }
      .width('100%')
      .padding(14)
      .backgroundColor('#FFFFFF')
      .borderRadius(8)
    }, (item: InventoryItem) => item.name)
  }

  @Builder
  Memoirs() {
    Column({ space: 12 }) {
      this.MemoryNode('相遇之日', 'Doro 破壳而出，认真记住了你的名字。', true)
      this.MemoryNode('第一次提前完成', 'Doro 开心得翻了一圈，送你 18 枚 Doro币。', true)
      this.MemoryNode('第一次逾期', 'Doro 有点难过，但还是选择原谅。', false)
      this.MemoryNode('连续完成10个DDL', '还差 6 个节点解锁小奖牌。', false)
    }
    .width('100%')
  }

  @Builder
  MemoryNode(title: string, desc: string, milestone: boolean) {
    Column({ space: 6 }) {
      Text(title)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(milestone ? '#8E6125' : '#20302A')
      Text(desc)
        .fontSize(13)
        .fontColor('#687076')
        .lineHeight(20)
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .padding(14)
    .backgroundColor(milestone ? '#FFF7E6' : '#FFFFFF')
    .borderRadius(8)
    .border({ width: milestone ? 1 : 0, color: '#E9C46A' })
  }

  @Builder
  NavButton(label: string, index: number) {
    Button(label)
      .layoutWeight(1)
      .height(46)
      .fontSize(12)
      .fontWeight(this.activeTab === index ? FontWeight.Bold : FontWeight.Regular)
      .fontColor(this.activeTab === index ? '#FFFFFF' : '#53645D')
      .backgroundColor(this.activeTab === index ? '#2F6F62' : '#FFFFFF')
      .borderRadius(8)
      .onClick(() => {
        this.activeTab = index;
      })
  }

  build() {
    Column() {
      if (this.activeTab === 0) {
        this.HomePage()
      } else if (this.activeTab === 1) {
        this.DdlPage()
      } else if (this.activeTab === 2) {
        this.FocusPage()
      } else if (this.activeTab === 3) {
        this.TownPage()
      } else {
        this.BagPage()
      }

      Row({ space: 6 }) {
        this.NavButton('家园', 0)
        this.NavButton('DDL', 1)
        this.NavButton('专注', 2)
        this.NavButton('小镇', 3)
        this.NavButton('背包', 4)
      }
      .width('100%')
      .padding({ left: 10, right: 10, top: 8, bottom: 10 })
      .backgroundColor('#FAF4EA')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F6F2EA')
  }
}
