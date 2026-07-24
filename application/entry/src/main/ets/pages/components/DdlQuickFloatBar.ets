import { DdlTask } from '../AppState';

@Component
export struct DdlQuickFloatBar {
  @Prop tasks: DdlTask[] = [];
  onOpenDdlTab?: () => void;
  onCreate?: () => void;

  private pendingTasks(): DdlTask[] {
    const result: DdlTask[] = [];
    const now: number = Date.now();
    for (let i: number = 0; i < this.tasks.length; i++) {
      const item: DdlTask = this.tasks[i];
      const deadlineTime: number = new Date(item.deadline.replace(' ', 'T')).getTime();
      if (!item.done && deadlineTime >= now) {
        result.push(item);
      }
    }
    return result;
  }

  private hasPendingTask(): boolean {
    return this.pendingTasks().length > 0;
  }

  private firstPendingTitle(): string {
    const pending: DdlTask[] = this.pendingTasks();
    return pending.length > 0 ? pending[0].title : '暂无任务，点击创建契约';
  }

  private subtitleText(): string {
    return this.hasPendingTask() ? '点击跳转到 DDL 列表' : '还没有待办，先立下一个新契约吧';
  }

  build() {
    Stack() {
      Row() {
        Stack({ alignContent: Alignment.Center }) {
          Circle()
            .width(36)
            .height(36)
            .fill('#FFE8C8')
          Text('📋')
            .fontSize(18)
        }
        .width(40)
        .height(40)

        Column({ space: 2 }) {
          Text(this.firstPendingTitle())
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor('#5A403A')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(this.subtitleText())
            .fontSize(11)
            .fontColor('#9B7D76')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 10 })
        .layoutWeight(1)

        if (this.hasPendingTask()) {
          Button('新建契约')
            .height(34)
            .fontSize(12)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
            .backgroundColor('#FF8F9F')
            .borderRadius(17)
            .onClick(() => {
              if (this.onCreate !== undefined) {
                this.onCreate();
              }
            })
        }
      }
      .width('100%')
      .height('100%')
      .padding({ left: 12, right: 12, top: 10, bottom: 10 })
      .backgroundColor('#FFF7F0')
      .borderRadius(22)
      .shadow({ radius: 16, color: '#28FF9EAF', offsetX: 0, offsetY: 4 })
      .onClick(() => {
        if (this.hasPendingTask() && this.onOpenDdlTab !== undefined) {
          this.onOpenDdlTab();
        } else if (!this.hasPendingTask() && this.onCreate !== undefined) {
          this.onCreate();
        }
      })
    }
    .width('72%')
    .height(76)
  }
}
