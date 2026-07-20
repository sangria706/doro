import { DialogueEntry, DialogueOption, ALL_DIALOGUES, DialogueManager } from './DialogueSystem';
import { CatNPC, CatAffection, CatBento, BentoResult, ALL_CATS, BENTO_LIST, getCatById, getBentoById, getAffectionLevel, getAffectionColor, getAffectionLevelEmoji, getDailyDialogue, getBentoReaction, isCatAwake } from './CatNPCSystem';

class DdlTask {
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

class ShopItem {
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

class FriendInfo {
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

class ChatMessage {
  fromMe: boolean = false;
  text: string = '';
  time: string = '';

  constructor(fromMe: boolean, text: string, time: string) {
    this.fromMe = fromMe;
    this.text = text;
    this.time = time;
  }
}

interface TaskJson {
  id: number;
  title: string;
  deadline: string;
  difficulty: string;
  progress: number;
  done: boolean;
}

interface FriendJson {
  id: number;
  name: string;
  doroName: string;
  isOnline: boolean;
}

interface SaveData {
  tasks: TaskJson[];
  focusMinutesToday: number;
  focusCount: number;
  coins: number;
  mood: number;
  satiety: number;
  syncVersion: number;
  friends: FriendJson[];
}

const FOCUS_DURATIONS: number[] = [5, 10, 15, 20, 25, 30, 45, 60];

const DAY_MS: number = 24 * 60 * 60 * 1000;
const SAFE_BOTTOM: number = 34;

@Entry
@Component
struct Index {
  @State appStage: number = 0;
  @State activeTab: number = 0;
  @State ddlStep: number = 0;
  @State showShop: boolean = false;
  @State showChat: boolean = false;
  @State showProfile: boolean = false;
  @State profileName: string = '';
  @State focusSliderValue: number = 25;
  @State bagTab: number = 0;
  @State focusRunning: boolean = false;
  @State selectedTaskId: number = 1;
  @State username: string = '';
  @State doroName: string = '桃桃';
  @State usernameHint: string = '2-12个字符，中文/英文/数字/下划线';
  @State newTitle: string = '';
  @State newDeadline: string = '2026-07-21 14:00';
  @State newDifficulty: string = '困难';
  @State mood: number = 76;
  @State satiety: number = 68;
  @State coins: number = 328;
  @State comfort: number = 13;
  @State focusMinutesToday: number = 75;
  @State focusCount: number = 3;
  @State syncVersion: number = 12;
  @State focusDuration: number = 25;
  @State focusSecondsLeft: number = 1500;
  @State focusCustomName: string = '';
  @State showFocusCompleteDialog: boolean = false;
  @State focusMarkDdlDone: boolean = false;
  @State showDdlPicker: boolean = false;
  @State showFeedPicker: boolean = false;
  @State showDressPicker: boolean = false;
  @State shopTab: number = 0;
  @State friends: FriendInfo[] = [];
  @State friendChatHistory: ChatMessage[] = [];
  @State chatTargetId: number = -1;
  @State chatInputText: string = '';
  @State searchKeyword: string = '';
  @State searchResults: FriendInfo[] = [];
  @State showFriendSearch: boolean = false;
  @State feedback: string = '';
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
    new InventoryItem('樱花小围巾', '粉色治愈系初始装扮', 1),
    new InventoryItem('专注之星碎片', '集齐 4 片可兑换头饰', 2),
    new InventoryItem('铃铛发带', '重逢剧情纪念物', 0)
  ];
  @State furnitures: InventoryItem[] = [
    new InventoryItem('蜜桃软垫', '舒适度 +4', 1),
    new InventoryItem('薄荷绿植', '舒适度 +3', 1),
    new InventoryItem('暖光小灯', '舒适度 +5', 0)
  ];
  private readonly shopItems: ShopItem[] = [
    new ShopItem('草莓奶油包', '香甜松软，Doro超爱', 12, 'food', 18, 6),
    new ShopItem('温泉蛋拌饭', '暖心暖胃的家常味', 10, 'food', 15, 4),
    new ShopItem('蜂蜜柚子茶', '喝一杯心情会变好', 8, 'food', 8, 10),
    new ShopItem('烤红薯', '冬天里的暖手宝', 6, 'food', 12, 3),
    new ShopItem('樱花小围巾', '粉色治愈系初始装扮', 20, 'outfit', 0, 5),
    new ShopItem('星星发卡', '戴上就有好运气', 25, 'outfit', 0, 8),
    new ShopItem('毛绒手套', '冬天也要暖暖的', 15, 'outfit', 0, 4),
    new ShopItem('蜜桃软垫', '舒适度 +4', 18, 'furniture', 0, 0),
    new ShopItem('薄荷绿植', '舒适度 +3', 14, 'furniture', 0, 0),
    new ShopItem('暖光小灯', '舒适度 +5', 22, 'furniture', 0, 0)
  ];
  private timerId: number = -1;
  @State gems: number = 48;

  @State hasEventUpdate: boolean = true;

  @State showDialogue: boolean = false;
  @State currentDialogueId: string = '';
  @State dialogueSpeakerText: string = '';
  @State dialogueSpeakerEmoji: string = '';
  @State dialogueSpeakerName: string = '';
  @State dialogueTypewriterText: string = '';
  @State dialogueTypewriterFull: string = '';
  @State dialogueShowOptions: boolean = false;
  @State dialogueOptions: DialogueOption[] = [];
  @State dialogueEffectText: string = '';
  @State dialogueEffectColor: string = '#FF8F9F';
  @State dialogueAffinity: number = 0;
  @State dialogueCoinReward: number = 0;
  @State lastSelectedTone: string = '';
  @State dialogueResponseDone: boolean = false;
  private dialogueManager: DialogueManager = new DialogueManager();
  private dialogueTypewriterTimer: number = -1;

  @State catAffections: Record<string, CatAffection> = {};
  @State showCatList: boolean = true;
  @State selectedCat: CatNPC | null = null;
  @State selectedCatAffection: number = 0;
  @State selectedCatVisitCount: number = 0;
  @State showBentoPicker: boolean = false;
  @State bentoReactionText: string = '';
  @State bentoReactionEmoji: string = '';
  @State showBentoResult: boolean = false;
  @State catAffectionFloat: string = '';
  @State levelUpText: string = '';
  @State showLevelUp: boolean = false;
  @State catGreetingText: string = '';
  @State showCatDetail: boolean = false;
  @State catChatMessages: ChatMessage[] = [];
  @State catChatShowOptions: boolean = false;
  @State catChatDone: boolean = false;

  aboutToAppear(): void {
    this.loadData();
    this.initFriends();
    this.initCatAffections();
    setTimeout(() => {
      this.checkAndTriggerDialogue();
    }, 500);
  }

  private initCatAffections(): void {
    for (let i: number = 0; i < ALL_CATS.length; i++) {
      const cat: CatNPC = ALL_CATS[i];
      if (this.catAffections[cat.id] === undefined) {
        const newAff: CatAffection = {
          npcId: cat.id,
          affection: 0,
          visitCount: 0,
          lastVisitDate: '',
          lastGiftTime: 0,
          receivedGifts: []
        };
        const key: string = cat.id;
        this.catAffections[key] = newAff;
      }
    }
  }

  private clamp(value: number): number {
    if (value < 0) {
      return 0;
    }
    if (value > 100) {
      return 100;
    }
    return value;
  }

  private syncLocalChange(text: string): void {
    this.syncVersion += 1;
    this.feedback = text;
    this.saveData();
  }

  private saveData(): void {
    PersistentStorage.persistProp('doro_save', '');
    const taskArray: TaskJson[] = [];
    for (let i: number = 0; i < this.tasks.length; i++) {
      const t: DdlTask = this.tasks[i];
      const tj: TaskJson = { id: t.id, title: t.title, deadline: t.deadline, difficulty: t.difficulty, progress: t.progress, done: t.done };
      taskArray.push(tj);
    }
    const friendArray: FriendJson[] = [];
    for (let i: number = 0; i < this.friends.length; i++) {
      const f: FriendInfo = this.friends[i];
      const fj: FriendJson = { id: f.id, name: f.name, doroName: f.doroName, isOnline: f.isOnline };
      friendArray.push(fj);
    }
    const affs: CatAffection[] = [];
    const keys: string[] = Object.keys(this.catAffections);
    for (let i: number = 0; i < keys.length; i++) {
      const aff: CatAffection | undefined = this.catAffections[keys[i]];
      if (aff !== undefined) {
        affs.push(aff);
      }
    }
    const data: SaveData = {
      tasks: taskArray,
      focusMinutesToday: this.focusMinutesToday,
      focusCount: this.focusCount,
      coins: this.coins,
      mood: this.mood,
      satiety: this.satiety,
      syncVersion: this.syncVersion,
      friends: friendArray
    };
    AppStorage.set('doro_save', JSON.stringify(data));
    AppStorage.set('cat_affections', JSON.stringify(affs));
  }

  private loadData(): void {
    PersistentStorage.persistProp('doro_save', '');
    const raw: Object = AppStorage.get('doro_save') as Object;
    const json: string = raw !== undefined ? raw as string : '';
    if (json.length > 0) {
      const data: SaveData = JSON.parse(json) as SaveData;
      this.tasks = data.tasks.map((td: TaskJson) =>
        new DdlTask(td.id, td.title, td.deadline, td.difficulty, td.progress, td.done));
      this.focusMinutesToday = data.focusMinutesToday;
      this.focusCount = data.focusCount;
      this.coins = data.coins;
      this.mood = data.mood;
      this.satiety = data.satiety;
      this.syncVersion = data.syncVersion;
      if (data.friends !== undefined) {
        this.friends = data.friends.map((fj: FriendJson) =>
          new FriendInfo(fj.id, fj.name, fj.doroName, fj.isOnline));
      }
    }
    PersistentStorage.persistProp('cat_affections', '');
    const affRaw: Object = AppStorage.get('cat_affections') as Object;
    const affJson: string = affRaw !== undefined ? affRaw as string : '';
    if (affJson.length > 0) {
      const affs: CatAffection[] = JSON.parse(affJson) as CatAffection[];
      for (let i: number = 0; i < affs.length; i++) {
        const aff: CatAffection = affs[i];
        this.catAffections[aff.npcId] = aff;
      }
    }
  }

