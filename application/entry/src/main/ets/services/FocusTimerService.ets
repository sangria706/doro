export interface FocusCompleteResult {
  isComplete: boolean;
  coinAdd: number;
  moodAdd: number;
  focusMinutesAdd: number;
  focusCountAdd: number;
  shouldMarkDdlDone: boolean;
  shouldAddFragment: boolean;
  doroWords: string;
  feedback: string;
}

export interface FocusToggleResult {
  focusRunning: boolean;
  feedback: string;
  doroWords: string;
  started: boolean;
}

export interface FocusResetResult {
  focusRunning: boolean;
  focusSecondsLeft: number;
  showFocusCompleteDialog: boolean;
  doroWords: string;
}

export interface FocusContinueResult {
  focusSecondsLeft: number;
  showFocusCompleteDialog: boolean;
}

export interface FocusTickResult {
  focusSecondsLeft: number;
  focusRunning: boolean;
  isComplete: boolean;
}

export class FocusTimerService {
  private timerId: number = -1;

  isTimerActive(): boolean {
    return this.timerId !== -1;
  }

  clearTimer(): void {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }

  /**
   * 开始或暂停：已运行则清除定时器；否则用回调创建防重复定时器
   */
  toggle(secondsLeft: number, onTick: () => void): FocusToggleResult {
    if (this.timerId !== -1) {
      this.clearTimer();
      return {
        focusRunning: false,
        feedback: '已暂停',
        doroWords: 'Doro 伸了个懒腰，等你继续。',
        started: false
      };
    }
    if (secondsLeft <= 0) {
      return {
        focusRunning: false,
        feedback: '',
        doroWords: '',
        started: false
      };
    }
    this.clearTimer();
    this.timerId = setInterval(() => {
      onTick();
    }, 1000) as number;
    return {
      focusRunning: true,
      feedback: '专注开始',
      doroWords: 'Doro 安静坐在旁边看书。',
      started: true
    };
  }

  /**
   * 每秒递减；到 0 时销毁定时器并标记完成
   */
  tick(secondsLeft: number): FocusTickResult {
    if (secondsLeft > 1) {
      return {
        focusSecondsLeft: secondsLeft - 1,
        focusRunning: true,
        isComplete: false
      };
    }
    this.clearTimer();
    return {
      focusSecondsLeft: 0,
      focusRunning: false,
      isComplete: true
    };
  }

  reset(focusDurationMinutes: number): FocusResetResult {
    this.clearTimer();
    return {
      focusRunning: false,
      focusSecondsLeft: focusDurationMinutes * 60,
      showFocusCompleteDialog: false,
      doroWords: '专注已重置，准备好了随时开始。'
    };
  }

  continueMinutes(extraMinutes: number): FocusContinueResult {
    return {
      focusSecondsLeft: extraMinutes * 60,
      showFocusCompleteDialog: false
    };
  }

  /**
   * 会话结束奖励：+5 币、心情+2、分钟/次数累加、每 4 次碎片、是否绑定完成 DDL
   * 数值与原 Index.endFocusSession 一致
   */
  completeSession(
    focusDurationMinutes: number,
    currentFocusCount: number,
    focusMarkDdlDone: boolean,
    selectedTaskId: number
  ): FocusCompleteResult {
    const nextFocusCount: number = currentFocusCount + 1;
    const shouldAddFragment: boolean = nextFocusCount % 4 === 0;
    const shouldMarkDdlDone: boolean = focusMarkDdlDone && selectedTaskId !== -1;
    let doroWords: string = '专注完成，Doro 给你递来小纸条。';
    let feedback: string = '+5 币  心情+2';
    if (shouldAddFragment) {
      doroWords = '专注完成！Doro 送来一片专注之星。';
      feedback = '+5 币  专注之星+1';
    }
    // AchievementService.unlockAchievement("ach_focus_1");
    return {
      isComplete: true,
      coinAdd: 5,
      moodAdd: 2,
      focusMinutesAdd: focusDurationMinutes,
      focusCountAdd: 1,
      shouldMarkDdlDone: shouldMarkDdlDone,
      shouldAddFragment: shouldAddFragment,
      doroWords: doroWords,
      feedback: feedback
    };
  }

  canChangeDurationOrDdl(): boolean {
    return this.timerId === -1;
  }
}
