import {
  AchievementItem,
  DEFAULT_TEST_ACHIEVEMENTS,
  cloneDefaultAchievements
} from './AppState';

export { AchievementItem };

export interface AchievementClaimResult {
  rewardGems: number;
  rewardCoins: number;
  showRewardPopup: boolean;
}

/** 与 AppState 默认测试成就同源，供 Index 初始化引用 */
export const TEST_ACHIEVEMENTS: AchievementItem[] = DEFAULT_TEST_ACHIEVEMENTS;

export function cloneAchievements(source: AchievementItem[]): AchievementItem[] {
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
      completed: item.completed,
      claimed: item.claimed,
      rewardGems: item.rewardGems,
      rewardCoins: item.rewardCoins
    });
  }
  return result;
}