  private pendingCount(): number {
    return this.tasks.filter((task: DdlTask) => !task.done && !this.isOverdue(task)).length;
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

  private pad(value: number): string {
    return value < 10 ? `0${value}` : `${value}`;
  }

  private calcLevel(): number {
    return Math.floor(this.focusCount / 5) + 1;
  }

  private calcExpProgress(): number {
    return this.focusCount % 5;
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

  private selectedTaskTitle(): string {
    if (this.selectedTaskId === -1) {
      if (this.focusCustomName.length > 0) {
        return this.focusCustomName;
      }
      return '自定义专注';
    }
    const selected: DdlTask[] = this.tasks.filter((task: DdlTask) => task.id === this.selectedTaskId);
    if (selected.length === 0) {
      return '选择一个 DDL';
    }
    return selected[0].title;
  }

  private nextNickname(): void {
    const names: string[] = ['樱桃糯米', '桃雾同学', '云朵布丁', '小莓计划家', '奶油星星'];
    this.username = names[Math.floor(Math.random() * names.length)];
    this.usernameHint = 'Doro 帮你取好了，可以直接确认';
  }

  private checkUsername(value: string): void {
    this.username = value;
    if (value.length < 2) {
      this.usernameHint = '名字再长一点，Doro 才记得牢';
      return;
    }
    if (value.length > 12) {
      this.usernameHint = '名字太长啦，控制在12个字符内';
      return;
    }
    this.usernameHint = '这个名字可以使用';
  }

  private confirmUsername(): void {
    if (this.username.length < 2 || this.username.length > 12) {
      this.usernameHint = '先填一个 2-12 个字符的名字';
      return;
    }
    this.doroName = `${this.username}的Doro`;
    this.appStage = 3;
    this.doroWords = `你就是我的主人吗？我叫${this.doroName}！`;
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
    const task: DdlTask = new DdlTask(Date.now(), title, this.newDeadline, this.newDifficulty, 0, false);
    this.tasks = [task, ...this.tasks];
    this.selectedTaskId = task.id;
    this.newTitle = '';
    this.ddlStep = 0;
    this.coins += 3;
    this.doroWords = '契约成立！Doro 盖上了小爪印。';
    this.syncLocalChange('+3 Doro币');
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
      this.syncLocalChange(`+${reward} 币  心情+${late ? 2 : 8}`);
      if (!this.showDialogue) {
        if (late) {
          this.triggerDdlOverdueDialogue();
        } else {
          this.triggerDdlDoneDialogue();
        }
      }
    }
  }

  private touchDoro(): void {
    this.mood = this.clamp(this.mood + 1);
    const words: string[] = [
      '嘿嘿，被你发现我在等你。',
      '爱心粒子冒出来了，今日心情 +1。',
      'Doro 跳了一下，然后认真坐好。',
      '一起把最难的那件事拆小一点吧。'
    ];
    this.doroWords = words[Math.floor(Math.random() * words.length)];
    this.syncLocalChange('心情 +1');
  }

  private feedDoro(): void {
    const hasFood: boolean = this.foods.some((item: InventoryItem) => item.count > 0);
    if (!hasFood) {
      this.doroWords = '没有食物了，先去小镇逛逛吧。';
      this.feedback = '食物空空';
      return;
    }
    this.showFeedPicker = true;
  }

  private dressDoro(): void {
    const hasOutfit: boolean = this.outfits.some((item: InventoryItem) => item.count > 0);
    if (!hasOutfit) {
      this.doroWords = '没有装扮了，完成 DDL 获取新装扮吧。';
      this.feedback = '装扮空空';
      return;
    }
    this.showDressPicker = true;
  }

  private feedWithItem(index: number): void {
    const item: InventoryItem = this.foods[index];
    if (item.count <= 0) {
      return;
    }
    this.foods = this.foods.map((food: InventoryItem, foodIndex: number) => {
      if (foodIndex === index) {
        return new InventoryItem(food.name, food.desc, food.count - 1);
      }
      return food;
    });
    this.satiety = this.clamp(this.satiety + 12);
    this.mood = this.clamp(this.mood + 3);
    this.doroWords = 'Doro 开心地吃完了' + item.name + '。';
    this.showFeedPicker = false;
    this.syncLocalChange('饱腹 +12  心情 +3');
  }

  private dressWithItem(index: number): void {
    const item: InventoryItem = this.outfits[index];
    if (item.count <= 0) {
      return;
    }
    this.mood = this.clamp(this.mood + 2);
    this.doroWords = 'Doro 穿上了' + item.name + '，在镜子前转了一圈。';
    this.showDressPicker = false;
    this.syncLocalChange('心情 +2');
  }

  private buyShopItem(index: number): void {
    const item: ShopItem = this.shopItems[index];
    if (this.coins < item.price) {
      this.doroWords = '三叶草币不够啦，再完成一些 DDL 吧。';
      return;
    }
    this.coins -= item.price;
    if (item.category === 'food') {
      this.foods = this.foods.map((food: InventoryItem) => {
        if (food.name === item.name) {
          return new InventoryItem(food.name, food.desc, food.count + 1);
        }
        return food;
      });
      const exists: boolean = this.foods.some((food: InventoryItem) => food.name === item.name);
      if (!exists) {
        this.foods = [...this.foods, new InventoryItem(item.name, item.desc, 1)];
      }
    } else if (item.category === 'outfit') {
      this.outfits = this.outfits.map((outfit: InventoryItem) => {
        if (outfit.name === item.name) {
          return new InventoryItem(outfit.name, outfit.desc, outfit.count + 1);
        }
        return outfit;
      });
      const exists: boolean = this.outfits.some((outfit: InventoryItem) => outfit.name === item.name);
      if (!exists) {
        this.outfits = [...this.outfits, new InventoryItem(item.name, item.desc, 1)];
      }
    }
    this.doroWords = '购买了' + item.name + '！Doro 帮你收好了。';
    this.syncLocalChange('-' + item.price.toString() + ' 币');
  }

  private initFriends(): void {
    if (this.friends.length > 0) {
      return;
    }
    this.friends = [
      new FriendInfo(1, '小蓝', '小蓝的Doro', true),
      new FriendInfo(2, '阿禾', '阿禾的Doro', false),
      new FriendInfo(3, '沐沐', '沐沐的Doro', true),
      new FriendInfo(4, '栗子', '栗子的Doro', false),
      new FriendInfo(5, '小北', '小北的Doro', true)
    ];
  }

  private openChat(friendId: number): void {
    this.chatTargetId = friendId;
    this.chatInputText = '';
    this.friendChatHistory = [];
    this.showChat = true;
  }

  private sendMessage(): void {
    const text: string = this.chatInputText.trim();
    if (text.length === 0) {
      return;
    }
    const now: Date = new Date();
    const time: string = this.pad(now.getHours()) + ':' + this.pad(now.getMinutes());
    this.friendChatHistory = [...this.friendChatHistory, new ChatMessage(true, text, time)];
    this.chatInputText = '';
    const target: FriendInfo | undefined = this.friends.find((f: FriendInfo) => f.id === this.chatTargetId);
    if (target !== undefined) {
      setTimeout(() => {
        const replies: string[] = [
          '好的呀~ Doro 说收到！',
          '嗯嗯，我记住了！',
          '一起加油吧~',
          'Doro 点了点头。',
          '好哦，晚点见！'
        ];
        const reply: string = replies[Math.floor(Math.random() * replies.length)];
        const replyNow: Date = new Date();
        const replyTime: string = this.pad(replyNow.getHours()) + ':' + this.pad(replyNow.getMinutes());
        this.friendChatHistory = [...this.friendChatHistory, new ChatMessage(false, reply, replyTime)];
      }, 800);
    }
  }

  private searchFriends(): void {
    const keyword: string = this.searchKeyword.trim().toLowerCase();
    if (keyword.length === 0) {
      this.searchResults = [];
      return;
    }
    const allUsers: FriendInfo[] = [
      new FriendInfo(1, '小蓝', '小蓝的Doro', true),
      new FriendInfo(2, '阿禾', '阿禾的Doro', false),
      new FriendInfo(3, '沐沐', '沐沐的Doro', true),
      new FriendInfo(4, '栗子', '栗子的Doro', false),
      new FriendInfo(5, '小北', '小北的Doro', true),
      new FriendInfo(6, '糖糖', '糖糖的Doro', true),
      new FriendInfo(7, '小橘', '小橘的Doro', false),
      new FriendInfo(8, '团团', '团团的Doro', true),
      new FriendInfo(9, '豆豆', '豆豆的Doro', false),
      new FriendInfo(10, '花花', '花花的Doro', true)
    ];
    this.searchResults = allUsers.filter((u: FriendInfo) =>
      u.name.toLowerCase().includes(keyword) &&
      !this.friends.some((f: FriendInfo) => f.id === u.id)
    );
  }

  private addFriend(friendId: number): void {
    const found: FriendInfo | undefined = this.searchResults.find((f: FriendInfo) => f.id === friendId);
    if (found !== undefined) {
      this.friends = [...this.friends, found];
      this.searchResults = this.searchResults.filter((f: FriendInfo) => f.id !== friendId);
      this.doroWords = '你和' + found.name + '成为好友了！';
      this.syncLocalChange('好友 +1');
    }
  }

  private toggleFocus(): void {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
      this.focusRunning = false;
      this.doroWords = 'Doro 伸了个懒腰，等你继续。';
      this.feedback = '已暂停';
    } else if (this.focusSecondsLeft > 0) {
      this.focusRunning = true;
      this.doroWords = 'Doro 安静坐在旁边看书。';
      this.feedback = '专注开始';
      this.timerId = setInterval(() => {
        if (this.focusSecondsLeft > 1) {
          this.focusSecondsLeft -= 1;
        } else {
          this.focusSecondsLeft = 0;
          this.focusRunning = false;
          clearInterval(this.timerId);
          this.timerId = -1;
          this.onFocusComplete();
        }
      }, 1000);
    }
  }

  private onFocusComplete(): void {
    this.showFocusCompleteDialog = true;
    this.focusMarkDdlDone = false;
    this.doroWords = '时间到！Doro 轻轻碰了碰你的手。';
  }

  private continueFocus(extraMinutes: number): void {
    this.focusSecondsLeft = extraMinutes * 60;
    this.showFocusCompleteDialog = false;
    this.toggleFocus();
  }

  private endFocusSession(): void {
    const elapsedMinutes: number = this.focusDuration;
    this.focusMinutesToday += elapsedMinutes;
    this.focusCount += 1;
    this.coins += 5;
    this.mood = this.clamp(this.mood + 2);
    if (this.focusMarkDdlDone && this.selectedTaskId !== -1) {
      this.finishTask(this.selectedTaskId);
    }
    if (this.focusCount % 4 === 0) {
      this.outfits = this.outfits.map((item: InventoryItem) => {
        if (item.name === '专注之星碎片') {
          return new InventoryItem(item.name, item.desc, item.count + 1);
        }
        return item;
      });
      this.doroWords = '专注完成！Doro 送来一片专注之星。';
      this.syncLocalChange('+5 币  专注之星+1');
    } else {
      this.doroWords = '专注完成，Doro 给你递来小纸条。';
      this.syncLocalChange('+5 币  心情+2');
    }
    this.showFocusCompleteDialog = false;
    this.saveData();
  }

  private selectDuration(minutes: number): void {
    if (this.timerId !== -1) {
      return;
    }
    this.focusDuration = minutes;
    this.focusSecondsLeft = minutes * 60;
  }

  private resetFocus(): void {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
    this.focusRunning = false;
    this.focusSecondsLeft = this.focusDuration * 60;
    this.showFocusCompleteDialog = false;
    this.doroWords = '专注已重置，准备好了随时开始。';
  }

  private formatTime(seconds: number): string {
    const m: number = Math.floor(seconds / 60);
    const s: number = seconds % 60;
    return this.pad(m) + ':' + this.pad(s);
  }

  private selectDdlForFocus(taskId: number): void {
    if (this.timerId !== -1) {
      return;
    }
    this.selectedTaskId = taskId;
    this.showDdlPicker = false;
    if (taskId === -1) {
      this.focusCustomName = '';
    }
  }

  private getFocusSubtitle(): string {
    if (this.selectedTaskId === -1) {
      if (this.focusCustomName.length > 0) {
        return '专注：' + this.focusCustomName;
      }
      return '自定义专注时间';
    }
    return 'Doro安静陪你完成' + this.focusDuration.toString() + '分钟';
  }

  private leaveBento(): void {
    if (this.foods[0].count <= 0) {
      this.doroWords = '今天的普通便当已经送出去了。';
      this.feedback = '便当已用完';
      return;
    }
    this.foods = this.foods.map((item: InventoryItem, index: number) => {
      if (index === 0) {
        return new InventoryItem(item.name, item.desc, item.count - 1);
      }
      return item;
    });
    this.doroWords = '便当旁边留下了你家 Doro 的小爪印。';
    this.syncLocalChange('便当已送达');
  }

