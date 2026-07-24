export class DdlTask {
  id: number = 0;
  title: string = '';
  deadline: string = '';
  difficulty: string = '';
  progress: number = 0;
  done: boolean = false;

  constructor(id: number = 0, title: string = '', deadline: string = '', difficulty: string = '', progress: number = 0, done: boolean = false) {
    this.id = id;
    this.title = title;
    this.deadline = deadline;
    this.difficulty = difficulty;
    this.progress = progress;
    this.done = done;
  }
}

export class InventoryItem {
  name: string = '';
  desc: string = '';
  count: number = 0;

  constructor(name: string, desc: string, count: number) {
    this.name = name;
    this.desc = desc;
    this.count = count;
  }
}

export class ShopItem {
  name: string = '';
  desc: string = '';
  price: number = 0;
  category: string = '';
  satietyEffect: number = 0;
  moodEffect: number = 0;

  constructor(name: string, desc: string, price: number, category: string, satietyEffect: number, moodEffect: number) {
    this.name = name;
    this.desc = desc;
    this.price = price;
    this.category = category;
    this.satietyEffect = satietyEffect;
    this.moodEffect = moodEffect;
  }
}

export class FriendInfo {
  id: number = 0;
  name: string = '';
  doroName: string = '';
  isOnline: boolean = false;

  constructor(id: number, name: string, doroName: string, isOnline: boolean) {
    this.id = id;
    this.name = name;
    this.doroName = doroName;
    this.isOnline = isOnline;
  }
}

export class ChatMessage {
  fromMe: boolean = false;
  text: string = '';
  time: string = '';

  constructor(fromMe: boolean, text: string, time: string) {
    this.fromMe = fromMe;
    this.text = text;
    this.time = time;
  }
}

export interface TaskJson {
  id: number;
  title: string;
  deadline: string;
  difficulty: string;
  progress: number;
  done: boolean;
}

export interface FriendJson {
  id: number;
  name: string;
  doroName: string;
  isOnline: boolean;
}

/** 成就数据：id / 名称 / 描述 / 是否解锁 / 是否已领取 / 奖励宝石5 / 奖励金币20 */
export interface AchievementItem {
  id: string;
  name: string;
  desc: string;
  completed: boolean;
  claimed: boolean;
  rewardGems: number;
  rewardCoins: number;
}

export interface AchievementClaimResult {
  rewardGems: number;
  rewardCoins: number;
  showRewardPopup: boolean;
}

/** 3 条测试用默认成就（初始化 / 旧档兜底） */
export const DEFAULT_TEST_ACHIEVEMENTS: AchievementItem[] = [
  {
    id: 'ach_focus_1',
    name: '专注新手',
    desc: '完成 1 次专注',
    completed: false,
    claimed: false,
    rewardGems: 5,
    rewardCoins: 20
  },
  {
    id: 'ach_ddl_1',
    name: 'DDL 初体验',
    desc: '完成 1 个 DDL 任务',
    completed: false,
    claimed: false,
    rewardGems: 5,
    rewardCoins: 20
  },
  {
    id: 'ach_friend_1',
    name: '社交破冰',
    desc: '添加 1 位好友',
    completed: false,
    claimed: false,
    rewardGems: 5,
    rewardCoins: 20
  }
];

export function cloneDefaultAchievements(): AchievementItem[] {
  const result: AchievementItem[] = [];
  for (let i: number = 0; i < DEFAULT_TEST_ACHIEVEMENTS.length; i++) {
    const item: AchievementItem = DEFAULT_TEST_ACHIEVEMENTS[i];
    result.push({
      id: item.id,
      name: item.name,
      desc: item.desc,
      completed: item.completed,
      claimed: item.claimed,
      rewardGems: item.rewardGems,
      rewardCoins: item.rewardCoins
    });
  }
  return result;
}

export interface SaveData {
  tasks: TaskJson[];
  focusMinutesToday: number;
  focusCount: number;
  coins: number;
  mood: number;
  satiety: number;
  syncVersion: number;
  friends: FriendJson[];
  /** 成就列表；旧存档可能无此字段 */
  achievements: AchievementItem[];
}

export const FOCUS_DURATIONS: number[] = [5, 10, 15, 20, 25, 30, 45, 60];

export const DAY_MS: number = 24 * 60 * 60 * 1000;

export const SAFE_BOTTOM: number = 34;
