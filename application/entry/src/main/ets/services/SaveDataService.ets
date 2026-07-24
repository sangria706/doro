import {
  AchievementItem,
  DdlTask,
  FriendInfo,
  FriendJson,
  SaveData,
  TaskJson,
  cloneDefaultAchievements
} from '../pages/AppState';
import { CatAffection } from '../pages/CatNPCSystem';

/** 与原 Index 一致：doro_save / cat_affections */
const KEY_DORO_SAVE: string = 'doro_save';
const KEY_CAT_AFFECTIONS: string = 'cat_affections';

export interface SaveSnapshot {
  tasks: DdlTask[];
  focusMinutesToday: number;
  focusCount: number;
  coins: number;
  mood: number;
  satiety: number;
  syncVersion: number;
  friends: FriendInfo[];
  catAffections: Record<string, CatAffection>;
  achievements: AchievementItem[];
}

export interface LoadDataResult {
  hasMainSave: boolean;
  hasCatSave: boolean;
  snapshot: SaveSnapshot;
  feedback: string;
}

export interface SyncLocalResult {
  syncVersion: number;
  feedback: string;
}

export class SaveDataService {
  /**
   * 加载 doro_save、cat_affections；空串/解析失败兜底。
   * 旧档无 achievements 时自动赋默认测试成就列表。
   */
  loadData(current: SaveSnapshot): LoadDataResult {
    PersistentStorage.persistProp(KEY_DORO_SAVE, '');
    PersistentStorage.persistProp(KEY_CAT_AFFECTIONS, '');

    const snapshot: SaveSnapshot = this.cloneSnapshot(current);
    let hasMainSave: boolean = false;
    let hasCatSave: boolean = false;

    const raw: Object | undefined = AppStorage.get(KEY_DORO_SAVE) as Object | undefined;
    const json: string = raw !== undefined && raw !== null ? raw as string : '';
    if (json.length > 0) {
      try {
        const data: SaveData = JSON.parse(json) as SaveData;
        if (data !== null && data !== undefined) {
          hasMainSave = true;
          if (data.tasks !== undefined && data.tasks !== null) {
            snapshot.tasks = this.mapTasksFromJson(data.tasks);
          }
          if (data.focusMinutesToday !== undefined) {
            snapshot.focusMinutesToday = data.focusMinutesToday;
          }
          if (data.focusCount !== undefined) {
            snapshot.focusCount = data.focusCount;
          }
          if (data.coins !== undefined) {
            snapshot.coins = data.coins;
          }
          if (data.mood !== undefined) {
            snapshot.mood = data.mood;
          }
          if (data.satiety !== undefined) {
            snapshot.satiety = data.satiety;
          }
          if (data.syncVersion !== undefined) {
            snapshot.syncVersion = data.syncVersion;
          }
          if (data.friends !== undefined && data.friends !== null) {
            snapshot.friends = this.mapFriendsFromJson(data.friends);
          }
          if (data.achievements !== undefined && data.achievements !== null && data.achievements.length > 0) {
            snapshot.achievements = this.cloneAchievementList(data.achievements);
          } else {
            snapshot.achievements = cloneDefaultAchievements();
          }
        }
      } catch (_e) {
        hasMainSave = false;
        snapshot.achievements = cloneDefaultAchievements();
      }
    } else {
      snapshot.achievements = cloneDefaultAchievements();
    }

    const affRaw: Object | undefined = AppStorage.get(KEY_CAT_AFFECTIONS) as Object | undefined;
    const affJson: string = affRaw !== undefined && affRaw !== null ? affRaw as string : '';
    if (affJson.length > 0) {
      try {
        const affs: CatAffection[] = JSON.parse(affJson) as CatAffection[];
        if (affs !== null && affs !== undefined) {
          hasCatSave = true;
          snapshot.catAffections = this.mapCatAffectionsFromArray(affs, snapshot.catAffections);
        }
      } catch (_e) {
        hasCatSave = false;
      }
    }

    return {
      hasMainSave: hasMainSave,
      hasCatSave: hasCatSave,
      snapshot: snapshot,
      feedback: ''
    };
  }

  /**
   * 打包任务、好友、猫咪好感、资源、成就写入 AppStorage。
   */
  saveData(snapshot: SaveSnapshot): void {
    PersistentStorage.persistProp(KEY_DORO_SAVE, '');
    PersistentStorage.persistProp(KEY_CAT_AFFECTIONS, '');

    const taskArray: TaskJson[] = this.mapTasksToJson(snapshot.tasks);
    const friendArray: FriendJson[] = this.mapFriendsToJson(snapshot.friends);
    const affs: CatAffection[] = this.packCatAffections(snapshot.catAffections);
    const achievementList: AchievementItem[] = this.cloneAchievementList(snapshot.achievements);

    const data: SaveData = {
      tasks: taskArray,
      focusMinutesToday: snapshot.focusMinutesToday,
      focusCount: snapshot.focusCount,
      coins: snapshot.coins,
      mood: snapshot.mood,
      satiety: snapshot.satiety,
      syncVersion: snapshot.syncVersion,
      friends: friendArray,
      achievements: achievementList
    };

    AppStorage.set(KEY_DORO_SAVE, JSON.stringify(data));
    AppStorage.set(KEY_CAT_AFFECTIONS, JSON.stringify(affs));
  }