  private useFood(index: number): void {
    const item: InventoryItem = this.foods[index];
    if (item.count <= 0) {
      this.feedback = '库存不足';
      return;
    }
    this.foods = this.foods.map((food: InventoryItem, foodIndex: number) => {
      if (foodIndex === index) {
        return new InventoryItem(food.name, food.desc, food.count - 1);
      }
      return food;
    });
    this.satiety = this.clamp(this.satiety + 12);
    this.mood = this.clamp(this.mood + 3);
    this.doroWords = `Doro 吃掉了${item.name}。`;
    this.syncLocalChange('饱腹 +12');
  }

  private checkAndTriggerDialogue(): void {
    const hour: number = new Date().getHours();
    const timeDialogue: DialogueEntry | null = this.dialogueManager.checkTimeBased(hour);
    if (timeDialogue !== null) {
      this.startDialogueById(timeDialogue.dialogueId);
      return;
    }
    const moodDialogue: DialogueEntry | null = this.dialogueManager.checkMoodBased(this.mood);
    if (moodDialogue !== null) {
      this.startDialogueById(moodDialogue.dialogueId);
      return;
    }
  }

  private startDialogueById(dialogueId: string): void {
    const entry: DialogueEntry | null = this.dialogueManager.startDialogue(dialogueId);
    if (entry === null) {
      return;
    }
    this.currentDialogueId = dialogueId;
    this.dialogueSpeakerEmoji = entry.speakerEmoji;
    this.dialogueSpeakerName = entry.speaker === 'doro' ? 'Doro' : this.getNpcName(entry.speaker);
    this.dialogueTypewriterFull = entry.text;
    this.dialogueTypewriterText = '';
    this.dialogueShowOptions = false;
    this.dialogueOptions = entry.options.slice(0);
    this.dialogueEffectText = '';
    this.dialogueResponseDone = false;
    this.showDialogue = true;
    this.startTypewriter();
  }

  private getNpcName(speakerId: string): string {
    const map: Record<string, string> = {
      'npc_1': '小蓝', 'npc_2': '阿禾', 'npc_3': '沐沐',
      'npc_4': '栗子', 'npc_5': '小北', 'npc_6': '糖糖',
      'npc_7': '小橘', 'npc_8': '团团', 'npc_9': '豆豆', 'npc_10': '花花'
    };
    const name: string | undefined = map[speakerId];
    if (name !== undefined) {
      return name;
    }
    return '猫咪';
  }

  private startTypewriter(): void {
    if (this.dialogueTypewriterTimer !== -1) {
      clearInterval(this.dialogueTypewriterTimer);
    }
    let idx: number = 0;
    this.dialogueTypewriterTimer = setInterval(() => {
      if (idx < this.dialogueTypewriterFull.length) {
        this.dialogueTypewriterText = this.dialogueTypewriterFull.substring(0, idx + 1);
        idx++;
      } else {
        clearInterval(this.dialogueTypewriterTimer);
        this.dialogueTypewriterTimer = -1;
        if (this.dialogueResponseDone) {
          setTimeout(() => {
            this.closeDialogue();
          }, 1200);
        } else {
          this.dialogueShowOptions = true;
        }
      }
    }, 35);
  }

  private onDialogueOptionSelect(optionIndex: number): void {
    if (!this.dialogueShowOptions) {
      return;
    }
    const option: DialogueOption | null = this.dialogueManager.selectOption(optionIndex);
    if (option === null) {
      return;
    }
    this.lastSelectedTone = option.tone;
    this.dialogueSpeakerText = '';
    this.dialogueTypewriterFull = option.response;
    this.dialogueTypewriterText = '';
    this.dialogueShowOptions = false;

    const oldMood: number = this.mood;
    this.mood = this.clamp(this.mood + option.effects.moodChange);
    this.dialogueAffinity += option.effects.affectionChange;
    if (option.effects.coinChange > 0) {
      this.coins += option.effects.coinChange;
    }
    this.dialogueCoinReward = option.effects.coinChange;

    let effects: string[] = [];
    if (option.effects.moodChange > 0) {
      effects.push('心情+' + option.effects.moodChange.toString());
    } else if (option.effects.moodChange < 0) {
      effects.push('心情' + option.effects.moodChange.toString());
    }
    if (option.effects.affectionChange > 0) {
      effects.push('好感+' + option.effects.affectionChange.toString());
    }
    if (option.effects.coinChange > 0) {
      effects.push('+' + option.effects.coinChange.toString() + '币');
    }
    if (effects.length > 0) {
      this.dialogueEffectText = effects.join('  ');
      this.dialogueEffectColor = option.effects.moodChange >= 0 ? '#FF8F9F' : '#F59A7A';
    }

    this.dialogueResponseDone = true;
    this.startTypewriter();
  }

  private onDialogueContinue(): void {
    const current: DialogueEntry | null = this.dialogueManager.getCurrentDialogue();
    if (current !== null && this.dialogueManager.getSession().currentOptionIndex >= 0) {
      const option: DialogueOption | null = current.options[this.dialogueManager.getSession().currentOptionIndex];
      if (option !== null && option.nextDialogueId !== null) {
        const next: DialogueEntry | null = this.dialogueManager.findNextDialogue(current.dialogueId, option);
        if (next !== null) {
          this.dialogueManager.endDialogue();
          this.startDialogueById(next.dialogueId);
          return;
        }
      }
    }
    this.closeDialogue();
  }

  private closeDialogue(): void {
    this.showDialogue = false;
    this.dialogueManager.endDialogue();
    if (this.dialogueTypewriterTimer !== -1) {
      clearInterval(this.dialogueTypewriterTimer);
      this.dialogueTypewriterTimer = -1;
    }
    this.dialogueEffectText = '';
    if (this.dialogueCoinReward > 0) {
      this.syncLocalChange('+' + this.dialogueCoinReward.toString() + '币  好感+' + this.dialogueAffinity.toString());
      this.dialogueCoinReward = 0;
    }
  }

  private triggerDdlDoneDialogue(): void {
    const ddlDoneEntry: DialogueEntry | null = this.dialogueManager.getDialogueById('doro_ddl_done_01');
    if (ddlDoneEntry !== null && this.dialogueManager.checkMoodBased !== undefined) {
      this.startDialogueById('doro_ddl_done_01');
    }
  }

  private triggerDdlOverdueDialogue(): void {
    this.startDialogueById('doro_ddl_overdue_01');
  }

  private getCatAffection(catId: string): number {
    const aff: CatAffection | undefined = this.catAffections[catId];
    if (aff !== undefined) {
      return aff.affection;
    }
    return 0;
  }

  private visitCat(catId: string): void {
    const aff: CatAffection | undefined = this.catAffections[catId];
    const today: string = new Date().getFullYear().toString() + '-' +
      (new Date().getMonth() + 1).toString() + '-' + new Date().getDate().toString();
    if (aff !== undefined) {
      if (aff.lastVisitDate !== today) {
        aff.affection = aff.affection + 2;
        if (aff.affection > 100) {
          aff.affection = 100;
        }
        aff.visitCount += 1;
        aff.lastVisitDate = today;
        const key: string = catId;
        this.catAffections[key] = aff;
        this.saveData();
      }
      this.selectedCatAffection = aff.affection;
      this.selectedCatVisitCount = aff.visitCount;
    }
    const cat: CatNPC | null = getCatById(catId);
    if (cat !== null) {
      this.selectedCat = cat;
      const todayNum: number = new Date().getDate();
      this.catGreetingText = getDailyDialogue(cat, this.selectedCatAffection, todayNum);
      this.catChatMessages = [];
      const now: Date = new Date();
      const time: string = this.pad(now.getHours()) + ':' + this.pad(now.getMinutes());
      this.catChatMessages.push(new ChatMessage(false, this.catGreetingText, time));
      this.catChatShowOptions = true;
      this.catChatDone = false;
      this.showCatDetail = true;
    }
  }

  private getCatResponseOptions(cat: CatNPC): string[] {
    const personality: string = cat.personality;
    if (personality === '焦虑') {
      return ['别担心，有我呢！', '今天天气超好的~', '摸摸头冷静一下'];
    }
    if (personality === '优雅') {
      return ['你今天也好优雅~', '请多指教！', '一起喝杯茶吧'];
    }
    if (personality === '佛系') {
      return ['醒醒！太阳晒屁股了', '你继续睡吧~', '要不要吃点什么？'];
    }
    if (personality === '严肃') {
      return ['今天也很自律呢！', '我马上去写计划！', '不要太严格啦~'];
    }
    if (personality === '害羞') {
      return ['你好可爱呀！', '不要怕，我不会伤害你的', '慢慢来不着急'];
    }
    if (personality === '话痨') {
      return ['然后呢然后呢？', '哈哈哈好好笑', '你听我说！'];
    }
    if (personality === '迷糊') {
      return ['你又忘了什么呀？', '我帮你找找！', '小迷糊最可爱了'];
    }
    if (personality === '暴躁') {
      return ['你好凶哦…', '给你顺顺毛~', '要不要一起玩游戏？'];
    }
    if (personality === '文艺') {
      return ['好有意境的话呀', '我也喜欢~', '今天灵感怎么样？'];
    }
    if (personality === '贪吃') {
      return ['带好吃的了！', '你又胖了哈哈哈', '一起吃吧~'];
    }
    if (personality === '傲娇') {
      return ['你也很可爱啦！', '我才不是在夸你~', '今天特别好看哦'];
    }
    if (personality === '温柔') {
      return ['你太暖了！', '今天也辛苦了~', '抱抱！'];
    }
    return ['你好呀！', '今天怎么样？', '一起加油吧~'];
  }

  private getCatResponseToOption(cat: CatNPC, optionIndex: number): string {
    const options: string[] = this.getCatResponseOptions(cat);
    const chosen: string = options[optionIndex];
    if (chosen.length === 0) {
      return '…嗯。';
    }
    if (cat.personality === '焦虑') {
      const replies: string[] = ['嗯…你这么说了我好像放心一点了…', '真的吗？那我信你一次！', '好…好，深呼吸…呼——'];
      return replies[Math.floor(Math.random() * replies.length)];
    }
    if (cat.personality === '优雅') {
      const replies: string[] = ['您过奖了…（优雅地点头）', '请坐，茶已经泡好了。', '和您聊天很愉快。'];
      return replies[Math.floor(Math.random() * replies.length)];
    }
    if (cat.personality === '佛系') {
      const replies: string[] = ['啊…好…（慢慢坐起来）', '嗯…我再躺五分钟…', '吃的？…也行吧…'];
      return replies[Math.floor(Math.random() * replies.length)];
    }
    if (cat.personality === '严肃') {
      const replies: string[] = ['嗯，继续保持。', '很好，有计划了吗？', '放松可以，但不能松懈。'];
      return replies[Math.floor(Math.random() * replies.length)];
    }
    if (cat.personality === '害羞') {
      const replies: string[] = ['！谢、谢谢…（脸红）', '好…好的…我慢慢来…', '你、你真好……'];
      return replies[Math.floor(Math.random() * replies.length)];
    }
    if (cat.personality === '话痨') {
      const replies: string[] = ['对吧对吧！我就知道你会感兴趣！', '还有还有！我还没说完呢！', '哈哈哈你懂我！'];
      return replies[Math.floor(Math.random() * replies.length)];
    }
    if (cat.personality === '迷糊') {
      const replies: string[] = ['诶？我刚刚说啥来着……', '哦对！谢谢你帮我找！', '嘿嘿…我是不是很麻烦…'];
      return replies[Math.floor(Math.random() * replies.length)];
    }
    if (cat.personality === '暴躁') {
      const replies: string[] = ['哼！我才不凶！', '别、别摸我头啦…', '打游戏？…行吧就陪你一会儿。'];
      return replies[Math.floor(Math.random() * replies.length)];
    }
    if (cat.personality === '文艺') {
      const replies: string[] = ['你也感受到那种情绪了吗…', '今天的风确实很适合这首诗。', '灵感像猫一样，强求不来的。'];
      return replies[Math.floor(Math.random() * replies.length)];
    }
    if (cat.personality === '贪吃') {
      const replies: string[] = ['真的吗！快给我尝尝！', '我才不胖！这是…毛茸茸！', '好啊好啊！吃什么！'];
      return replies[Math.floor(Math.random() * replies.length)];
    }
    if (cat.personality === '傲娇') {
      const replies: string[] = ['哼…你这么说我也不会高兴的！', '谁、谁要你夸了！', '今天…特地为我才穿这么好看的吗？'];
      return replies[Math.floor(Math.random() * replies.length)];
    }
    if (cat.personality === '温柔') {
      const replies: string[] = ['你也是我遇见过最温暖的人。', '累了就休息，我会一直在这里的。', '过来吧，给你一个抱抱~'];
      return replies[Math.floor(Math.random() * replies.length)];
    }
    return '…谢谢你来看我。';
  }

