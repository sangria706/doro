import { DdlTask } from './AppState';

@Component
export struct DdlPage {
  @Prop tasks: DdlTask[] = [];
  @Prop readonly ddlStep: number = 0;
  @Prop newTitle: string = '';
  @Prop newDeadline: string = '';
  @Prop newDifficulty: string = '';
  @Prop doroWords: string = '';
  onTitleChange?: (value: string) => void;
  onDeadlineChange?: (value: string) => void;
  onDifficultyChange?: (value: string) => void;
  onAddTask?: () => void;
  onFinishTask?: (taskId: number) => void;

  build() {
    Scroll() {
      Column({ space: 14 }) {
        this.BrandHeader('任务契约', '每个DDL都由Doro盖上小爪印')
        this.ContractCreator()
        this.TaskSection('进行中', false, false)
        this.TaskSection('已完成', true, false)
        this.TaskSection('已逾期', false, true)
      }
      .padding({ left: 16, right: 16, bottom: 24 })
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
  ContractCreator() {
    Column({ space: 12 }) {
      Row() {
        Text('新建DDL')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#5A403A')
        Blank()
        Text(`步骤 ${this.ddlStep + 1}/4`)
          .fontSize(12)
          .fontColor('#9B7D76')
      }
      .width('100%')
      if (this.ddlStep === 0) {
        TextInput({ placeholder: '请输入DDL内容...', text: this.newTitle })
          .height(46)
          .backgroundColor('#FFF4F7')
          .borderRadius(22)
          .onChange((value: string) => {
            if (this.onTitleChange !== undefined) {
              this.onTitleChange(value);
            }
          })
      } else if (this.ddlStep === 1) {
        TextInput({ placeholder: '2026-07-21 14:00', text: this.newDeadline })
          .height(46)
          .backgroundColor('#FFF4F7')
          .borderRadius(22)
          .onChange((value: string) => {
            if (this.onDeadlineChange !== undefined) {
              this.onDeadlineChange(value);
            }
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
            .fontColor('#7D6862')
            .lineHeight(22)
        }
      } else {
        Column({ space: 8 }) {
          Text('契约成立')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#8A5A4F')
          Text(`你承诺在 ${this.newDeadline} 前完成"${this.newTitle.length > 0 ? this.newTitle : '未命名DDL'}"。`)
            .fontSize(14)
            .fontColor('#7D6862')
            .lineHeight(22)
          Text('Doro 伸出小爪子，盖了个粉色爪印。')
            .fontSize(14)
            .fontColor('#FF7F95')
        }
        .width('100%')
        .padding(14)
        .backgroundColor('#FFF0C9')
        .borderRadius(20)
      }
      Text(this.doroWords)
        .fontSize(14)
        .fontColor('#FF5A7A')
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .visibility(this.doroWords.length > 0 ? Visibility.Visible : Visibility.None)
      Row({ space: 10 }) {
        Button('上一步')
          .layoutWeight(1)
          .height(42)
          .enabled(this.ddlStep > 0)
          .fontColor('#7D6862')
          .backgroundColor('#FFF4F7')
          .borderRadius(21)
          .onClick(() => {
            return;
          })
        Button(this.ddlStep === 2 ? '我承诺' : '下一步')
          .layoutWeight(1)
          .height(42)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
          .backgroundColor('#FF8F9F')
          .borderRadius(21)
          .onClick(() => {
            if (this.ddlStep === 2) {
              if (this.onAddTask !== undefined) {
                this.onAddTask();
              }
            }
          })
      }
    }
    .width('100%')
    .padding(18)
    .backgroundColor('#FFFFFC')
    .borderRadius(24)
    .shadow({ radius: 22, color: '#22FF9EAF', offsetX: 0, offsetY: 8 })
  }

  @Builder
  DifficultyChip(label: string) {
    Button(label)
      .layoutWeight(1)
      .height(38)
      .fontSize(12)
      .fontColor(this.newDifficulty === label ? '#FFFFFF' : '#7D6862')
      .backgroundColor(this.newDifficulty === label ? this.difficultyColor(label) : '#FFF4F7')
      .borderRadius(19)
      .onClick(() => {
        if (this.onDifficultyChange !== undefined) {
          this.onDifficultyChange(label);
        }
      })
  }

  @Builder
  TaskSection(title: string, done: boolean, overdueOnly: boolean) {
    Column({ space: 10 }) {
      Text(`${title} (${this.sectionCount(done, overdueOnly)})`)
        .width('100%')
        .fontSize(17)
        .fontWeight(FontWeight.Bold)
        .fontColor(overdueOnly ? '#F59A7A' : '#5A403A')
      ForEach(this.filteredTasks(done, overdueOnly), (task: DdlTask) => {
        this.TaskCard(task)
      }, (task: DdlTask) => `${task.id}-${title}`)
    }
    .width('100%')
  }

  private filteredTasks(done: boolean, overdueOnly: boolean): DdlTask[] {
    const result: DdlTask[] = [];
    for (let i: number = 0; i < this.tasks.length; i++) {
      const task: DdlTask = this.tasks[i];
      if (this.shouldShowTask(task, done, overdueOnly)) {
        result.push(task);
      }
    }
    return result;
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
    let count: number = 0;
    for (let i: number = 0; i < this.tasks.length; i++) {
      const task: DdlTask = this.tasks[i];
      if (this.shouldShowTask(task, done, overdueOnly)) {
        count++;
      }
    }
    return count;
  }

  private isOverdue(task: DdlTask): boolean {
    return new Date(this.normalizeDeadline(task.deadline)).getTime() < new Date().getTime();
  }

  private normalizeDeadline(value: string): string {
    return value.replace(' ', 'T');
  }

  private pad(value: number): string {
    return value < 10 ? `0${value}` : `${value}`;
  }

  private dateText(deadline: string): string {
    const target: Date = new Date(this.normalizeDeadline(deadline));
    const now: Date = new Date();
    const targetDay: Date = new Date(target.getFullYear(), target.getMonth(), target.getDate());
    const nowDay: Date = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const DAY_MS: number = 24 * 60 * 60 * 1000;
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

  private difficultyColor(difficulty: string): string {
    if (difficulty === '简单') {
      return '#8BC8A5';
    }
    if (difficulty === '普通') {
      return '#BBA6E8';
    }
    if (difficulty === '困难') {
      return '#FF8F9F';
    }
    if (difficulty === '史诗') {
      return '#C995D8';
    }
    return '#C995D8';
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
    if (difficulty === '史诗') {
      return 'Doro 睁大眼睛：史诗任务！要签很认真的约定。';
    }
    return 'Doro 睁大眼睛：史诗任务！要签很认真的约定。';
  }

  @Builder
  TaskCard(task: DdlTask) {
    Column({ space: 10 }) {
      Row() {
        Text(task.title)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(task.done ? '#AF9E99' : '#5A403A')
          .maxLines(2)
          .layoutWeight(1)
        Text(task.difficulty)
          .fontSize(12)
          .fontColor('#FFFFFF')
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .backgroundColor(this.difficultyColor(task.difficulty))
          .borderRadius(14)
      }
      .width('100%')
      Text(this.dateText(task.deadline))
        .fontSize(13)
        .fontColor(this.isOverdue(task) && !task.done ? '#F59A7A' : '#9B7D76')
        .width('100%')
      Progress({ value: task.progress, total: 100, type: ProgressType.Linear })
        .height(9)
        .width('100%')
        .color(this.difficultyColor(task.difficulty))
        .backgroundColor('#F3DDE3')
      Row() {
        Text(task.done ? 'Doro 保存了这段回忆' : 'Doro在旁边打气')
          .fontSize(13)
          .fontColor('#8D746D')
        Blank()
        if (!task.done) {
          Button('标记完成')
            .height(36)
            .fontSize(12)
            .fontColor('#FFFFFF')
            .backgroundColor('#FF8F9F')
            .borderRadius(18)
            .onClick(() => {
              if (this.onFinishTask !== undefined) {
                this.onFinishTask(task.id);
              }
            })
        }
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(task.done ? '#FFF8FA' : '#FFFFFC')
    .borderRadius(22)
    .border({ width: 1, color: this.isOverdue(task) && !task.done ? '#FFC3B1' : '#FFE2EA' })
  }
}
