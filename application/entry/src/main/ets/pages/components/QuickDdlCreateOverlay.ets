@Component
export struct QuickDdlCreateOverlay {
  @Prop ddlStep: number = 0;
  @Prop newTitle: string = '';
  @Prop newDeadline: string = '';
  @Prop newDifficulty: string = '';
  @Prop doroWords: string = '';
  @State pickerDate: Date = new Date();
  onTitleChange?: (value: string) => void;
  onDeadlineChange?: (value: string) => void;
  onDifficultyChange?: (value: string) => void;
  onPrev?: () => void;
  onNext?: () => void;
  onAddTask?: () => void;
  onClose?: () => void;

  aboutToAppear(): void {
    if (this.newDeadline.length > 0) {
      const parsed: Date = new Date(this.newDeadline.replace(' ', 'T'));
      if (!isNaN(parsed.getTime())) {
        this.pickerDate = parsed;
      }
    }
  }

  private formatDate(date: Date): string {
    const y: number = date.getFullYear();
    const m: string = this.padLocal(date.getMonth() + 1);
    const d: string = this.padLocal(date.getDate());
    const h: string = this.padLocal(date.getHours());
    const min: string = this.padLocal(date.getMinutes());
    return `${y}-${m}-${d} ${h}:${min}`;
  }

  private padLocal(n: number): string {
    return n < 10 ? `0${n}` : `${n}`;
  }

  private notifyDeadlineChange(): void {
    if (this.onDeadlineChange !== undefined) {
      this.onDeadlineChange(this.formatDate(this.pickerDate));
    }
  }

  build() {
    Column() {
      Column({ space: 12 }) {
        Row() {
          Text('快速新建DDL任务')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#5A403A')
            .layoutWeight(1)
          Button('✕')
            .width(32)
            .height(32)
            .fontSize(16)
            .fontColor('#7D6862')
            .backgroundColor('#FFF4F7')
            .borderRadius(16)
            .onClick(() => {
              if (this.onClose !== undefined) {
                this.onClose();
              }
            })
        }
        .width('100%')

        Text('步骤 ' + (this.ddlStep + 1).toString() + '/3 · 标题 → 截止时间 → 难度')
          .fontSize(12)
          .fontColor('#9B7D76')
          .width('100%')

        if (this.ddlStep === 1 && this.newDeadline.length > 0) {
          Text('当前选择：' + this.newDeadline)
            .fontSize(13)
            .fontColor('#FF7F95')
            .width('100%')
            .textAlign(TextAlign.Center)
        }

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
          Column({ space: 8 }) {
            Text('📅 选择截止日期')
              .fontSize(14)
              .fontColor('#5A403A')
              .width('100%')
            DatePicker({
              start: new Date(),
              end: new Date('2100-12-31'),
              selected: this.pickerDate
            })
              .width('100%')
              .onDateChange((value: Date) => {
                const merged: Date = new Date(value);
                merged.setHours(this.pickerDate.getHours(), this.pickerDate.getMinutes());
                this.pickerDate = merged;
                this.notifyDeadlineChange();
              })
            Text('⏰ 选择截止时间')
              .fontSize(14)
              .fontColor('#5A403A')
              .width('100%')
            TimePicker({
              selected: this.pickerDate
            })
              .useMilitaryTime(true)
              .width('100%')
              .onChange((value: TimePickerResult) => {
                this.pickerDate.setHours(value.hour, value.minute);
                this.notifyDeadlineChange();
              })
          }
        } else {
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
              if (this.onPrev !== undefined) {
                this.onPrev();
              }
            })
          Button(this.ddlStep >= 2 ? '我承诺' : '下一步')
            .layoutWeight(1)
            .height(42)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
            .backgroundColor('#FF8F9F')
            .borderRadius(21)
            .onClick(() => {
              if (this.ddlStep >= 2) {
                if (this.onAddTask !== undefined) {
                  this.onAddTask();
                }
              } else if (this.onNext !== undefined) {
                this.onNext();
              }
            })
        }
      }
      .width('88%')
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
    return 'Doro 睁大眼睛：史诗任务！要签很认真的约定。';
  }
}