  private sendCatChatOption(optionIndex: number): void {
    if (this.selectedCat === null || this.catChatDone) {
      return;
    }
    const options: string[] = this.getCatResponseOptions(this.selectedCat);
    const chosenText: string = options[optionIndex];
    const now: Date = new Date();
    const time: string = this.pad(now.getHours()) + ':' + this.pad(now.getMinutes());
    this.catChatMessages.push(new ChatMessage(true, chosenText, time));
    this.catChatShowOptions = false;
    const reply: string = this.getCatResponseToOption(this.selectedCat, optionIndex);
    setTimeout(() => {
      const replyTime: string = this.pad(new Date().getHours()) + ':' + this.pad(new Date().getMinutes());
      this.catChatMessages.push(new ChatMessage(false, reply, replyTime));
      this.catChatDone = true;
      setTimeout(() => {
        this.closeCatDetail();
      }, 1500);
    }, 800);
  }

  private openBentoPicker(): void {
    this.showBentoPicker = true;
    this.bentoReactionText = '';
    this.bentoReactionEmoji = '';
  }

  private sendBento(catId: string, bentoId: string): void {
    const aff: CatAffection | undefined = this.catAffections[catId];
    if (aff === undefined) {
      return;
    }
    const now: number = Date.now();
    if (now - aff.lastGiftTime < 86400000) {
      this.bentoReactionText = '今天已经送过了哦~明天再来吧！';
      this.bentoReactionEmoji = '😴';
      this.showBentoResult = true;
      return;
    }
    const cat: CatNPC | null = getCatById(catId);
    if (cat === null) {
      return;
    }
    const bento: CatBento | null = getBentoById(bentoId);
    if (bento === null) {
      return;
    }
    if (this.coins < bento.price) {
      this.bentoReactionText = '三叶草币不够啦…先完成DDL攒钱吧！';
      this.bentoReactionEmoji = '😅';
      this.showBentoResult = true;
      return;
    }
    this.coins -= bento.price;

    let liked: boolean = false;
    let hated: boolean = false;
    for (let i: number = 0; i < cat.likedBento.length; i++) {
      if (cat.likedBento[i] === bento.name) {
        liked = true;
      }
    }
    for (let i: number = 0; i < cat.hatedBento.length; i++) {
      if (cat.hatedBento[i] === bento.name) {
        hated = true;
      }
    }

    let gain: number = 4;
    if (liked) {
      gain = 8;
    }
    if (hated) {
      gain = 1;
    }

    const oldLevel: string = getAffectionLevel(aff.affection);
    aff.affection = aff.affection + gain;
    if (aff.affection > 100) {
      aff.affection = 100;
    }
    aff.lastGiftTime = now;
    const catKey: string = catId;
    this.catAffections[catKey] = aff;
    this.selectedCatAffection = aff.affection;
    this.saveData();

    const result: BentoResult = getBentoReaction(cat, bento.name);
    this.bentoReactionText = result.text;
    this.bentoReactionEmoji = result.emoji;
    this.showBentoResult = true;
    this.catAffectionFloat = (gain > 0 ? '+' : '') + gain.toString();
    this.showBentoPicker = false;

    const newLevel: string = getAffectionLevel(aff.affection);
    if (newLevel !== oldLevel) {
      this.levelUpText = '你和' + cat.name + '的关系升级为【' + newLevel + '】啦！';
      this.showLevelUp = true;
      setTimeout(() => {
        this.showLevelUp = false;
        if (aff.affection >= 80) {
          for (let i: number = 0; i < aff.receivedGifts.length; i++) {
            if (aff.receivedGifts[i] === cat.giftName) {
              return;
            }
          }
          aff.receivedGifts.push(cat.giftName);
          const k: string = catId;
          this.catAffections[k] = aff;
          this.saveData();
          this.bentoReactionText = cat.name + '送给你【' + cat.giftName + '】作为挚友信物！' + cat.giftEmoji;
          this.bentoReactionEmoji = '🎁';
        }
      }, 1500);
    }
  }

  private closeCatDetail(): void {
    this.showCatDetail = false;
    this.selectedCat = null;
    this.showBentoResult = false;
  }

  private getSelectedCatEmoji(): string {
    if (this.selectedCat !== null) {
      return this.selectedCat.emoji;
    }
    return '🐱';
  }

  private getSelectedCatGiftEmoji(): string {
    if (this.selectedCat !== null) {
      return this.selectedCat.giftEmoji;
    }
    return '🎁';
  }

  private getSelectedCatReceivedGifts(): string[] {
    if (this.selectedCat !== null) {
      const aff: CatAffection | undefined = this.catAffections[this.selectedCat.id];
      if (aff !== undefined) {
        return aff.receivedGifts;
      }
    }
    return [];
  }

  @Builder
  PinkButton(label: string, color: string) {
    Button(label)
      .height(46)
      .fontSize(15)
      .fontWeight(FontWeight.Bold)
      .fontColor('#FFFFFF')
      .backgroundColor(color)
      .borderRadius(22)
      .shadow({ radius: 18, color: '#33FFB6C1', offsetX: 0, offsetY: 8 })
  }

