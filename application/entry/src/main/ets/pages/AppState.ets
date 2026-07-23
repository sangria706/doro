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

export interface SaveData {
  tasks: TaskJson[];
  focusMinutesToday: number;
  focusCount: number;
  coins: number;
  mood: number;
  satiety: number;
  syncVersion: number;
  friends: FriendJson[];
}

export const FOCUS_DURATIONS: number[] = [5, 10, 15, 20, 25, 30, 45, 60];

export const DAY_MS: number = 24 * 60 * 60 * 1000;

export const SAFE_BOTTOM: number = 34;
