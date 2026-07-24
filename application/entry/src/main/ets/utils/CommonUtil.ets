import { DdlTask, FriendInfo, InventoryItem } from '../pages/AppState';

export class CommonUtil {
  static clamp(value: number): number {
    if (value < 0) {
      return 0;
    }
    if (value > 100) {
      return 100;
    }
    return value;
  }

  static pad(value: number): string {
    return value < 10 ? '0' + value.toString() : value.toString();
  }

  static cloneArray<T>(source: T[]): T[] {
    const result: T[] = [];
    for (let i: number = 0; i < source.length; i++) {
      result.push(source[i]);
    }
    return result;
  }

  static updateTaskArray(tasks: DdlTask[], updater: (task: DdlTask, index: number) => DdlTask): DdlTask[] {
    const result: DdlTask[] = [];
    for (let i: number = 0; i < tasks.length; i++) {
      result.push(updater(tasks[i], i));
    }
    return result;
  }

  static updateItemArray(items: InventoryItem[], updater: (item: InventoryItem, index: number) => InventoryItem): InventoryItem[] {
    const result: InventoryItem[] = [];
    for (let i: number = 0; i < items.length; i++) {
      result.push(updater(items[i], i));
    }
    return result;
  }

  static getRandomNickname(): string {
    const names: string[] = ['樱桃糯米', '桃雾同学', '云朵布丁', '小莓计划家', '奶油星星'];
    return names[Math.floor(Math.random() * names.length)];
  }

  static getRandomDoroTouchWords(): string {
    const words: string[] = [
      '嘿嘿，被你发现我在等你。',
      '爱心粒子冒出来了，今日心情 +1。',
      'Doro 跳了一下，然后认真坐好。',
      '一起把最难的那件事拆小一点吧。'
    ];
    return words[Math.floor(Math.random() * words.length)];
  }

  static getNpcRealNameById(id: string): string {
    if (id === 'anxiety_line_cat') {
      return '小白';
    }
    if (id === 'elegant_cow_cat') {
      return '小沐';
    }
    if (id === 'chill_orange_cat') {
      return '橘宝';
    }
    if (id === 'strict_black_cat') {
      return '墨墨';
    }
    if (id === 'shy_white_cat') {
      return '小雪';
    }
    if (id === 'talkative_calico_cat') {
      return '花花';
    }
    if (id === 'clumsy_fold_cat') {
      return '团子';
    }
    if (id === 'grumpy_munchkin_cat') {
      return '短短';
    }
    if (id === 'artistic_siamese_cat') {
      return '小诗';
    }
    if (id === 'greedy_garfield_cat') {
      return '胖胖';
    }
    if (id === 'tsundere_ragdoll_cat') {
      return '绵绵';
    }
    return '暖暖';
  }
}
