import { DdlTask } from '../pages/AppState';

// ====================== 常量抽离（便于统一维护、对接后端） ======================
namespace DdlConstant {
  // 新建任务奖励
  export const ADD_TASK_COIN = 3;
  // 按时/逾期完成金币奖励
  export const FINISH_ON_TIME_COIN = 18;
  export const FINISH_LATE_COIN = 6;
  // 心情变动
  export const MOOD_ON_TIME = 8;
  export const MOOD_LATE = 2;
  // 饱腹固定扣除
  export const SATIETY_DEDUCT = -2;
  // 时间格式正则
  export const DEADLINE_REG = /^\d{4}-\d{2}-\d{2} \d{2}:\d{2}$/;
}

// ====================== 返回值结构 ======================
export interface DdlTaskAddResult {
  tasks: DdlTask[];
  selectedTaskId: number;
  newTitle: string;
  newDeadline: string;
  ddlStep: number;
  coinsDelta: number;
  doroWords: string;
  shouldSync: boolean;
  feedback: string;
}

export interface DdlTaskFinishResult {
  tasks: DdlTask[];
  reward: number;
  late: boolean;
  moodDelta: number;
  satietyDelta: number;
  doroWords: string;
  shouldSync: boolean;
  feedback: string;
  triggerDoneDialogue: boolean;
  triggerOverdueDialogue: boolean;
}

// ====================== 核心业务服务类 ======================
/**
 * DDL任务纯业务计算服务
 * 只负责数据运算、规则判断，不操作页面@State、不弹窗、不路由跳转
 */
export class DdlTaskService {
  /**
   * 标准化截止时间：空格替换为T，用于时间戳对比
   */
  private normalizeDeadline(value: string): string {
    return value.replace(' ', 'T');
  }

  /**
   * 判断任务是否逾期
   */
  isOverdue(task: DdlTask): boolean {
    const deadlineTime = new Date(this.normalizeDeadline(task.deadline)).getTime();
    const now = Date.now();
    return deadlineTime < now;
  }

  /**
   * 统计未完成且未逾期待办数量
   */
  pendingCount(tasks: DdlTask[]): number {
    let count: number = 0;
    for (let i: number = 0; i < tasks.length; i++) {
      const item: DdlTask = tasks[i];
      if (!item.done && !this.isOverdue(item)) {
        count += 1;
      }
    }
    return count;
  }

  /**
   * 统计未完成已逾期任务数量
   */
  overdueCount(tasks: DdlTask[]): number {
    let count: number = 0;
    for (let i: number = 0; i < tasks.length; i++) {
      const item: DdlTask = tasks[i];
      if (!item.done && this.isOverdue(item)) {
        count += 1;
      }
    }
    return count;
  }

  /**
   * 新增DDL任务
   * @param tasks 原任务数组
   * @param newTitle 任务标题
   * @param newDeadline 截止时间字符串
   * @param newDifficulty 难度
   * @returns 处理后结果结构体
   */
  addTask(
    tasks: DdlTask[],
    newTitle: string,
    newDeadline: string,
    newDifficulty: string
  ): DdlTaskAddResult {
    const trimTitle: string = newTitle.trim();
    if (trimTitle.length === 0) {
      return {
        tasks: this.cloneTasks(tasks),
        selectedTaskId: -1,
        newTitle: newTitle,
        newDeadline: newDeadline,
        ddlStep: 0,
        coinsDelta: 0,
        doroWords: '契约要先写下名字哦。',
        shouldSync: false,
        feedback: ''
      };
    }
    if (!DdlConstant.DEADLINE_REG.test(newDeadline)) {
      return {
        tasks: this.cloneTasks(tasks),
        selectedTaskId: -1,
        newTitle: newTitle,
        newDeadline: newDeadline,
        ddlStep: 1,
        coinsDelta: 0,
        doroWords: '日期格式写成 2026-05-21 13:14哦。',
        shouldSync: false,
        feedback: ''
      };
    }
    const deadlineTime: number = new Date(newDeadline.replace(' ', 'T')).getTime();
    if (deadlineTime <= Date.now()) {
      return {
        tasks: this.cloneTasks(tasks),
        selectedTaskId: -1,
        newTitle: newTitle,
        newDeadline: newDeadline,
        ddlStep: 1,
        coinsDelta: 0,
        doroWords: '截止时间不能早于现在哦。',
        shouldSync: false,
        feedback: ''
      };
    }
    const newTask: DdlTask = new DdlTask(Date.now(), trimTitle, newDeadline, newDifficulty, 0, false);
    const nextTasks: DdlTask[] = [];
    nextTasks.push(newTask);
    for (let i: number = 0; i < tasks.length; i++) {
      nextTasks.push(tasks[i]);
    }
    return {
      tasks: nextTasks,
      selectedTaskId: newTask.id,
      newTitle: '',
      newDeadline: newDeadline,
      ddlStep: 0,
      coinsDelta: DdlConstant.ADD_TASK_COIN,
      doroWords: '契约成立！Doro 盖上了小爪印。',
      shouldSync: true,
      feedback: `+${DdlConstant.ADD_TASK_COIN} Doro币`
    };
  }

  /**
   * 完成指定任务，计算奖励、状态、对话触发标记
   * @param tasks 原任务列表
   * @param taskId 要完成的任务ID
   */
  finishTask(tasks: DdlTask[], taskId: number): DdlTaskFinishResult {
    let isLate: boolean = false;
    let rewardCoin: number = 0;
    const nextTasks: DdlTask[] = [];
    for (let i: number = 0; i < tasks.length; i++) {
      const task: DdlTask = tasks[i];
      if (task.id === taskId && !task.done) {
        isLate = this.isOverdue(task);
        rewardCoin = isLate ? DdlConstant.FINISH_LATE_COIN : DdlConstant.FINISH_ON_TIME_COIN;
        nextTasks.push(new DdlTask(task.id, task.title, task.deadline, task.difficulty, 100, true));
      } else {
        nextTasks.push(task);
      }
    }
    const moodDelta: number = isLate ? DdlConstant.MOOD_LATE : DdlConstant.MOOD_ON_TIME;
    const satietyDelta: number = DdlConstant.SATIETY_DEDUCT;
    const doroWords: string = isLate
      ? '虽然晚了一点，Doro 还是松了一口气。'
      : '提前完成！Doro 开心地转了一圈。';
    // AchievementService.unlockAchievement("ach_ddl_1");
    return {
      tasks: nextTasks,
      reward: rewardCoin,
      late: isLate,
      moodDelta: moodDelta,
      satietyDelta: satietyDelta,
      doroWords: doroWords,
      shouldSync: rewardCoin > 0,
      feedback: `+${rewardCoin} 币  心情+${moodDelta}`,
      triggerDoneDialogue: rewardCoin > 0 && !isLate,
      triggerOverdueDialogue: rewardCoin > 0 && isLate
    };
  }

  private cloneTasks(tasks: DdlTask[]): DdlTask[] {
    const nextTasks: DdlTask[] = [];
    for (let i: number = 0; i < tasks.length; i++) {
      const task: DdlTask = tasks[i];
      nextTasks.push(new DdlTask(task.id, task.title, task.deadline, task.difficulty, task.progress, task.done));
    }
    return nextTasks;
  }
}
