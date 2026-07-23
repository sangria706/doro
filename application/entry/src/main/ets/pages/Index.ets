import { DdlTask, InventoryItem, ShopItem, FriendInfo, ChatMessage, TaskJson, FriendJson, SaveData } from './AppState';
import { DialogueEntry, DialogueOption, DialogueManager } from './DialogueSystem';
import { CatNPC, CatAffection, CatBento, BentoResult, ALL_CATS, BENTO_LIST, getCatById, getBentoById, getAffectionLevel, getAffectionColor, getAffectionLevelEmoji, getDailyDialogue, getBentoReaction, isCatAwake } from './CatNPCSystem';
import { HomePage } from './HomePage';
import { DdlPage } from './DdlPage';
import { FocusPage } from './FocusPage';
import { BagPage } from './BagPage';
import { CatListPage } from './CatListPage';
import { CatDetailPage } from './CatDetailPage';
import { TopInfoBar } from './components/TopInfoBar';
import { BottomToolbar } from './components/BottomToolbar';
import { FeedPickerOverlay, DressPickerOverlay, FocusCompleteOverlay, DdlPickerOverlay, ShopAsOverlay, SearchFriendOverlay, ProfileOverlay, DialogueOverlay, BentoPickerOverlay, BentoResultOverlay, LevelUpOverlay } from './components/Overlays';

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

  private calcLevel(): number {
    return Math.floor(this.focusCount / 5) + 1;
  }

  private calcExpProgress(): number {
    return this.focusCount % 5;
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
    this.startDialogueById('doro_ddl_done_01');
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

  private pad(value: number): string {
    return value < 10 ? `0${value}` : `${value}`;
  }

  private getCatResponseToOption(cat: CatNPC, optionIndex: number): string {
    const personality: string = cat.personality;
    if (personality === '焦虑') {
      const replies: string[] = ['嗯…你这么说了我好像放心一点了…', '真的吗？那我信你一次！', '好…好，深呼吸…呼——'];
      return replies[Math.floor(Math.random() * replies.length)];
    }
    if (personality === '优雅') {
      const replies: string[] = ['您过奖了…（优雅地点头）', '请坐，茶已经泡好了。', '和您聊天很愉快。'];
      return replies[Math.floor(Math.random() * replies.length)];
    }
    if (personality === '佛系') {
      const replies: string[] = ['啊…好…（慢慢坐起来）', '嗯…我再躺五分钟…', '吃的？…也行吧…'];
      return replies[Math.floor(Math.random() * replies.length)];
    }
    if (personality === '严肃') {
      const replies: string[] = ['嗯，继续保持。', '很好，有计划了吗？', '放松可以，但不能松懈。'];
      return replies[Math.floor(Math.random() * replies.length)];
    }
    if (personality === '害羞') {
      const replies: string[] = ['！谢、谢谢…（脸红）', '好…好的…我慢慢来…', '你、你真好……'];
      return replies[Math.floor(Math.random() * replies.length)];
    }
    if (personality === '话痨') {
      const replies: string[] = ['对吧对吧！我就知道你会感兴趣！', '还有还有！我还没说完呢！', '哈哈哈你懂我！'];
      return replies[Math.floor(Math.random() * replies.length)];
    }
    if (personality === '迷糊') {
      const replies: string[] = ['诶？我刚刚说啥来着……', '哦对！谢谢你帮我找！', '嘿嘿…我是不是很麻烦…'];
      return replies[Math.floor(Math.random() * replies.length)];
    }
    if (personality === '暴躁') {
      const replies: string[] = ['哼！我才不凶！', '别、别摸我头啦…', '打游戏？…行吧就陪你一会儿。'];
      return replies[Math.floor(Math.random() * replies.length)];
    }
    if (personality === '文艺') {
      const replies: string[] = ['你也感受到那种情绪了吗…', '今天的风确实很适合这首诗。', '灵感像猫一样，强求不来的。'];
      return replies[Math.floor(Math.random() * replies.length)];
    }
    if (personality === '贪吃') {
      const replies: string[] = ['真的吗！快给我尝尝！', '我才不胖！这是…毛茸茸！', '好啊好啊！吃什么！'];
      return replies[Math.floor(Math.random() * replies.length)];
    }
    if (personality === '傲娇') {
      const replies: string[] = ['哼…你这么说我也不会高兴的！', '谁、谁要你夸了！', '今天…特地为我才穿这么好看的吗？'];
      return replies[Math.floor(Math.random() * replies.length)];
    }
    if (personality === '温柔') {
      const replies: string[] = ['你也是我遇见过最温暖的人。', '累了就休息，我会一直在这里的。', '过来吧，给你一个抱抱~'];
      return replies[Math.floor(Math.random() * replies.length)];
    }
    return '…谢谢你来看我。';
  }

  private sendCatChatOption(optionIndex: number): void {
    if (this.selectedCat === null || this.catChatDone) {
      return;
    }
    const personality: string = this.selectedCat.personality;
    let options: string[] = [];
    if (personality === '焦虑') {
      options = ['别担心，有我呢！', '今天天气超好的~', '摸摸头冷静一下'];
    } else if (personality === '优雅') {
      options = ['你今天也好优雅~', '请多指教！', '一起喝杯茶吧'];
    } else if (personality === '佛系') {
      options = ['醒醒！太阳晒屁股了', '你继续睡吧~', '要不要吃点什么？'];
    } else if (personality === '严肃') {
      options = ['今天也很自律呢！', '我马上去写计划！', '不要太严格啦~'];
    } else if (personality === '害羞') {
      options = ['你好可爱呀！', '不要怕，我不会伤害你的', '慢慢来不着急'];
    } else if (personality === '话痨') {
      options = ['然后呢然后呢？', '哈哈哈好好笑', '你听我说！'];
    } else if (personality === '迷糊') {
      options = ['你又忘了什么呀？', '我帮你找找！', '小迷糊最可爱了'];
    } else if (personality === '暴躁') {
      options = ['你好凶哦…', '给你顺顺毛~', '要不要一起玩游戏？'];
    } else if (personality === '文艺') {
      options = ['好有意境的话呀', '我也喜欢~', '今天灵感怎么样？'];
    } else if (personality === '贪吃') {
      options = ['带好吃的了！', '你又胖了哈哈哈', '一起吃吧~'];
    } else if (personality === '傲娇') {
      options = ['你也很可爱啦！', '我才不是在夸你~', '今天特别好看哦'];
    } else if (personality === '温柔') {
      options = ['你太暖了！', '今天也辛苦了~', '抱抱！'];
    } else {
      options = ['你好呀！', '今天怎么样？', '一起加油吧~'];
    }
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
    this.showBentoPicker = false;
    this.showLevelUp = false;
    this.catChatDone = false;
    this.catChatShowOptions = false;
    this.catChatMessages = [];
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
        Text('继续使用表示你同意本地保存游戏数据，并在登录后同步到云端。后续可在"我的-隐私设置"中管理小镇拜访、在线状态和便当接收。')
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

  build() {
    if (this.appStage < 4) {
      this.AuthFlow()
    } else {
      Stack() {
        Column() {
          TopInfoBar({
            username: this.username,
            level: this.calcLevel(),
            expProgress: this.calcExpProgress(),
            coins: this.coins,
            gems: this.gems,
            hasEventUpdate: this.hasEventUpdate,
            onAvatarClick: () => {
              this.profileName = this.username;
              this.showProfile = true;
            },
            onShopClick: () => {
              this.showShop = true;
            }
          })
          Column() {
            if (this.activeTab === 0) {
              HomePage({
                mood: this.mood,
                satiety: this.satiety,
                coins: this.coins,
                feedback: this.feedback,
                comfort: this.comfort,
                pendingCount: this.pendingCount(),
                overdueCount: this.overdueCount(),
                doroWords: this.doroWords,
                onFeed: () => this.feedDoro(),
                onTouchDoro: () => this.touchDoro(),
                onDress: () => this.dressDoro(),
                onDialogue: () => this.checkAndTriggerDialogue()
              })
            } else if (this.activeTab === 1) {
              DdlPage({
                tasks: this.tasks,
                ddlStep: this.ddlStep,
                newTitle: this.newTitle,
                newDeadline: this.newDeadline,
                newDifficulty: this.newDifficulty,
                onTitleChange: (value: string) => { this.newTitle = value; },
                onDeadlineChange: (value: string) => { this.newDeadline = value; },
                onDifficultyChange: (value: string) => { this.newDifficulty = value; },
                onPrevStep: () => { if (this.ddlStep > 0) { this.ddlStep -= 1; } },
                onNextStep: () => { this.ddlStep += 1; },
                onAddTask: () => this.addTask(),
                onFinishTask: (taskId: number) => this.finishTask(taskId)
              })
            } else if (this.activeTab === 2) {
              FocusPage({
                focusDuration: this.focusDuration,
                focusSecondsLeft: this.focusSecondsLeft,
                focusRunning: this.focusRunning,
                focusSliderValue: this.focusSliderValue,
                focusCustomName: this.focusCustomName,
                selectedTaskId: this.selectedTaskId,
                focusMinutesToday: this.focusMinutesToday,
                focusCount: this.focusCount,
                doroWords: this.doroWords,
                onSliderChange: (value: number) => {
                  this.focusSliderValue = value;
                  const mins: number = Math.round(value);
                  this.focusDuration = mins;
                  this.focusSecondsLeft = mins * 60;
                },
                onToggle: () => this.toggleFocus(),
                onReset: () => this.resetFocus(),
                onSelectDdl: () => { if (this.timerId === -1) { this.showDdlPicker = true; } },
                onDdlSelect: (taskId: number) => this.selectDdlForFocus(taskId),
                onCustomNameChange: (value: string) => { this.focusCustomName = value; },
                onTouchDoro: () => this.touchDoro()
              })
            } else if (this.activeTab === 3) {
              BagPage({
                bagTab: this.bagTab,
                outfits: this.outfits,
                foods: this.foods,
                furnitures: this.furnitures,
                onTabChange: (index: number) => { this.bagTab = index; },
                onUseFood: (index: number) => this.useFood(index)
              })
            } else {
              if (this.showCatDetail) {
                CatDetailPage({
                  selectedCatEmoji: this.selectedCat !== null ? this.selectedCat.emoji : '🐱',
                  selectedCatName: this.selectedCat !== null ? this.selectedCat.name : '',
                  selectedCatAwake: this.selectedCat !== null ? isCatAwake(this.selectedCat) : true,
                  selectedCatPersonality: this.selectedCat !== null ? this.selectedCat.personality : '',
                  selectedCatAwakeTime: this.selectedCat !== null ? this.selectedCat.awakeTime : '',
                  selectedCatSleepTime: this.selectedCat !== null ? this.selectedCat.sleepTime : '',
                  selectedCatId: this.selectedCat !== null ? this.selectedCat.id : '',
                  selectedCatLikedBento: this.selectedCat !== null ? this.selectedCat.likedBento : [],
                  catChatMessages: this.catChatMessages,
                  catChatShowOptions: this.catChatShowOptions,
                  catChatDone: this.catChatDone,
                  onClose: () => this.closeCatDetail(),
                  onChatOption: (optionIndex: number) => this.sendCatChatOption(optionIndex),
                  onOpenBentoPicker: () => { this.showBentoPicker = true; }
                })
              } else {
                CatListPage({
                  getAffection: (catId: string) => this.getCatAffection(catId),
                  onVisitCat: (catId: string) => this.visitCat(catId)
                })
              }
            }
          }
          .layoutWeight(1)
          BottomToolbar({
            activeTab: this.activeTab,
            pendingCount: this.pendingCount(),
            onTabChange: (index: number) => {
              this.activeTab = index;
              this.feedback = '';
            }
          })
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#FFF4F7')
        .alignItems(HorizontalAlign.Center)

        if (this.showShop) {
          ShopAsOverlay({
            shopTab: this.shopTab,
            coins: this.coins,
            shopItems: this.shopItems,
            onBuy: (globalIndex: number) => this.buyShopItem(globalIndex),
            onTabChange: (index: number) => { this.shopTab = index; },
            onClose: () => { this.showShop = false; }
          })
        }
        if (this.showFeedPicker) {
          FeedPickerOverlay({
            foods: this.foods,
            onFeed: (index: number) => this.feedWithItem(index),
            onClose: () => { this.showFeedPicker = false; }
          })
        }
        if (this.showDressPicker) {
          DressPickerOverlay({
            outfits: this.outfits,
            onDress: (index: number) => this.dressWithItem(index),
            onClose: () => { this.showDressPicker = false; }
          })
        }
        if (this.showFocusCompleteDialog) {
          FocusCompleteOverlay({
            focusDuration: this.focusDuration,
            selectedTaskId: this.selectedTaskId,
            focusMarkDdlDone: this.focusMarkDdlDone,
            onContinue5: () => { this.continueFocus(5); },
            onContinue10: () => { this.continueFocus(10); },
            onEnd: () => this.endFocusSession(),
            onToggle: (value: boolean) => { this.focusMarkDdlDone = value; },
            onClose: () => { this.showFocusCompleteDialog = false; }
          })
        }
        if (this.showDdlPicker) {
          DdlPickerOverlay({
            tasks: this.tasks,
            selectedTaskId: this.selectedTaskId,
            focusCustomName: this.focusCustomName,
            onSelect: (taskId: number) => this.selectDdlForFocus(taskId),
            onNameChange: (value: string) => { this.focusCustomName = value; },
            onClose: () => { this.showDdlPicker = false; }
          })
        }
        if (this.showFriendSearch) {
          SearchFriendOverlay({
            searchKeyword: this.searchKeyword,
            searchResults: this.searchResults,
            friends: this.friends,
            onKeywordChange: (value: string) => { this.searchKeyword = value; },
            onSearch: () => this.searchFriends(),
            onAdd: (friendId: number) => this.addFriend(friendId),
            onClose: () => { this.showFriendSearch = false; }
          })
        }
        if (this.showProfile) {
          ProfileOverlay({
            profileName: this.profileName,
            level: this.calcLevel(),
            syncVersion: this.syncVersion,
            coins: this.coins,
            gems: this.gems,
            focusMinutesToday: this.focusMinutesToday,
            focusCount: this.focusCount,
            onNameChange: (value: string) => { this.profileName = value; },
            onSave: () => {
              if (this.profileName.length >= 2 && this.profileName.length <= 12) {
                this.username = this.profileName;
                this.doroName = this.username + '的Doro';
                this.showProfile = false;
                this.syncLocalChange('用户名已更新');
              } else {
                this.doroWords = '名字需 2-12 个字符哦';
              }
            },
            onClose: () => { this.showProfile = false; }
          })
        }
        if (this.showDialogue) {
          DialogueOverlay({
            dialogueSpeakerEmoji: this.dialogueSpeakerEmoji,
            dialogueSpeakerName: this.dialogueSpeakerName,
            dialogueTypewriterText: this.dialogueTypewriterText,
            dialogueTypewriterFull: this.dialogueTypewriterFull,
            dialogueOptions: this.dialogueOptions,
            dialogueEffectText: this.dialogueEffectText,
            dialogueEffectColor: this.dialogueEffectColor,
            dialogueShowOptions: this.dialogueShowOptions,
            onOptionSelect: (optionIndex: number) => this.onDialogueOptionSelect(optionIndex),
            onContinue: () => this.onDialogueContinue(),
            onClose: () => this.closeDialogue()
          })
        }
        if (this.showBentoPicker) {
          BentoPickerOverlay({
            catName: this.selectedCat !== null ? this.selectedCat.name : '',
            likedBento: this.selectedCat !== null ? this.selectedCat.likedBento : [],
            coins: this.coins,
            bentoList: BENTO_LIST,
            onSend: (bentoId: string) => {
              if (this.selectedCat !== null) {
                this.sendBento(this.selectedCat.id, bentoId);
              }
            },
            onClose: () => { this.showBentoPicker = false; }
          })
        }
        if (this.showBentoResult) {
          BentoResultOverlay({
            bentoReactionEmoji: this.bentoReactionEmoji,
            bentoReactionText: this.bentoReactionText,
            catAffectionFloat: this.catAffectionFloat,
            onClose: () => {
              this.showBentoResult = false;
              this.catAffectionFloat = '';
            }
          })
        }
        if (this.showLevelUp) {
          LevelUpOverlay({
            levelUpText: this.levelUpText,
            onClose: () => { this.showLevelUp = false; }
          })
        }
      }
      .width('100%')
      .height('100%')
    }
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
}
