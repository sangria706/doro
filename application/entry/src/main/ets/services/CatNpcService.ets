import { ChatMessage } from '../pages/AppState';
import { CatAffection, CatBento, BentoResult, CatNPC, getAffectionLevel, getBentoReaction, getBentoById, getCatById, getDailyDialogue } from '../pages/CatNPCSystem';

export interface CatNpcServiceCallbacks {
  saveData: () => void;
  pad: (value: number) => string;
  closeCatDetail: () => void;
}

export interface CatNpcChatSelectionResult {
  chosenText: string;
  reply: string;
  replyTime: string;
}

export interface CatNpcBentoSelectionResult {
  gainedAffection: number;
  oldLevel: string;
  newLevel: string;
  bentoReaction: BentoResult;
  showLevelUp: boolean;
  showGiftReward: boolean;
}

export interface CatNpcBentoResultState {
  bentoReactionText: string;
  bentoReactionEmoji: string;
  catAffectionFloat: string;
  levelUpText: string;
  showBentoPicker: boolean;
  showBentoResult: boolean;
  showLevelUp: boolean;
}

export interface CatNpcVisitState {
  selectedCat: CatNPC | null;
  selectedCatAffection: number;
  selectedCatVisitCount: number;
  catGreetingText: string;
  catChatMessages: ChatMessage[];
  catChatShowOptions: boolean;
  catChatDone: boolean;
  showCatDetail: boolean;
}

export interface CatNpcBentoRequest {
  catId: string;
  bentoId: string;
}

export interface CatNpcChatRequest {
  optionIndex: number;
}

export class CatNpcService {
  private catAffections: Record<string, CatAffection> = {};
  private callbacks: CatNpcServiceCallbacks;

  constructor(catAffections: Record<string, CatAffection>, callbacks: CatNpcServiceCallbacks) {
    this.catAffections = catAffections;
    this.callbacks = callbacks;
  }

  getCatAffection(catId: string): number {
    const aff: CatAffection | undefined = this.catAffections[catId];
    if (aff !== undefined) {
      return aff.affection;
    }
    return 0;
  }

  visitCat(catId: string): CatNpcVisitState {
    const aff: CatAffection | undefined = this.catAffections[catId];
    const today: string = new Date().getFullYear().toString() + '-' + (new Date().getMonth() + 1).toString() + '-' + new Date().getDate().toString();
    let selectedCatAffection: number = 0;
    let selectedCatVisitCount: number = 0;
    if (aff !== undefined) {
      if (aff.lastVisitDate !== today) {
        aff.affection = aff.affection + 2;
        if (aff.affection > 100) {
          aff.affection = 100;
        }
        aff.visitCount += 1;
        aff.lastVisitDate = today;
        this.catAffections[catId] = aff;
        this.callbacks.saveData();
      }
      selectedCatAffection = aff.affection;
      selectedCatVisitCount = aff.visitCount;
    }
    const cat: CatNPC | null = getCatById(catId);
    let catGreetingText: string = '';
    let catChatMessages: ChatMessage[] = [];
    let showCatDetail: boolean = false;
    if (cat !== null) {
      const todayNum: number = new Date().getDate();
      catGreetingText = getDailyDialogue(cat, selectedCatAffection, todayNum);
      const now: Date = new Date();
      const time: string = this.callbacks.pad(now.getHours()) + ':' + this.callbacks.pad(now.getMinutes());
      catChatMessages = [];
      catChatMessages.push(new ChatMessage(false, catGreetingText, time));
      showCatDetail = true;
    }
    return {
      selectedCat: cat,
      selectedCatAffection: selectedCatAffection,
      selectedCatVisitCount: selectedCatVisitCount,
      catGreetingText: catGreetingText,
      catChatMessages: catChatMessages,
      catChatShowOptions: true,
      catChatDone: false,
      showCatDetail: showCatDetail
    };
  }

  sendCatChatOption(selectedCat: CatNPC, optionIndex: number, currentMessages: ChatMessage[]): CatNpcChatSelectionResult {
    const personality: string = selectedCat.personality;
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
    const time: string = this.callbacks.pad(now.getHours()) + ':' + this.callbacks.pad(now.getMinutes());
    const reply: string = this.getCatResponseToOption(selectedCat, optionIndex);
    currentMessages.push(new ChatMessage(true, chosenText, time));
    currentMessages.push(new ChatMessage(false, reply, time));
    return {
      chosenText: chosenText,
      reply: reply,
      replyTime: time
    };
  }

  sendBento(catId: string, bentoId: string, coins: number): CatNpcBentoResultState {
    const aff: CatAffection | undefined = this.catAffections[catId];
    const resultState: CatNpcBentoResultState = {
      bentoReactionText: '',
      bentoReactionEmoji: '',
      catAffectionFloat: '',
      levelUpText: '',
      showBentoPicker: false,
      showBentoResult: false,
      showLevelUp: false
    };
    if (aff === undefined) {
      return resultState;
    }
    const now: number = Date.now();
    if (now - aff.lastGiftTime < 86400000) {
      resultState.bentoReactionText = '今天已经送过了哦~明天再来吧！';
      resultState.bentoReactionEmoji = '😴';
      resultState.showBentoResult = true;
      return resultState;
    }
    const cat: CatNPC | null = getCatById(catId);
    if (cat === null) {
      return resultState;
    }
    const bento: CatBento | null = getBentoById(bentoId);
    if (bento === null) {
      return resultState;
    }
    if (coins < bento.price) {
      resultState.bentoReactionText = '三叶草币不够啦…先完成DDL攒钱吧！';
      resultState.bentoReactionEmoji = '😅';
      resultState.showBentoResult = true;
      return resultState;
    }
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
    this.catAffections[catId] = aff;
    this.callbacks.saveData();
    const bentoReaction: BentoResult = getBentoReaction(cat, bento.name);
    resultState.bentoReactionText = bentoReaction.text;
    resultState.bentoReactionEmoji = bentoReaction.emoji;
    resultState.catAffectionFloat = (gain > 0 ? '+' : '') + gain.toString();
    resultState.showBentoResult = true;
    const newLevel: string = getAffectionLevel(aff.affection);
    if (newLevel !== oldLevel) {
      resultState.levelUpText = '你和' + cat.name + '的关系升级为【' + newLevel + '】啦！';
      resultState.showLevelUp = true;
      if (aff.affection >= 80) {
        let hasGift: boolean = false;
        for (let i: number = 0; i < aff.receivedGifts.length; i++) {
          if (aff.receivedGifts[i] === cat.giftName) {
            hasGift = true;
          }
        }
        if (!hasGift) {
          aff.receivedGifts.push(cat.giftName);
          this.catAffections[catId] = aff;
          this.callbacks.saveData();
          resultState.bentoReactionText = cat.name + '送给你【' + cat.giftName + '】作为挚友信物！' + cat.giftEmoji;
          resultState.bentoReactionEmoji = '🎁';
        }
      }
    }
    // AchievementService.unlockAchievement("ach_cat_gift");
    return resultState;
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
}