  @Builder
  CardShell() {
    Column()
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFC')
      .borderRadius(22)
      .shadow({ radius: 22, color: '#22FF9EAF', offsetX: 0, offsetY: 8 })
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
  AuthFlow() {
    Column() {
      if (this.appStage === 0) {
        this.SplashAgreement()
      } else if (this.appStage === 1) {
        this.LoginPage()
      } else if (this.appStage === 2) {
        this.CreateNamePage()
      } else {
        this.HatchPage()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFF4F7')
  }

  @Builder
  SplashAgreement() {
    Column({ space: 20 }) {
      Blank()
      Text('Doro的约定')
        .fontSize(34)
        .fontWeight(FontWeight.Bold)
        .fontColor('#5A403A')
      Stack({ alignContent: Alignment.Center }) {
        Circle()
          .width(138)
          .height(138)
          .fill('#FFD9E2')
        Text('Doro')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FF7F95')
      }
      Text('和Doro一起打败拖延症吧~')
        .fontSize(16)
        .fontColor('#8D746D')
      Column({ space: 8 }) {
        Text('用户协议与隐私政策')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#5A403A')
        Text('继续使用表示你同意本地保存游戏数据，并在登录后同步到云端。后续可在“我的-隐私设置”中管理小镇拜访、在线状态和便当接收。')
          .fontSize(14)
          .fontColor('#76645F')
          .lineHeight(22)
      }
      .width('88%')
      .padding(18)
      .backgroundColor('#FFFFFC')
      .borderRadius(24)
      Button('同意并继续')
        .width('88%')
        .height(48)
        .fontColor('#FFFFFF')
        .fontWeight(FontWeight.Bold)
        .backgroundColor('#FF8F9F')
        .borderRadius(24)
        .onClick(() => {
          this.appStage = 1;
        })
      Blank()
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  LoginPage() {
    Column({ space: 16 }) {
      this.BrandHeader('Doro的约定', '粉色治愈系 DDL 养成游戏')
      Stack({ alignContent: Alignment.Center }) {
        Circle()
          .width(120)
          .height(120)
          .fill('#FFE1EA')
        Text('云朵上的Doro')
          .fontSize(16)
          .fontColor('#C56D7C')
      }
      .height(140)
      .width('100%')

      Column({ space: 12 }) {
        Button('手机号一键登录')
          .width('100%')
          .height(50)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
          .backgroundColor('#FF8F9F')
          .borderRadius(24)
          .onClick(() => {
            this.appStage = 2;
          })
        Button('Apple ID 登录')
          .width('100%')
          .height(46)
          .fontColor('#5A403A')
          .backgroundColor('#FFF3F6')
          .borderRadius(23)
          .onClick(() => {
            this.appStage = 2;
          })
        Button('Google / 微信 / 邮箱 更多选项')
          .width('100%')
          .height(46)
          .fontColor('#5A403A')
          .backgroundColor('#F7F0FF')
          .borderRadius(23)
          .onClick(() => {
            this.appStage = 2;
          })
        Text('已有账号？去登录   没有账号？去注册')
          .fontSize(13)
          .fontColor('#9B7D76')
      }
      .width('88%')
      .padding(18)
      .backgroundColor('#FFFFFC')
      .borderRadius(24)
      .shadow({ radius: 24, color: '#22FF9EAF', offsetX: 0, offsetY: 8 })
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  CreateNamePage() {
    Column({ space: 18 }) {
      this.BrandHeader('创建名字', 'Doro会用这个名字记住你')
      Column({ space: 12 }) {
        TextInput({ placeholder: '输入用户名', text: this.username })
          .height(48)
          .fontSize(15)
          .backgroundColor('#FFF4F7')
          .borderRadius(22)
          .onChange((value: string) => this.checkUsername(value))
        Text(this.usernameHint)
          .width('100%')
          .fontSize(13)
          .fontColor(this.usernameHint === '这个名字可以使用' ? '#79B58F' : '#9B7D76')
        Button('想不出名字？让Doro帮你取一个~')
          .width('100%')
          .height(44)
          .fontColor('#5A403A')
          .backgroundColor('#F8EFFF')
          .borderRadius(22)
          .onClick(() => this.nextNickname())
        Button('确认，开始破壳')
          .width('100%')
          .height(48)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
          .backgroundColor('#FF8F9F')
          .borderRadius(24)
          .onClick(() => this.confirmUsername())
      }
      .width('88%')
      .padding(18)
      .backgroundColor('#FFFFFC')
      .borderRadius(24)
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  HatchPage() {
    Column({ space: 18 }) {
      Blank()
      Stack({ alignContent: Alignment.Center }) {
        Circle()
          .width(178)
          .height(178)
          .fill('#FFD9E2')
        Circle()
          .width(126)
          .height(126)
          .fill('#FFF9F4')
        Text('破壳啦')
          .fontSize(27)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FF7F95')
      }
      Text(this.doroWords)
        .width('82%')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#5A403A')
        .textAlign(TextAlign.Center)
        .lineHeight(28)
      Text('初始性格：认真但爱撒娇 · 花纹：樱花粉 · 眼睛：蜜糖棕')
        .width('82%')
        .fontSize(14)
        .fontColor('#8D746D')
        .textAlign(TextAlign.Center)
        .lineHeight(22)
      Button('进入家园')
        .width('82%')
        .height(48)
        .fontColor('#FFFFFF')
        .fontWeight(FontWeight.Bold)
        .backgroundColor('#FF8F9F')
        .borderRadius(24)
        .onClick(() => {
          this.appStage = 4;
        })
      Blank()
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  TopStatus() {
    Column({ space: 8 }) {
      Row({ space: 10 }) {
        this.MiniMeter('心情', this.mood, '#FF8F9F')
        this.MiniMeter('饱腹', this.satiety, '#8BC8A5')
        Text(`${this.coins} 叶`)
          .height(36)
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor('#8A5A4F')
          .padding({ left: 13, right: 13 })
          .backgroundColor('#FFF0C9')
          .borderRadius(18)
      }
      if (this.feedback.length > 0) {
        Text(this.feedback)
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FF6F87')
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor('#FFFFFC')
          .borderRadius(16)
      }
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
          .fontColor('#7D6862')
        Text(`${value}`)
          .fontSize(11)
          .fontWeight(FontWeight.Bold)
          .fontColor(color)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      Progress({ value, total: 100, type: ProgressType.Linear })
        .height(7)
        .width('100%')
        .color(color)
        .backgroundColor('#F3DDE3')
    }
    .height(38)
    .layoutWeight(1)
    .padding({ left: 10, right: 10, top: 5, bottom: 5 })
    .backgroundColor('#FFFFFC')
    .borderRadius(18)
  }

  @Builder
  DoroScene(mode: string) {
    Stack({ alignContent: Alignment.Center }) {
      Column() {
        Row() {
          Text('沙发')
            .fontSize(15)
            .fontColor('#AD7A72')
          Blank()
          Text('绿植')
            .fontSize(15)
            .fontColor('#79B58F')
          Blank()
          Text('相框')
            .fontSize(15)
            .fontColor('#9B7DCE')
        }
        .width('78%')
        .margin({ bottom: 18 })

        Stack({ alignContent: Alignment.Center }) {
          Circle()
            .width(mode === 'focus' ? 138 : 176)
            .height(mode === 'focus' ? 138 : 176)
            .fill('#FFD9E2')
          Circle()
            .width(mode === 'focus' ? 104 : 132)
            .height(mode === 'focus' ? 104 : 132)
            .fill('#FFF9F4')
          Column({ space: 5 }) {
            Text('Doro')
              .fontSize(mode === 'focus' ? 24 : 31)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FF7F95')
            Text(mode === 'focus' ? '安静陪伴中' : '图片占位')
              .fontSize(12)
              .fontColor('#AD7A72')
          }
        }
        .onClick(() => this.touchDoro())

        Row({ space: 8 }) {
          Text('花瓣')
            .fontSize(12)
            .fontColor('#C08490')
          Text('星星')
            .fontSize(12)
            .fontColor('#C08490')
          Text('光点')
            .fontSize(12)
            .fontColor('#C08490')
        }
        .margin({ top: 18 })
      }
    }
    .height(mode === 'home' ? 360 : 246)
    .width('100%')
    .backgroundColor(mode === 'focus' ? '#FFF0F5' : '#FFEAF0')
    .borderRadius(24)
    .shadow({ radius: 24, color: '#26FF9EAF', offsetX: 0, offsetY: 10 })
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
              .height(48)
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Bold)
              .backgroundColor('#FF8F9F')
              .borderRadius(24)
              .onClick(() => this.feedDoro())
            Button('抚摸')
              .layoutWeight(1)
              .height(48)
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Bold)
              .backgroundColor('#BBA6E8')
              .borderRadius(24)
              .onClick(() => this.touchDoro())
            Button('装扮')
              .layoutWeight(1)
              .height(48)
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Bold)
              .backgroundColor('#8BC8A5')
              .borderRadius(24)
              .onClick(() => this.dressDoro())
            Button('对话')
              .layoutWeight(1)
              .height(48)
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Bold)
              .backgroundColor('#F5A6C8')
              .borderRadius(24)
              .onClick(() => this.checkAndTriggerDialogue())
          }
          this.SpeechCard()
          Row({ space: 10 }) {
            this.HomeStat('舒适度', `${this.comfort} 星`, '#BBA6E8')
            this.HomeStat('待办DDL', `${this.pendingCount()} 个`, '#FF8F9F')
            this.HomeStat('逾期', `${this.overdueCount()} 个`, '#F59A7A')
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
  SpeechCard() {
    Column({ space: 8 }) {
      Text('Doro说')
        .fontSize(12)
        .fontColor('#9B7D76')
      Text(`“${this.doroWords}”`)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#5A403A')
        .lineHeight(27)
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .padding(18)
    .backgroundColor('#FFFFFC')
    .borderRadius(22)
    .shadow({ radius: 18, color: '#22FF9EAF', offsetX: 0, offsetY: 6 })
  }

  @Builder
  HomeStat(label: string, value: string, color: string) {
    Column({ space: 6 }) {
      Text(label)
        .fontSize(12)
        .fontColor('#9B7D76')
      Text(value)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
    }
    .alignItems(HorizontalAlign.Start)
    .layoutWeight(1)
    .padding(14)
    .backgroundColor('#FFFFFC')
    .borderRadius(20)
  }

  @Builder
  DdlPage() {
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
            this.newTitle = value;
          })
      } else if (this.ddlStep === 1) {
        TextInput({ placeholder: '2026-07-21 14:00', text: this.newDeadline })
          .height(46)
          .backgroundColor('#FFF4F7')
          .borderRadius(22)
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
            .fontColor('#7D6862')
            .lineHeight(22)
        }
      } else {
        Column({ space: 8 }) {
          Text('契约成立')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#8A5A4F')
          Text(`你承诺在 ${this.newDeadline} 前完成“${this.newTitle.length > 0 ? this.newTitle : '未命名DDL'}”。`)
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
      Row({ space: 10 }) {
        Button('上一步')
          .layoutWeight(1)
          .height(42)
          .enabled(this.ddlStep > 0)
          .fontColor('#7D6862')
          .backgroundColor('#FFF4F7')
          .borderRadius(21)
          .onClick(() => {
            if (this.ddlStep > 0) {
              this.ddlStep -= 1;
            }
          })
        Button(this.ddlStep === 3 ? '我承诺' : '下一步')
          .layoutWeight(1)
          .height(42)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
          .backgroundColor('#FF8F9F')
          .borderRadius(21)
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
        .fontColor(overdueOnly ? '#F59A7A' : '#5A403A')
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
            .onClick(() => this.finishTask(task.id))
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

  @Builder
  FocusPage() {
    Scroll() {
      Column({ space: 16 }) {
        this.BrandHeader('专注花园', this.getFocusSubtitle())

        Column({ space: 8 }) {
          Text('选择时长')
            .width('100%')
            .fontSize(13)
            .fontColor('#9B7D76')
          Slider({
            value: this.focusSliderValue,
            min: 1,
            max: 180,
            step: 1,
            style: SliderStyle.OutSet
          })
            .width('100%')
            .onChange((value: number) => {
              this.focusSliderValue = value;
              const mins: number = Math.round(value);
              this.focusDuration = mins;
              this.focusSecondsLeft = mins * 60;
            })
          Row({ space: 6 }) {
            Text(Math.floor(this.focusSliderValue / 60).toString() + ' 时')
              .fontSize(14)
              .fontColor('#5A403A')
            Text((Math.round(this.focusSliderValue) % 60).toString() + ' 分')
              .fontSize(14)
              .fontColor('#FF7F95')
            Text('共 ' + Math.round(this.focusSliderValue).toString() + ' 分钟')
              .fontSize(13)
              .fontColor('#9B7D76')
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
        }
        .width('100%')

        Column({ space: 8 }) {
          Text('关联DDL')
            .width('100%')
            .fontSize(13)
            .fontColor('#9B7D76')
          Button(this.selectedTaskTitle())
            .width('100%')
            .height(44)
            .fontColor('#5A403A')
            .backgroundColor('#FFFFFC')
            .borderRadius(22)
            .onClick(() => {
              if (this.timerId === -1) {
                this.showDdlPicker = true;
              }
            })
          if (this.selectedTaskId === -1) {
            TextInput({ placeholder: '输入专注名称...', text: this.focusCustomName })
              .height(42)
              .fontSize(14)
              .backgroundColor('#FFF4F7')
              .borderRadius(21)
              .onChange((value: string) => {
                this.focusCustomName = value;
              })
          }
        }
        .width('100%')

        Text(this.formatTime(this.focusSecondsLeft))
          .width('100%')
          .height(118)
          .textAlign(TextAlign.Center)
          .fontSize(52)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FF7F95')
          .backgroundColor('#FFFFFC')
          .borderRadius(24)
        this.DoroScene('focus')
        Row({ space: 10 }) {
          Button(this.focusRunning ? '暂停专注' : '开始专注')
            .layoutWeight(1)
            .height(48)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
            .backgroundColor('#FF8F9F')
            .borderRadius(24)
            .onClick(() => this.toggleFocus())
          Button('重置')
            .layoutWeight(1)
            .height(48)
            .fontColor('#5A403A')
            .fontWeight(FontWeight.Bold)
            .backgroundColor('#FFFFFC')
            .borderRadius(24)
            .onClick(() => this.resetFocus())
        }
        Text('今日累计：' + this.focusMinutesToday.toString() + '分钟 · 番茄钟 ' + this.focusCount.toString() + ' 个')
          .fontSize(14)
          .fontColor('#9B7D76')
          .width('100%')
          .textAlign(TextAlign.Center)
      }
      .padding(16)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  FeedPickerOverlay() {
    Column() {
      Column({ space: 14 }) {
        Text('选择食物')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#5A403A')
        ForEach(this.foods, (item: InventoryItem, index: number) => {
          Column({ space: 6 }) {
            Row() {
              Text(item.name)
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#5A403A')
              Blank()
              Text('x' + item.count.toString())
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor(item.count > 0 ? '#FF7F95' : '#CBBFBC')
            }
            .width('100%')
            Text(item.desc)
              .fontSize(13)
              .fontColor('#9B7D76')
              .lineHeight(20)
            Button('喂食')
              .width('100%')
              .height(40)
              .fontSize(14)
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Bold)
              .backgroundColor(item.count > 0 ? '#FF8F9F' : '#CBBFBC')
              .borderRadius(20)
              .enabled(item.count > 0)
              .onClick(() => this.feedWithItem(index))
          }
          .width('100%')
          .padding(14)
          .backgroundColor('#FFF8FA')
          .borderRadius(18)
        }, (item: InventoryItem) => 'feed-' + item.name)
        Button('取消')
          .width('100%')
          .height(42)
          .fontColor('#7D6862')
          .backgroundColor('#FFF4F7')
          .borderRadius(21)
          .onClick(() => {
            this.showFeedPicker = false;
          })
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
  DressPickerOverlay() {
    Column() {
      Column({ space: 14 }) {
        Text('选择装扮')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#5A403A')
        ForEach(this.outfits, (item: InventoryItem, index: number) => {
          Column({ space: 6 }) {
            Row() {
              Text(item.name)
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#5A403A')
              Blank()
              Text('x' + item.count.toString())
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor(item.count > 0 ? '#FF7F95' : '#CBBFBC')
            }
            .width('100%')
            Text(item.desc)
              .fontSize(13)
              .fontColor('#9B7D76')
              .lineHeight(20)
            Button('穿戴')
              .width('100%')
              .height(40)
              .fontSize(14)
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Bold)
              .backgroundColor(item.count > 0 ? '#BBA6E8' : '#CBBFBC')
              .borderRadius(20)
              .enabled(item.count > 0)
              .onClick(() => this.dressWithItem(index))
          }
          .width('100%')
          .padding(14)
          .backgroundColor('#FFF8FA')
          .borderRadius(18)
        }, (item: InventoryItem) => 'dress-' + item.name)
        Button('取消')
          .width('100%')
          .height(42)
          .fontColor('#7D6862')
          .backgroundColor('#FFF4F7')
          .borderRadius(21)
          .onClick(() => {
            this.showDressPicker = false;
          })
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
  FocusCompleteOverlay() {
    Column() {
      Column({ space: 16 }) {
        Text('时间到！专注完成')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#5A403A')
        Text('本次专注：' + this.focusDuration.toString() + '分钟')
          .fontSize(14)
          .fontColor('#8D746D')
        if (this.selectedTaskId !== -1) {
          Row({ space: 8 }) {
            Toggle({ type: ToggleType.Checkbox, isOn: this.focusMarkDdlDone })
              .onChange((value: boolean) => {
                this.focusMarkDdlDone = value;
              })
            Text('标记该DDL为完成')
              .fontSize(14)
              .fontColor('#5A403A')
          }
          .width('100%')
          .padding({ left: 8 })
        }
        Row({ space: 10 }) {
          Button('继续专注 5 分')
            .layoutWeight(1)
            .height(44)
            .fontSize(13)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
            .backgroundColor('#BBA6E8')
            .borderRadius(22)
            .onClick(() => this.continueFocus(5))
          Button('继续专注 10 分')
            .layoutWeight(1)
            .height(44)
            .fontSize(13)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
            .backgroundColor('#BBA6E8')
            .borderRadius(22)
            .onClick(() => this.continueFocus(10))
        }
        Button('结束专注')
          .width('100%')
          .height(48)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
          .backgroundColor('#FF8F9F')
          .borderRadius(24)
          .onClick(() => this.endFocusSession())
        Text('数据已同步')
          .fontSize(12)
          .fontColor('#8BC8A5')
      }
      .width('88%')
      .padding(24)
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
  DdlPickerOverlay() {
    Column() {
      Column({ space: 10 }) {
        Text('选择关联DDL')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#5A403A')
        Scroll() {
          Column({ space: 8 }) {
            ForEach(this.tasks.filter((task: DdlTask) => !task.done), (task: DdlTask) => {
              Button(task.title)
                .width('100%')
                .height(42)
                .fontSize(14)
                .fontColor(this.selectedTaskId === task.id ? '#FFFFFF' : '#5A403A')
                .backgroundColor(this.selectedTaskId === task.id ? '#FF8F9F' : '#FFF4F7')
                .borderRadius(21)
                .onClick(() => this.selectDdlForFocus(task.id))
            }, (task: DdlTask) => 'ddl-' + task.id.toString())
            Button('自定义专注（无DDL）')
              .width('100%')
              .height(42)
              .fontSize(14)
              .fontColor(this.selectedTaskId === -1 ? '#FFFFFF' : '#5A403A')
              .backgroundColor(this.selectedTaskId === -1 ? '#FF8F9F' : '#FFF4F7')
              .borderRadius(21)
              .onClick(() => this.selectDdlForFocus(-1))
            if (this.selectedTaskId === -1) {
              TextInput({ placeholder: '输入专注名称...', text: this.focusCustomName })
                .height(42)
                .fontSize(14)
                .backgroundColor('#FFF4F7')
                .borderRadius(21)
                .onChange((value: string) => {
                  this.focusCustomName = value;
                })
            }
          }
          .width('100%')
        }
        .layoutWeight(1)
        .width('100%')
        Button('关闭')
          .width('100%')
          .height(42)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
          .backgroundColor('#FF8F9F')
          .borderRadius(21)
          .onClick(() => {
            this.showDdlPicker = false;
          })
      }
      .width('88%')
      .constraintSize({ maxHeight: '70%' })
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
  ShopAsOverlay() {
    Column() {
      Column({ space: 14 }) {
        Row() {
          Button('关闭')
            .width(76)
            .height(36)
            .fontSize(12)
            .fontColor('#7D6862')
            .backgroundColor('#FFF4F7')
            .borderRadius(18)
            .onClick(() => {
              this.showShop = false;
            })
          Text('商店')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#5A403A')
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
          Blank()
            .width(76)
        }
        .width('100%')
        Row({ space: 8 }) {
          this.ShopTab('食物', 0)
          this.ShopTab('装扮', 1)
          this.ShopTab('家具', 2)
        }
        .padding({ left: 4, right: 4 })
        Text('当前余额：' + this.coins.toString() + ' 三叶草币')
          .width('100%')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FF7F95')
          .textAlign(TextAlign.Center)
        Scroll() {
          Column({ space: 12 }) {
            ForEach(this.shopItems.filter((item: ShopItem) => {
              if (this.shopTab === 0) {
                return item.category === 'food';
              }
              if (this.shopTab === 1) {
                return item.category === 'outfit';
              }
              return item.category === 'furniture';
            }), (item: ShopItem, index: number) => {
              this.ShopCard(item, index)
            }, (item: ShopItem) => 'shop-' + item.name)
          }
          .width('100%')
        }
        .layoutWeight(1)
        .width('100%')
      }
      .width('88%')
      .constraintSize({ maxHeight: '80%' })
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
  ShopTab(label: string, index: number) {
    Button(label)
      .layoutWeight(1)
      .height(38)
      .fontSize(13)
      .fontColor(this.shopTab === index ? '#FFFFFF' : '#7D6862')
      .backgroundColor(this.shopTab === index ? '#FF8F9F' : '#FFFFFC')
      .borderRadius(19)
      .onClick(() => {
        this.shopTab = index;
      })
  }

  @Builder
  ShopCard(item: ShopItem, globalIndex: number) {
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
            .lineHeight(20)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        Column({ space: 4 }) {
          Text(item.price.toString() + ' 币')
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF7F95')
          Button('购买')
            .height(32)
            .fontSize(12)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
            .backgroundColor(this.coins >= item.price ? '#FF8F9F' : '#CBBFBC')
            .borderRadius(16)
            .enabled(this.coins >= item.price)
            .onClick(() => {
              const idx: number = this.shopItems.indexOf(item);
              this.buyShopItem(idx);
            })
        }
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      if (item.category === 'food') {
        Text('效果：饱腹+' + item.satietyEffect.toString() + '  心情+' + item.moodEffect.toString())
          .fontSize(12)
          .fontColor('#8BC8A5')
          .width('100%')
      }
      if (item.category === 'outfit') {
        Text('效果：心情+' + item.moodEffect.toString())
          .fontSize(12)
          .fontColor('#BBA6E8')
          .width('100%')
      }
    }
    .width('100%')
    .padding(14)
    .backgroundColor('#FFFFFC')
    .borderRadius(20)
  }

  @Builder
  SearchFriendOverlay() {
    Column() {
      Column({ space: 14 }) {
        Text('搜索添加好友')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#5A403A')
        TextInput({ placeholder: '输入好友用户名...', text: this.searchKeyword })
          .height(42)
          .fontSize(14)
          .backgroundColor('#FFF4F7')
          .borderRadius(21)
          .onChange((value: string) => {
            this.searchKeyword = value;
          })
        Button('搜索')
          .width('100%')
          .height(42)
          .fontSize(14)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
          .backgroundColor('#FF8F9F')
          .borderRadius(21)
          .onClick(() => this.searchFriends())
        if (this.searchKeyword.length > 0 && this.searchResults.length === 0) {
          Text('未找到相关用户')
            .fontSize(14)
            .fontColor('#9B7D76')
            .width('100%')
            .textAlign(TextAlign.Center)
        }
        ForEach(this.searchResults, (user: FriendInfo) => {
          Row() {
            Column({ space: 2 }) {
              Text(user.name)
                .fontSize(15)
                .fontWeight(FontWeight.Bold)
                .fontColor('#5A403A')
              Text(user.doroName)
                .fontSize(12)
                .fontColor('#9B7D76')
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
            Button('添加好友')
              .height(34)
              .fontSize(12)
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Bold)
              .backgroundColor('#8BC8A5')
              .borderRadius(17)
              .onClick(() => this.addFriend(user.id))
          }
          .width('100%')
          .padding(12)
          .backgroundColor('#FFF8FA')
          .borderRadius(16)
        }, (user: FriendInfo) => 'search-' + user.id.toString())
        Button('关闭')
          .width('100%')
          .height(42)
          .fontColor('#7D6862')
          .backgroundColor('#FFF4F7')
          .borderRadius(21)
          .onClick(() => {
            this.showFriendSearch = false;
          })
      }
      .width('88%')
      .constraintSize({ maxHeight: '75%' })
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

  private getChatName(): string {
    const target: FriendInfo | undefined = this.friends.find((f: FriendInfo) => f.id === this.chatTargetId);
    return target !== undefined ? target.name : '聊天';
  }

  @Builder
  ChatView() {
    Column({ space: 10 }) {
      Row() {
        Button('返回')
          .width(76)
          .height(36)
          .fontSize(12)
          .fontColor('#7D6862')
          .backgroundColor('#FFF4F7')
          .borderRadius(18)
          .onClick(() => {
            this.showChat = false;
          })
        Text(this.getChatName())
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#5A403A')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Blank()
          .width(76)
      }
      .width('100%')
      .padding({ bottom: 8 })
      Scroll() {
        Column({ space: 8 }) {
          if (this.friendChatHistory.length === 0) {
            Text('开始和' + this.getChatName() + '聊天吧~')
              .fontSize(14)
              .fontColor('#9B7D76')
              .width('100%')
              .textAlign(TextAlign.Center)
              .margin({ top: 30 })
          }
          ForEach(this.friendChatHistory, (msg: ChatMessage) => {
            Row() {
              if (msg.fromMe) {
                Blank()
              }
              Column({ space: 4 }) {
                Text(msg.text)
                  .fontSize(15)
                  .fontColor(msg.fromMe ? '#FFFFFF' : '#5A403A')
                  .padding({ left: 14, right: 14, top: 10, bottom: 10 })
                  .backgroundColor(msg.fromMe ? '#FF8F9F' : '#FFFFFC')
                  .borderRadius(18)
                Text(msg.time)
                  .fontSize(11)
                  .fontColor('#CBBFBC')
              }
              .alignItems(msg.fromMe ? HorizontalAlign.End : HorizontalAlign.Start)
              .constraintSize({ maxWidth: '80%' })
              if (!msg.fromMe) {
                Blank()
              }
            }
            .width('100%')
            .justifyContent(msg.fromMe ? FlexAlign.End : FlexAlign.Start)
          }, (msg: ChatMessage, idx: number) => 'msg-' + idx.toString())
        }
        .width('100%')
      }
      .layoutWeight(1)
      .width('100%')
      Row({ space: 8 }) {
        TextInput({ placeholder: '输入消息...', text: this.chatInputText })
          .layoutWeight(1)
          .height(44)
          .fontSize(14)
          .backgroundColor('#FFF4F7')
          .borderRadius(22)
          .onChange((value: string) => {
            this.chatInputText = value;
          })
        Button('发送')
          .height(44)
          .fontSize(14)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
          .backgroundColor('#FF8F9F')
          .borderRadius(22)
          .padding({ left: 20, right: 20 })
          .onClick(() => this.sendMessage())
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  BagPage() {
    Column({ space: 12 }) {
      this.BrandHeader('背包', '装扮、食物与家具')
      Row({ space: 8 }) {
        this.BagTab('装扮', 0)
        this.BagTab('食物', 1)
        this.BagTab('家具', 2)
      }
      .padding({ left: 16, right: 16 })
      Scroll() {
        Column({ space: 12 }) {
          if (this.bagTab === 0) {
            this.InventoryList(this.outfits, false)
          } else if (this.bagTab === 1) {
            this.InventoryList(this.foods, true)
          } else {
            this.InventoryList(this.furnitures, false)
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
      .height(38)
      .fontSize(12)
      .fontColor(this.bagTab === index ? '#FFFFFF' : '#7D6862')
      .backgroundColor(this.bagTab === index ? '#FF8F9F' : '#FFFFFC')
      .borderRadius(19)
      .onClick(() => {
        this.bagTab = index;
      })
  }

  @Builder
  InventoryList(items: InventoryItem[], canUse: boolean) {
    ForEach(items, (item: InventoryItem, index: number) => {
      Row() {
        Column({ space: 6 }) {
          Text(item.name)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#5A403A')
          Text(item.desc)
            .fontSize(13)
            .fontColor('#9B7D76')
            .lineHeight(20)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        if (canUse) {
          Button(`用 x${item.count}`)
            .width(78)
            .height(34)
            .fontSize(12)
            .fontColor('#FFFFFF')
            .backgroundColor(item.count > 0 ? '#FF8F9F' : '#CBBFBC')
            .borderRadius(17)
            .onClick(() => this.useFood(index))
        } else {
          Text(`x${item.count}`)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(item.count > 0 ? '#FF7F95' : '#CBBFBC')
        }
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFC')
      .borderRadius(22)
    }, (item: InventoryItem) => item.name)
  }

  @Builder
  UserCenter() {
    Column({ space: 12 }) {
      this.UserRow('用户名', this.username.length > 0 ? this.username : '游客玩家')
      this.UserRow('Doro名字', this.doroName)
      this.UserRow('小镇门牌号', 'Pink-0719')
      this.UserRow('最后同步', `本地版本 v${this.syncVersion} · 等待云端同步`)
      this.UserRow('隐私设置', '允许拜访：开 · 在线状态：关 · 接收便当：开')
      this.MemoryNode('相遇之日', 'Doro 破壳而出，认真记住了你的名字。', true)
      this.MemoryNode('第一次提前完成', 'Doro 开心得翻了一圈，送你 18 枚三叶草币。', true)
      Button('手动同步')
        .width('100%')
        .height(44)
        .fontColor('#FFFFFF')
        .fontWeight(FontWeight.Bold)
        .backgroundColor('#BBA6E8')
        .borderRadius(22)
        .onClick(() => {
          this.feedback = '已发起云端同步';
          this.syncVersion += 1;
        })
    }
    .width('100%')
  }

  @Builder
  UserRow(label: string, value: string) {
    Column({ space: 6 }) {
      Text(label)
        .fontSize(12)
        .fontColor('#9B7D76')
      Text(value)
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor('#5A403A')
        .lineHeight(22)
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFC')
    .borderRadius(22)
  }

  @Builder
  MemoryNode(title: string, desc: string, milestone: boolean) {
    Column({ space: 6 }) {
      Text(title)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(milestone ? '#8A5A4F' : '#5A403A')
      Text(desc)
        .fontSize(13)
        .fontColor('#9B7D76')
        .lineHeight(20)
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .padding(16)
    .backgroundColor(milestone ? '#FFF0C9' : '#FFFFFC')
    .borderRadius(22)
    .border({ width: milestone ? 1 : 0, color: '#F3C46D' })
  }

  @Builder
  IconBtn(label: string) {
    Text(label)
      .fontSize(11)
      .fontColor('#9B7D76')
      .padding({ left: 10, right: 10, top: 5, bottom: 5 })
      .backgroundColor('#FFF4F7')
      .borderRadius(14)
  }

  @Builder
  ToolItem(label: string, index: number) {
    Stack() {
      Column({ space: 2 }) {
        Text(label)
          .fontSize(12)
          .fontWeight(this.activeTab === index ? FontWeight.Bold : FontWeight.Regular)
          .fontColor(this.activeTab === index ? '#FFFFFF' : '#9B7D76')
      }
      .height(50)
      .justifyContent(FlexAlign.Center)
      .padding({ left: 12, right: 12 })
      .backgroundColor(this.activeTab === index ? '#FF8F9F' : '#00000000')
      .borderRadius(16)
      .onClick(() => {
        this.activeTab = index;
        this.feedback = '';
      })
      if ((index === 1 && this.pendingCount() > 0)) {
        Circle()
          .width(8)
          .height(8)
          .fill('#FF4757')
          .align(Alignment.TopEnd)
          .offset({ x: -2, y: 2 })
      }
    }
  }

  @Builder
  TopInfoBar() {
    Column() {
      Row() {
        Circle()
          .width(40)
          .height(40)
          .fill('#FFD9E2')
          .onClick(() => {
            this.profileName = this.username;
            this.showProfile = true;
          })
        Column({ space: 3 }) {
          Text(this.username.length > 0 ? this.username : '玩家')
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .fontColor('#5A403A')
          Row({ space: 6 }) {
            Text('Lv.' + this.calcLevel().toString())
              .fontSize(11)
              .fontColor('#FF7F95')
            Progress({ value: this.calcExpProgress(), total: 5, type: ProgressType.Linear })
              .height(5)
              .width(64)
              .color('#FF8F9F')
              .backgroundColor('#F3DDE3')
          }
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 8 })
        .layoutWeight(1)
        Row({ space: 8 }) {
          Text(this.coins.toString() + ' 叶')
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor('#8A5A4F')
            .padding({ left: 10, right: 10, top: 4, bottom: 4 })
            .backgroundColor('#FFF0C9')
            .borderRadius(14)
          Text(this.gems.toString() + ' 钻')
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor('#7C6FCB')
            .padding({ left: 10, right: 10, top: 4, bottom: 4 })
            .backgroundColor('#F3EFFF')
            .borderRadius(14)
        }
      }
      .width('100%')
      .padding({ top: 6, bottom: 6 })
      Row({ space: 6 }) {
        this.IconBtn('设置')
        this.IconBtn('音效')
        this.IconBtn('更多')
        Blank()
          .layoutWeight(1)
        Stack() {
          Text('商城')
            .fontSize(12)
            .fontColor('#FFFFFF')
            .padding({ left: 12, right: 12, top: 5, bottom: 5 })
            .backgroundColor('#FF8F9F')
            .borderRadius(14)
          if (this.hasEventUpdate) {
            Circle()
              .width(8)
              .height(8)
              .fill('#FF4757')
              .align(Alignment.TopEnd)
              .offset({ x: 4, y: -4 })
          }
        }
        .onClick(() => {
          this.showShop = true;
        })
        Stack() {
          Text('活动')
            .fontSize(12)
            .fontColor('#FFFFFF')
            .padding({ left: 12, right: 12, top: 5, bottom: 5 })
            .backgroundColor('#BBA6E8')
            .borderRadius(14)
          if (this.hasEventUpdate) {
            Circle()
              .width(8)
              .height(8)
              .fill('#FF4757')
              .align(Alignment.TopEnd)
              .offset({ x: 4, y: -4 })
          }
        }
        .onClick(() => {
          this.doroWords = '活动功能即将上线，敬请期待！';
        })
      }
      .width('100%')
    }
    .width('100%')
    .padding({ left: 14, right: 14, top: 8, bottom: 6 })
    .backgroundColor('#FFFFFC')
    .borderRadius({ topLeft: 0, topRight: 0, bottomLeft: 20, bottomRight: 20 })
    .shadow({ radius: 14, color: '#18FF9EAF', offsetX: 0, offsetY: 4 })
  }

  @Builder
  BottomToolbar() {
    Row({ space: 4 }) {
      this.ToolItem('家园', 0)
      this.ToolItem('任务', 1)
      this.ToolItem('专注', 2)
      this.ToolItem('背包', 3)
      this.ToolItem('猫猫', 4)
    }
    .width('100%')
    .height(62)
    .padding({ left: 6, right: 6, top: 4, bottom: 4 })
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#FFFFFC')
    .borderRadius(22)
    .shadow({ radius: 16, color: '#22FF9EAF', offsetX: 0, offsetY: -4 })
    .margin({ left: 10, right: 10, bottom: 20 })
  }

  @Builder
  CatListPage() {
    Column({ space: 10 }) {
      Text('🐱 猫猫好友')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor('#5A403A')
        .width('100%')
        .padding({ left: 4, top: 8 })
      Text('小镇上有12只性格各异的猫咪在等你认识~')
        .fontSize(13)
        .fontColor('#9B7D76')
        .width('100%')
        .padding({ left: 4 })
      Scroll() {
        Column({ space: 8 }) {
          ForEach(ALL_CATS, (cat: CatNPC) => {
            Column() {
              Row({ space: 10 }) {
                Text(cat.emoji)
                  .fontSize(30)
                  .opacity(isCatAwake(cat) ? 1.0 : 0.5)
                Column({ space: 3 }) {
                  Row({ space: 6 }) {
                    Text(cat.name)
                      .fontSize(16)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(isCatAwake(cat) ? '#5A403A' : '#CBBFBC')
                    Text('#' + cat.personality)
                      .fontSize(11)
                      .fontColor('#FFFFFF')
                      .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                      .backgroundColor(isCatAwake(cat) ? '#BBA6E8' : '#DDBFBC')
                      .borderRadius(10)
                  }
                  Row({ space: 6 }) {
                    Text(getAffectionLevelEmoji(getAffectionLevel(this.getCatAffection(cat.id))) + ' ' + getAffectionLevel(this.getCatAffection(cat.id)))
                      .fontSize(12)
                      .fontColor(getAffectionColor(this.getCatAffection(cat.id)))
                    Progress({ value: this.getCatAffection(cat.id), total: 100, type: ProgressType.Linear })
                      .height(5)
                      .width(80)
                      .color(getAffectionColor(this.getCatAffection(cat.id)))
                      .backgroundColor('#F3DDE3')
                  }
                  if (!isCatAwake(cat)) {
                    Text('💤 睡觉中')
                      .fontSize(12)
                      .fontColor('#CBBFBC')
                  }
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
              }
              .width('100%')
              .padding(12)
            }
            .width('100%')
            .backgroundColor('#FFFFFC')
            .borderRadius(18)
            .opacity(isCatAwake(cat) ? 1.0 : 0.6)
            .onClick(() => {
              if (isCatAwake(cat)) {
                this.visitCat(cat.id);
              } else {
                this.catGreetingText = cat.name + '正在睡觉呢…等它醒来再来吧~';
                this.selectedCat = cat;
                this.selectedCatAffection = this.getCatAffection(cat.id);
                this.showCatDetail = true;
              }
            })
          }, (cat: CatNPC) => cat.id)
        }
        .width('100%')
        .padding({ bottom: 8 })
      }
      .layoutWeight(1)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .padding({ left: 14, right: 14, top: 4 })
  }

  @Builder
  CatDetailPage() {
    Column() {
      if (this.selectedCat !== null) {
        Column({ space: 0 }) {
          Row({ space: 8 }) {
            Button('←')
              .width(36)
              .height(36)
              .fontSize(16)
              .fontColor('#7D6862')
              .backgroundColor('#FFF4F7')
              .borderRadius(18)
              .onClick(() => this.closeCatDetail())
            Text(this.selectedCat.emoji)
              .fontSize(22)
            Text(this.selectedCat.name)
              .fontSize(17)
              .fontWeight(FontWeight.Bold)
              .fontColor('#5A403A')
            Blank()
            Column()
              .width(36)
          }
          .width('100%')
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          .backgroundColor('#FFFFFC')

          if (!isCatAwake(this.selectedCat)) {
            Column() {
              Blank()
              Text('💤 ' + this.selectedCat.name + '正在睡觉')
                .fontSize(18)
                .fontColor('#CBBFBC')
              Text('活跃时间：' + this.selectedCat.awakeTime + ' · 睡觉时间：' + this.selectedCat.sleepTime)
                .fontSize(14)
                .fontColor('#DDBFBC')
              Blank()
            }
            .width('100%')
            .layoutWeight(1)
          } else {
            Scroll() {
              Column({ space: 10 }) {
                ForEach(this.catChatMessages, (msg: ChatMessage, idx: number) => {
                  Row() {
                    if (msg.fromMe) {
                      Blank()
                    } else {
                      Text(this.getSelectedCatEmoji())
                        .fontSize(28)
                        .margin({ right: 6 })
                    }
                    Column({ space: 4 }) {
                      Text(msg.text)
                        .fontSize(15)
                        .fontColor(msg.fromMe ? '#FFFFFF' : '#5A403A')
                        .padding({ left: 14, right: 14, top: 10, bottom: 10 })
                        .backgroundColor(msg.fromMe ? '#FF8F9F' : '#FFFFFC')
                        .borderRadius(18)
                      Text(msg.time)
                        .fontSize(11)
                        .fontColor('#CBBFBC')
                    }
                    .alignItems(msg.fromMe ? HorizontalAlign.End : HorizontalAlign.Start)
                    .constraintSize({ maxWidth: '75%' })
                    if (!msg.fromMe) {
                      Blank()
                    }
                  }
                  .width('100%')
                  .justifyContent(msg.fromMe ? FlexAlign.End : FlexAlign.Start)
                  .padding({ left: 12, right: 12 })
                }, (msg: ChatMessage, idx: number) => 'catmsg-' + idx.toString())
                Blank()
                  .height(20)
              }
              .width('100%')
              .padding({ top: 12 })
            }
            .layoutWeight(1)
            .width('100%')

            if (this.catChatShowOptions) {
              Column({ space: 6 }) {
                ForEach(this.getCatResponseOptions(this.selectedCat), (optText: string, idx: number) => {
                  Button(optText)
                    .width('100%')
                    .height(40)
                    .fontSize(13)
                    .fontColor('#FFFFFF')
                    .fontWeight(FontWeight.Bold)
                    .backgroundColor('#FF8F9F')
                    .borderRadius(20)
                    .onClick(() => this.sendCatChatOption(idx))
                }, (optText: string, idx: number) => 'opt-' + idx.toString())
              }
              .width('100%')
              .padding({ left: 14, right: 14, top: 8, bottom: 14 })
              .backgroundColor('#FFF4F7')
            }
          }
        }
        .width('100%')
        .height('100%')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFF4F7')
  }

  @Builder
  BentoPickerOverlay() {
    Column() {
      Column({ space: 12 }) {
        Row() {
          Text('🍱 选择便当')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#5A403A')
          Blank()
          Button('×')
            .width(32)
            .height(32)
            .fontSize(16)
            .fontColor('#9B7D76')
            .backgroundColor('#FFF4F7')
            .borderRadius(16)
            .onClick(() => {
              this.showBentoPicker = false;
            })
        }
        .width('100%')

        if (this.selectedCat !== null) {
          Text('💡 ' + this.selectedCat.name + '喜欢：' + this.selectedCat.likedBento.join('、'))
            .fontSize(13)
            .fontColor('#8BC8A5')
            .width('100%')
            .padding(10)
            .backgroundColor('#F0FFF4')
            .borderRadius(12)
        }

        Text('当前余额：' + this.coins.toString() + ' 三叶草币')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FF7F95')
          .width('100%')
          .textAlign(TextAlign.Center)

        ForEach(BENTO_LIST, (bento: CatBento) => {
          Row({ space: 10 }) {
            Text(bento.emoji)
              .fontSize(28)
            Column({ space: 2 }) {
              Text(bento.name)
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#5A403A')
              Text('效果：随机')
                .fontSize(11)
                .fontColor('#9B7D76')
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
            Text(bento.price.toString() + ' 币')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FF7F95')
            Button('送出')
              .width(60)
              .height(34)
              .fontSize(13)
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Bold)
              .backgroundColor(this.coins >= bento.price ? '#FF8F9F' : '#CBBFBC')
              .borderRadius(17)
              .enabled(this.coins >= bento.price)
              .onClick(() => {
                if (this.selectedCat !== null) {
                  this.sendBento(this.selectedCat.id, bento.id);
                }
              })
          }
          .width('100%')
          .padding(12)
          .backgroundColor('#FFF8FA')
          .borderRadius(16)
        }, (bento: CatBento) => bento.id)
      }
      .width('88%')
      .constraintSize({ maxHeight: '70%' })
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
  BentoResultOverlay() {
    Column() {
      Column({ space: 14 }) {
        Text(this.bentoReactionEmoji)
          .fontSize(48)
          .width('100%')
          .textAlign(TextAlign.Center)
        if (this.catAffectionFloat.length > 0) {
          Text('好感度 ' + this.catAffectionFloat)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF8F9F')
            .width('100%')
            .textAlign(TextAlign.Center)
        }
        Text(this.bentoReactionText)
          .fontSize(15)
          .fontColor('#5A403A')
          .lineHeight(24)
          .width('100%')
          .textAlign(TextAlign.Center)
        Button('知道了')
          .width('100%')
          .height(44)
          .fontSize(15)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
          .backgroundColor('#FF8F9F')
          .borderRadius(22)
          .onClick(() => {
            this.showBentoResult = false;
            this.catAffectionFloat = '';
          })
      }
      .width('76%')
      .padding(24)
      .backgroundColor('#FFFFFC')
      .borderRadius(24)
      .shadow({ radius: 30, color: '#33FF9EAF', offsetX: 0, offsetY: 10 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#66000000')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  LevelUpOverlay() {
    Column() {
      Column({ space: 14 }) {
        Text('🎉')
          .fontSize(48)
          .width('100%')
          .textAlign(TextAlign.Center)
        Text(this.levelUpText)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#5A403A')
          .lineHeight(26)
          .width('100%')
          .textAlign(TextAlign.Center)
        Button('太好了！')
          .width('100%')
          .height(44)
          .fontSize(15)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
          .backgroundColor('#BBA6E8')
          .borderRadius(22)
          .onClick(() => {
            this.showLevelUp = false;
          })
      }
      .width('76%')
      .padding(24)
      .backgroundColor('#FFFFFC')
      .borderRadius(24)
      .shadow({ radius: 30, color: '#33FF9EAF', offsetX: 0, offsetY: 10 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#66000000')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  ProfileOverlay() {
    Column() {
      Column({ space: 18 }) {
        Row() {
          Button('关闭')
            .width(76)
            .height(36)
            .fontSize(12)
            .fontColor('#7D6862')
            .backgroundColor('#FFF4F7')
            .borderRadius(18)
            .onClick(() => {
              this.showProfile = false;
            })
          Text('我的')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#5A403A')
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
          Blank()
            .width(76)
        }
        .width('100%')
        Circle()
          .width(72)
          .height(72)
          .fill('#FFD9E2')
          .alignSelf(ItemAlign.Center)
        Column({ space: 10 }) {
          Row() {
            Text('用户名')
              .fontSize(13)
              .fontColor('#9B7D76')
              .width(70)
            TextInput({ placeholder: '输入用户名', text: this.profileName })
              .layoutWeight(1)
              .height(40)
              .fontSize(14)
              .backgroundColor('#FFF4F7')
              .borderRadius(20)
              .onChange((value: string) => {
                this.profileName = value;
              })
          }
          .width('100%')
          this.UserRow('等级', 'Lv.' + this.calcLevel().toString())
          this.UserRow('ID', 'Pink-' + this.syncVersion.toString())
          this.UserRow('三叶草币', this.coins.toString())
          this.UserRow('钻石', this.gems.toString())
          this.UserRow('专注时长', this.focusMinutesToday.toString() + ' 分钟')
          this.UserRow('DDL完成', this.focusCount.toString() + ' 个')
        }
        .width('100%')
        Button('保存')
          .width('100%')
          .height(44)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
          .backgroundColor('#FF8F9F')
          .borderRadius(22)
          .onClick(() => {
            if (this.profileName.length >= 2 && this.profileName.length <= 12) {
              this.username = this.profileName;
              this.doroName = this.username + '的Doro';
              this.showProfile = false;
              this.syncLocalChange('用户名已更新');
            } else {
              this.doroWords = '名字需 2-12 个字符哦';
            }
          })
      }
      .width('88%')
      .padding(24)
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
  DialogueOverlay() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#00000000')
        .onClick(() => this.closeDialogue())

      Column({ space: 10 }) {
        Row() {
          Button('×')
            .width(28)
            .height(28)
            .fontSize(14)
            .fontColor('#9B7D76')
            .backgroundColor('#FFF4F7')
            .borderRadius(14)
            .onClick(() => this.closeDialogue())
          Blank()
          Text(this.dialogueSpeakerEmoji)
            .fontSize(22)
          Text(this.dialogueSpeakerName)
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .fontColor('#5A403A')
          Blank()
          Column()
            .width(28)
        }
        .width('100%')
        .padding({ top: 4 })

        Column({ space: 6 }) {
          Row() {
            Text(this.dialogueTypewriterText)
              .fontSize(15)
              .fontColor('#5A403A')
              .lineHeight(24)
              .layoutWeight(1)
              .padding(14)
          }
          .width('100%')
          .backgroundColor('#FFF0F5')
          .borderRadius(16)
          .constraintSize({ minHeight: 48, maxHeight: 100 })

          if (this.dialogueEffectText.length > 0) {
            Text(this.dialogueEffectText)
              .fontSize(12)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.dialogueEffectColor)
              .width('100%')
              .textAlign(TextAlign.Center)
          }
        }
        .width('100%')

        Column({ space: 6 }) {
          if (this.dialogueShowOptions) {
            ForEach(this.dialogueOptions, (option: DialogueOption, index: number) => {
              Button(option.text)
                .width('100%')
                .height(40)
                .fontSize(13)
                .fontColor('#FFFFFF')
                .fontWeight(FontWeight.Bold)
                .backgroundColor('#FF8F9F')
                .borderRadius(20)
                .onClick(() => this.onDialogueOptionSelect(index))
            }, (option: DialogueOption) => option.optionId)
          } else {
            Row() {
              Text(this.dialogueTypewriterText.length < this.dialogueTypewriterFull.length ? 'Doro正在打字...' : '点击背景继续')
                .fontSize(12)
                .fontColor('#CBBFBC')
                .width('100%')
                .textAlign(TextAlign.Center)
            }
            .height(30)
          }
        }
        .width('100%')
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12, bottom: 20 })
      .backgroundColor('#FFFFFC')
      .borderRadius({ topLeft: 28, topRight: 28, bottomLeft: 0, bottomRight: 0 })
      .shadow({ radius: 24, color: '#33FF9EAF', offsetX: 0, offsetY: -6 })
      .alignSelf(ItemAlign.End)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#66000000')
    .onClick(() => {
      if (!this.dialogueShowOptions && this.dialogueTypewriterText === this.dialogueTypewriterFull) {
        this.onDialogueContinue();
      }
    })
  }

  build() {
    if (this.appStage < 4) {
      this.AuthFlow()
    } else {
      Stack() {
        Column() {
          this.TopInfoBar()
          Column() {
            if (this.activeTab === 0) {
              this.HomePage()
            } else if (this.activeTab === 1) {
              this.DdlPage()
            } else if (this.activeTab === 2) {
              this.FocusPage()
            } else if (this.activeTab === 3) {
              this.BagPage()
            } else {
              if (this.showCatDetail) {
                this.CatDetailPage()
              } else {
                this.CatListPage()
              }
            }
          }
          .layoutWeight(1)
          this.BottomToolbar()
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#FFF4F7')
        .alignItems(HorizontalAlign.Center)
        if (this.showShop) {
          this.ShopAsOverlay()
        }
        if (this.showFeedPicker) {
          this.FeedPickerOverlay()
        }
        if (this.showDressPicker) {
          this.DressPickerOverlay()
        }
        if (this.showFocusCompleteDialog) {
          this.FocusCompleteOverlay()
        }
        if (this.showDdlPicker) {
          this.DdlPickerOverlay()
        }
        if (this.showFriendSearch) {
          this.SearchFriendOverlay()
        }
        if (this.showProfile) {
          this.ProfileOverlay()
        }
        if (this.showDialogue) {
          this.DialogueOverlay()
        }
      }
      .width('100%')
      .height('100%')
    }
  }
}
