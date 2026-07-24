import { DdlTask, InventoryItem, ShopItem, FriendInfo, ChatMessage } from './AppState';
import { DialogueEntry, DialogueOption, DialogueManager } from './DialogueSystem';
import { CatNPC, CatAffection, ALL_CATS, BENTO_LIST, getCatById, isCatAwake } from './CatNPCSystem';
import { CatNpcService, CatNpcVisitState, CatNpcBentoResultState, CatNpcChatSelectionResult } from '../services/CatNpcService';
import { HomePage } from './HomePage';
import { DdlPage } from './DdlPage';
import { FocusPage } from './FocusPage';
import { BagPage } from './BagPage';
import { CatListPage } from './CatListPage';
import { CatDetailPage } from './CatDetailPage';
import { AchievementItem, AchievementClaimResult, TEST_ACHIEVEMENTS, cloneAchievements } from './AchievementSystem';
import { DdlTaskService, DdlTaskAddResult, DdlTaskFinishResult } from '../services/DdlTaskService';
import {
  FocusTimerService,
  FocusCompleteResult,
  FocusToggleResult,
  FocusResetResult,
  FocusContinueResult,
  FocusTickResult
} from '../services/FocusTimerService';
import { SaveDataService, SaveSnapshot, LoadDataResult, SyncLocalResult } from '../services/SaveDataService';
import { TopInfoBar } from './components/TopInfoBar';
import { BottomToolbar } from './components/BottomToolbar';
import { FeedPickerOverlay, DressPickerOverlay, FocusCompleteOverlay, DdlPickerOverlay, ShopAsOverlay, SearchFriendOverlay, ProfileOverlay, DialogueOverlay, BentoPickerOverlay, BentoResultOverlay, LevelUpOverlay } from './components/Overlays';
import { AchievementUnlockOverlay } from './components/AchievementOverlay';
import { QuickDdlCreateOverlay } from './components/QuickDdlCreateOverlay';
import { DdlQuickFloatBar } from './components/DdlQuickFloatBar';
import { DashboardPage } from './DashboardPage';

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
  @State newDeadline: string = '';
  @State newDifficulty: string = '困难';
  @State mood: number = 60;
  @State satiety: number = 60;
  @State coins: number = 0;
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
  @State showQuickDdlCreate: boolean = false;
  @State showDashboard: boolean = false;
  @State showFloatBar: boolean = true;
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
  @State tasks: DdlTask[] = [];
  @State isNewPlayer: boolean = false;
  private ddlTaskService: DdlTaskService = new DdlTaskService();
  private readonly focusTimerService: FocusTimerService = new FocusTimerService();
  private readonly saveService: SaveDataService = new SaveDataService();
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
  @State gems: number = 0;
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
  private catNpcService: CatNpcService = new CatNpcService(this.catAffections, {
    saveData: () => this.persistSave(),
    pad: (value: number) => this.pad(value),
    closeCatDetail: () => this.closeCatDetail()
  });
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
  @State achievements: AchievementItem[] = cloneAchievements(TEST_ACHIEVEMENTS);
  @State showAchievementUnlock: boolean = false;
  @State showAchievementList: boolean = false;
  @State achievementUnlockName: string = '';
  private achievementUnlockTimer: number = -1;

  aboutToAppear(): void {
    PersistentStorage.persistProp('doro_tutorial_done', false);
    this.loadData();
    this.initFriends();
    this.initCatAffections();
    const tutorialDone: Object | undefined = AppStorage.get('doro_tutorial_done') as Object | undefined;
    const tutorialFlag: boolean = tutorialDone === true;
    if (!tutorialFlag && this.tasks.length === 0 && this.focusCount === 0) {
      this.isNewPlayer = true;
      this.coins = 0;
      this.mood = 60;
      this.satiety = 60;
    }
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

  private buildSaveSnapshot(): SaveSnapshot {
    return {
      tasks: this.tasks,
      focusMinutesToday: this.focusMinutesToday,
      focusCount: this.focusCount,
      coins: this.coins,
      mood: this.mood,
      satiety: this.satiety,
      syncVersion: this.syncVersion,
      friends: this.friends,
      catAffections: this.catAffections,
      achievements: this.achievements
    };
  }

  private applySaveSnapshot(snapshot: SaveSnapshot): void {
    this.tasks = snapshot.tasks;
    this.focusMinutesToday = snapshot.focusMinutesToday;
    this.focusCount = snapshot.focusCount;
    this.coins = snapshot.coins;
    this.mood = snapshot.mood;
    this.satiety = snapshot.satiety;
    this.syncVersion = snapshot.syncVersion;
    this.friends = snapshot.friends;
    this.catAffections = snapshot.catAffections;
    this.achievements = snapshot.achievements;
  }

  private persistSave(): void {
    this.saveService.saveData(this.buildSaveSnapshot());
  }

  private syncLocalChange(text: string): void {
    const snap: SaveSnapshot = this.buildSaveSnapshot();
    const res: SyncLocalResult = this.saveService.syncLocalChange(snap, text);
    this.syncVersion = res.syncVersion;
    this.feedback = res.feedback;
  }

  private sortAchievements(items: AchievementItem[]): AchievementItem[] {
    const unlocked: AchievementItem[] = [];
    const claimable: AchievementItem[] = [];
    const claimed: AchievementItem[] = [];
    for (let i: number = 0; i < items.length; i++) {
      const item: AchievementItem = items[i];
      const copy: AchievementItem = {
        id: item.id,
        name: item.name,
        desc: item.desc,
        completed: item.completed,
        claimed: item.claimed,
        rewardGems: item.rewardGems,
        rewardCoins: item.rewardCoins
      };
      if (!item.completed) {
        unlocked.push(copy);
      } else if (!item.claimed) {
        claimable.push(copy);
      } else {
        claimed.push(copy);
      }
    }
    return unlocked.concat(claimable).concat(claimed);
  }

  private updateAchievementProgress(): void {
    const map: Record<string, boolean> = {
      'ach_focus_1': this.focusCount >= 1,
      'ach_ddl_1': this.tasks.some((task: DdlTask) => task.done),
      'ach_friend_1': this.friends.length >= 6
    };
    const nextAchievements: AchievementItem[] = [];
    for (let i: number = 0; i < this.achievements.length; i++) {
      const item: AchievementItem = this.achievements[i];
      const completed: boolean = map[item.id] === true;
      nextAchievements.push({
        id: item.id,
        name: item.name,
        desc: item.desc,
        completed: completed,
        claimed: item.claimed,
        rewardGems: item.rewardGems,
        rewardCoins: item.rewardCoins
      });
    }
    this.achievements = this.sortAchievements(nextAchievements);
  }

  private claimAchievement(achievementId: string): AchievementClaimResult | undefined {
    const claimed = this.achievements.find((item: AchievementItem) => item.id === achievementId);
    if (claimed === undefined || !claimed.completed || claimed.claimed) {
      return undefined;
    }
    const nextAchievements: AchievementItem[] = [];
    for (let i: number = 0; i < this.achievements.length; i++) {
      const item: AchievementItem = this.achievements[i];
      nextAchievements.push({
        id: item.id,
        name: item.name,
        desc: item.desc,
        completed: item.completed,
        claimed: item.id === achievementId ? true : item.claimed,
        rewardGems: item.rewardGems,
        rewardCoins: item.rewardCoins
      });
    }
    this.achievements = this.sortAchievements(nextAchievements);
    this.gems += claimed.rewardGems;
    this.coins += claimed.rewardCoins;
    this.feedback = '成就奖励已领取';
    this.persistSave();
    this.showAchievementList = false;
    this.showAchievementUnlockToast(claimed.name);
    return {
      rewardGems: claimed.rewardGems,
      rewardCoins: claimed.rewardCoins,
      showRewardPopup: true
    };
  }

  private openAchievementList(): void {
    this.showAchievementList = true;
  }

  private showAchievementUnlockToast(name: string): void {
    this.achievementUnlockName = name;
    this.showAchievementUnlock = true;
    if (this.achievementUnlockTimer !== -1) {
      clearTimeout(this.achievementUnlockTimer);
    }
    this.achievementUnlockTimer = setTimeout(() => {
      this.showAchievementUnlock = false;
      this.achievementUnlockTimer = -1;
    }, 3000) as number;
  }

  private loadData(): void {
    const loaded: LoadDataResult = this.saveService.loadData(this.buildSaveSnapshot());
    if (loaded.hasMainSave || loaded.hasCatSave) {
      this.applySaveSnapshot(loaded.snapshot);
    } else {
      this.achievements = loaded.snapshot.achievements;
    }
    this.updateAchievementProgress();
  }

  private pendingCount(): number {
    return this.ddlTaskService.pendingCount(this.tasks);
  }

  private overdueCount(): number {
    return this.ddlTaskService.overdueCount(this.tasks);
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

  private openQuickDdlCreate(): void {
    this.ddlStep = 0;
    this.doroWords = '';
    this.showQuickDdlCreate = true;
  }

  private handleQuickDdlPrev(): void {
    if (this.ddlStep > 0) {
      this.ddlStep = this.ddlStep - 1;
    }
  }

  private handleQuickDdlNext(): void {
    if (this.ddlStep === 0) {
      if (this.newTitle.trim().length === 0) {
        this.doroWords = '契约要先写下名字哦。';
        this.ddlStep = 0;
        return;
      }
      this.doroWords = '';
      this.ddlStep = 1;
      return;
    }
    if (this.ddlStep === 1) {
      // 与 DdlTaskService 一致的时间校验文案，但不在此步创建任务
      const deadlineReg: RegExp = /^\d{4}-\d{2}-\d{2} \d{2}:\d{2}$/;
      if (!deadlineReg.test(this.newDeadline)) {
        this.doroWords = '日期格式写成 2026-05-21 13:14哦。';
        this.ddlStep = 1;
        return;
      }
      const deadlineTime: number = new Date(this.newDeadline.replace(' ', 'T')).getTime();
      if (deadlineTime <= Date.now()) {
        this.doroWords = '截止时间不能早于现在哦。';
        this.ddlStep = 1;
        return;
      }
      this.doroWords = '';
      this.ddlStep = 2;
      return;
    }
    this.handleAddDdlTask();
  }

  private handleAddDdlTask(): void {
    const result: DdlTaskAddResult = this.ddlTaskService.addTask(this.tasks, this.newTitle, this.newDeadline, this.newDifficulty);
    this.ddlStep = result.ddlStep;
    this.doroWords = result.doroWords;
    this.newTitle = result.newTitle;
    this.newDeadline = result.newDeadline;
    if (!result.shouldSync) {
      return;
    }
    this.tasks = result.tasks;
    this.selectedTaskId = result.selectedTaskId;
    this.coins += result.coinsDelta;
    this.syncLocalChange(result.feedback);
    this.showQuickDdlCreate = false;
  }

  private handleFinishDdlTask(taskId: number): void {
    const result: DdlTaskFinishResult = this.ddlTaskService.finishTask(this.tasks, taskId);
    this.tasks = result.tasks;
    if (!result.shouldSync) {
      return;
    }
    this.coins += result.reward;
    this.mood = this.clamp(this.mood + result.moodDelta);
    this.satiety = this.clamp(this.satiety + result.satietyDelta);
    this.doroWords = result.doroWords;
    this.syncLocalChange(result.feedback);
    if (!this.showDialogue) {
      if (result.triggerOverdueDialogue) {
        this.triggerDdlOverdueDialogue();
      } else if (result.triggerDoneDialogue) {
        this.triggerDdlDoneDialogue();
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
        const nextFoods: InventoryItem[] = [];
        for (let i: number = 0; i < this.foods.length; i++) {
          nextFoods.push(this.foods[i]);
        }
        nextFoods.push(new InventoryItem(item.name, item.desc, 1));
        this.foods = nextFoods;
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
        const nextOutfits: InventoryItem[] = [];
        for (let i: number = 0; i < this.outfits.length; i++) {
          nextOutfits.push(this.outfits[i]);
        }
        nextOutfits.push(new InventoryItem(item.name, item.desc, 1));
        this.outfits = nextOutfits;
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
    this.updateAchievementProgress();
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
      const nextFriends: FriendInfo[] = [];
      for (let i: number = 0; i < this.friends.length; i++) {
        nextFriends.push(this.friends[i]);
      }
      nextFriends.push(found);
      this.friends = nextFriends;
      const nextResults: FriendInfo[] = [];
      for (let i: number = 0; i < this.searchResults.length; i++) {
        const resultFriend: FriendInfo = this.searchResults[i];
        if (resultFriend.id !== friendId) {
          nextResults.push(resultFriend);
        }
      }
    this.searchResults = nextResults;
      this.doroWords = '你和' + found.name + '成为好友了！';
      this.syncLocalChange('好友 +1');
      this.updateAchievementProgress();
      const unlocked = this.achievements.find((item: AchievementItem) => item.id === 'ach_friend_1');
      if (unlocked !== undefined && unlocked.completed && !unlocked.claimed) {
        this.showAchievementUnlockToast(unlocked.name);
      }
    }
  }

  private toggleFocus(): void {
    const res: FocusToggleResult = this.focusTimerService.toggle(this.focusSecondsLeft, () => {
      this.onFocusTick();
    });
    if (res.feedback.length === 0 && res.doroWords.length === 0 && !res.started && !res.focusRunning) {
      return;
    }
    this.focusRunning = res.focusRunning;
    if (res.feedback.length > 0) {
      this.feedback = res.feedback;
    }
    if (res.doroWords.length > 0) {
      this.doroWords = res.doroWords;
    }
  }

  private onFocusTick(): void {
    const tick: FocusTickResult = this.focusTimerService.tick(this.focusSecondsLeft);
    this.focusSecondsLeft = tick.focusSecondsLeft;
    this.focusRunning = tick.focusRunning;
    if (tick.isComplete) {
      this.onFocusComplete();
    }
  }

  private onFocusComplete(): void {
    this.showFocusCompleteDialog = true;
    this.focusMarkDdlDone = false;
    this.doroWords = '时间到！Doro 轻轻碰了碰你的手。';
  }

  private continueFocus(extraMinutes: number): void {
    const cont: FocusContinueResult = this.focusTimerService.continueMinutes(extraMinutes);
    this.focusSecondsLeft = cont.focusSecondsLeft;
    this.showFocusCompleteDialog = cont.showFocusCompleteDialog;
    this.toggleFocus();
  }

  private endFocusSession(): void {
    const res: FocusCompleteResult = this.focusTimerService.completeSession(
      this.focusDuration,
      this.focusCount,
      this.focusMarkDdlDone,
      this.selectedTaskId
    );
    this.focusMinutesToday += res.focusMinutesAdd;
    this.focusCount += res.focusCountAdd;
    this.coins += res.coinAdd;
    this.mood = this.clamp(this.mood + res.moodAdd);
    if (res.shouldMarkDdlDone) {
      this.handleFinishDdlTask(this.selectedTaskId);
    }
    if (res.shouldAddFragment) {
      const nextOutfits: InventoryItem[] = [];
      for (let i: number = 0; i < this.outfits.length; i++) {
        const item: InventoryItem = this.outfits[i];
        if (item.name === '专注之星碎片') {
          nextOutfits.push(new InventoryItem(item.name, item.desc, item.count + 1));
        } else {
          nextOutfits.push(item);
        }
      }
      this.outfits = nextOutfits;
    }
    this.doroWords = res.doroWords;
    this.syncLocalChange(res.feedback);
    this.showFocusCompleteDialog = false;
    this.persistSave();
  }

  private selectDuration(minutes: number): void {
    if (!this.focusTimerService.canChangeDurationOrDdl()) {
      return;
    }
    this.focusDuration = minutes;
    this.focusSecondsLeft = minutes * 60;
  }

  private resetFocus(): void {
    const res: FocusResetResult = this.focusTimerService.reset(this.focusDuration);
    this.focusRunning = res.focusRunning;
    this.focusSecondsLeft = res.focusSecondsLeft;
    this.showFocusCompleteDialog = res.showFocusCompleteDialog;
    this.doroWords = res.doroWords;
  }

  private selectDdlForFocus(taskId: number): void {
    if (!this.focusTimerService.canChangeDurationOrDdl()) {
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
    const wasTutorial: boolean = this.currentDialogueId === 'doro_tutorial_01' || this.currentDialogueId === 'doro_tutorial_02';
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
    if (wasTutorial && this.isNewPlayer) {
      AppStorage.set('doro_tutorial_done', true);
      this.isNewPlayer = false;
      this.persistSave();
    }
  }

  private triggerDdlDoneDialogue(): void {
    this.startDialogueById('doro_ddl_done_01');
  }

  private triggerDdlOverdueDialogue(): void {
    this.startDialogueById('doro_ddl_overdue_01');
  }

  private getCatAffection(catId: string): number {
    return this.catNpcService.getCatAffection(catId);
  }

  private visitCat(catId: string): void {
    const state: CatNpcVisitState = this.catNpcService.visitCat(catId);
    this.selectedCat = state.selectedCat;
    this.selectedCatAffection = state.selectedCatAffection;
    this.selectedCatVisitCount = state.selectedCatVisitCount;
    this.catGreetingText = state.catGreetingText;
    this.catChatMessages = state.catChatMessages;
    this.catChatShowOptions = state.catChatShowOptions;
    this.catChatDone = state.catChatDone;
    this.showCatDetail = state.showCatDetail;
  }

  private pad(value: number): string {
    return value < 10 ? `0${value}` : `${value}`;
  }

  private sendCatChatOption(optionIndex: number): void {
    if (this.selectedCat === null || this.catChatDone) {
      return;
    }
    this.catNpcService.sendCatChatOption(this.selectedCat, optionIndex, this.catChatMessages);
    this.catChatShowOptions = false;
    this.catChatDone = true;
    setTimeout(() => {
      this.closeCatDetail();
    }, 1500);
  }

  private sendBento(catId: string, bentoId: string): void {
    const resultState: CatNpcBentoResultState = this.catNpcService.sendBento(catId, bentoId, this.coins);
    this.bentoReactionText = resultState.bentoReactionText;
    this.bentoReactionEmoji = resultState.bentoReactionEmoji;
    this.catAffectionFloat = resultState.catAffectionFloat;
    this.levelUpText = resultState.levelUpText;
    this.showBentoPicker = resultState.showBentoPicker;
    this.showBentoResult = resultState.showBentoResult;
    this.showLevelUp = resultState.showLevelUp;
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
          if (this.isNewPlayer) {
            setTimeout(() => {
              this.startDialogueById('doro_tutorial_01');
            }, 300);
          }
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
            claimableAchievementCount: this.countClaimableAchievements(),
            onAvatarClick: () => {
              this.profileName = this.username;
              this.showProfile = true;
            },
            onShopClick: () => {
              this.showShop = true;
            },
            onAchievementClick: () => this.openAchievementList(),
            onDashboardClick: () => { this.showDashboard = true; }
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
                doroWords: this.doroWords,
                onTitleChange: (value: string) => { this.newTitle = value; },
                onDeadlineChange: (value: string) => { this.newDeadline = value; },
                onDifficultyChange: (value: string) => { this.newDifficulty = value; },
                onAddTask: () => this.handleAddDdlTask(),
                onFinishTask: (taskId: number) => this.handleFinishDdlTask(taskId)
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
                onSelectDdl: () => {
                  if (this.focusTimerService.canChangeDurationOrDdl()) {
                    this.showDdlPicker = true;
                  }
                },
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

        if (this.showFloatBar && !this.showQuickDdlCreate && this.activeTab !== 2) {
          DdlQuickFloatBar({
            tasks: this.tasks,
            onOpenDdlTab: () => {
              this.activeTab = 1;
              this.feedback = '';
            },
            onCreate: () => this.openQuickDdlCreate(),
            onClose: () => { this.showFloatBar = false; }
          })
          .position({ x: 12, y: '100%' })
          .translate({ x: 0, y: -156 })
        }

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
            onAchievement: () => {
              this.showProfile = false;
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
        if (this.showAchievementUnlock) {
          AchievementUnlockOverlay({
            title: this.achievementUnlockName,
            completedText: '已完成',
            onOpen: () => {
              this.showAchievementUnlock = false;
              this.showDashboard = true;
            },
            onClose: () => { this.showAchievementUnlock = false; }
          })
        }
        if (this.showQuickDdlCreate) {
          QuickDdlCreateOverlay({
            ddlStep: this.ddlStep,
            newTitle: this.newTitle,
            newDeadline: this.newDeadline,
            newDifficulty: this.newDifficulty,
            doroWords: this.doroWords,
            onTitleChange: (value: string) => { this.newTitle = value; },
            onDeadlineChange: (value: string) => { this.newDeadline = value; },
            onDifficultyChange: (value: string) => { this.newDifficulty = value; },
            onPrev: () => this.handleQuickDdlPrev(),
            onNext: () => this.handleQuickDdlNext(),
            onAddTask: () => this.handleAddDdlTask(),
            onClose: () => {
              this.showQuickDdlCreate = false;
              this.ddlStep = 0;
            }
          })
        }
        if (this.showDashboard) {
          Column() {
            Column({ space: 10 }) {
              Row() {
                Text('数据看板')
                  .fontSize(20)
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
                  .onClick(() => { this.showDashboard = false; })
              }
              .width('100%')
              DashboardPage({
                tasks: this.tasks,
                focusCount: this.focusCount,
                focusMinutesToday: this.focusMinutesToday,
                mood: this.mood,
                satiety: this.satiety,
                coins: this.coins,
                comfort: this.comfort,
                achievements: this.achievements,
                currentLevel: this.calcLevel(),
                expProgress: this.calcExpProgress(),
                onClaimAchievement: (achievementId: string) => {
                  const result = this.claimAchievement(achievementId);
                  return result;
                }
              })
            }
            .width('88%')
            .constraintSize({ maxHeight: '85%' })
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
      }
      .width('100%')
      .height('100%')
    }
  }

  private countClaimableAchievements(): number {
    let count: number = 0;
    for (let i: number = 0; i < this.achievements.length; i++) {
      const item: AchievementItem = this.achievements[i];
      if (item.completed && !item.claimed) {
        count += 1;
      }
    }
    return count;
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
    this.updateAchievementProgress();
  }
}