  /**
   * 版本号 +1、更新反馈文案、落盘。
   */
  syncLocalChange(snapshot: SaveSnapshot, text: string): SyncLocalResult {
    const nextVersion: number = snapshot.syncVersion + 1;
    const next: SaveSnapshot = this.cloneSnapshot(snapshot);
    next.syncVersion = nextVersion;
    this.saveData(next);
    return {
      syncVersion: nextVersion,
      feedback: text
    };
  }

  bumpSyncVersion(syncVersion: number): number {
    return syncVersion + 1;
  }

  private mapTasksToJson(tasks: DdlTask[]): TaskJson[] {
    const taskArray: TaskJson[] = [];
    for (let i: number = 0; i < tasks.length; i++) {
      const t: DdlTask = tasks[i];
      const tj: TaskJson = {
        id: t.id,
        title: t.title,
        deadline: t.deadline,
        difficulty: t.difficulty,
        progress: t.progress,
        done: t.done
      };
      taskArray.push(tj);
    }
    return taskArray;
  }

  private mapTasksFromJson(list: TaskJson[]): DdlTask[] {
    const result: DdlTask[] = [];
    for (let i: number = 0; i < list.length; i++) {
      const td: TaskJson = list[i];
      result.push(new DdlTask(td.id, td.title, td.deadline, td.difficulty, td.progress, td.done));
    }
    return result;
  }

  private mapFriendsToJson(friends: FriendInfo[]): FriendJson[] {
    const friendArray: FriendJson[] = [];
    for (let i: number = 0; i < friends.length; i++) {
      const f: FriendInfo = friends[i];
      const fj: FriendJson = {
        id: f.id,
        name: f.name,
        doroName: f.doroName,
        isOnline: f.isOnline
      };
      friendArray.push(fj);
    }
    return friendArray;
  }

  private mapFriendsFromJson(list: FriendJson[]): FriendInfo[] {
    const result: FriendInfo[] = [];
    for (let i: number = 0; i < list.length; i++) {
      const fj: FriendJson = list[i];
      result.push(new FriendInfo(fj.id, fj.name, fj.doroName, fj.isOnline));
    }
    return result;
  }

  private packCatAffections(map: Record<string, CatAffection>): CatAffection[] {
    const affs: CatAffection[] = [];
    const keys: string[] = Object.keys(map);
    for (let i: number = 0; i < keys.length; i++) {
      const aff: CatAffection | undefined = map[keys[i]];
      if (aff !== undefined) {
        affs.push(aff);
      }
    }
    return affs;
  }

  private mapCatAffectionsFromArray(
    affs: CatAffection[],
    base: Record<string, CatAffection>
  ): Record<string, CatAffection> {
    const next: Record<string, CatAffection> = base;
    for (let i: number = 0; i < affs.length; i++) {
      const aff: CatAffection = affs[i];
      if (aff !== undefined && aff.npcId !== undefined) {
        next[aff.npcId] = aff;
      }
    }
    return next;
  }

  private cloneAchievementList(source: AchievementItem[]): AchievementItem[] {
    if (source === undefined || source === null || source.length === 0) {
      return cloneDefaultAchievements();
    }
    const result: AchievementItem[] = [];
    for (let i: number = 0; i < source.length; i++) {
      const item: AchievementItem = source[i];
      result.push({
        id: item.id,
        name: item.name,
        desc: item.desc,
        completed: item.completed === true,
        claimed: item.claimed === true,
        rewardGems: item.rewardGems !== undefined ? item.rewardGems : 5,
        rewardCoins: item.rewardCoins !== undefined ? item.rewardCoins : 20
      });
    }
    return result;
  }

  private cloneSnapshot(source: SaveSnapshot): SaveSnapshot {
    const tasks: DdlTask[] = [];
    for (let i: number = 0; i < source.tasks.length; i++) {
      const t: DdlTask = source.tasks[i];
      tasks.push(new DdlTask(t.id, t.title, t.deadline, t.difficulty, t.progress, t.done));
    }
    const friends: FriendInfo[] = [];
    for (let i: number = 0; i < source.friends.length; i++) {
      const f: FriendInfo = source.friends[i];
      friends.push(new FriendInfo(f.id, f.name, f.doroName, f.isOnline));
    }
    const catAffections: Record<string, CatAffection> = {};
    const keys: string[] = Object.keys(source.catAffections);
    for (let i: number = 0; i < keys.length; i++) {
      const aff: CatAffection | undefined = source.catAffections[keys[i]];
      if (aff !== undefined) {
        catAffections[keys[i]] = aff;
      }
    }
    return {
      tasks: tasks,
      focusMinutesToday: source.focusMinutesToday,
      focusCount: source.focusCount,
      coins: source.coins,
      mood: source.mood,
      satiety: source.satiety,
      syncVersion: source.syncVersion,
      friends: friends,
      catAffections: catAffections,
      achievements: this.cloneAchievementList(source.achievements)
    };
  }
}
