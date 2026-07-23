import { DdlTask, ShopItem, InventoryItem, FriendInfo, ChatMessage } from '../AppState';
import { DialogueOption } from '../DialogueSystem';
import { CatBento, BENTO_LIST } from '../CatNPCSystem';

@Component
export struct FeedPickerOverlay {
  @Prop foods: InventoryItem[] = [];
  onFeed?: (index: number) => void;
  onClose?: () => void;

  build() {
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
              .onClick(() => {
                if (this.onFeed !== undefined) {
                  this.onFeed(index);
                }
              })
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
            if (this.onClose !== undefined) {
              this.onClose();
            }
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
}

@Component
export struct DressPickerOverlay {
  @Prop outfits: InventoryItem[] = [];
  onDress?: (index: number) => void;
  onClose?: () => void;

  build() {
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
              .onClick(() => {
                if (this.onDress !== undefined) {
                  this.onDress(index);
                }
              })
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
            if (this.onClose !== undefined) {
              this.onClose();
            }
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
}

@Component
export struct FocusCompleteOverlay {
  @Prop focusDuration: number = 0;
  @Prop selectedTaskId: number = -1;
  @Prop focusMarkDdlDone: boolean = false;
  onContinue5?: () => void;
  onContinue10?: () => void;
  onEnd?: () => void;
  onToggle?: (value: boolean) => void;
  onClose?: () => void;

  build() {
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
                if (this.onToggle !== undefined) {
                  this.onToggle(value);
                }
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
            .onClick(() => {
              if (this.onContinue5 !== undefined) {
                this.onContinue5();
              }
            })
          Button('继续专注 10 分')
            .layoutWeight(1)
            .height(44)
            .fontSize(13)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
            .backgroundColor('#BBA6E8')
            .borderRadius(22)
            .onClick(() => {
              if (this.onContinue10 !== undefined) {
                this.onContinue10();
              }
            })
        }
        Button('结束专注')
          .width('100%')
          .height(48)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
          .backgroundColor('#FF8F9F')
          .borderRadius(24)
          .onClick(() => {
            if (this.onEnd !== undefined) {
              this.onEnd();
            }
          })
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
}

@Component
export struct DdlPickerOverlay {
  @Prop tasks: DdlTask[] = [];
  @Prop selectedTaskId: number = -1;
  @Prop focusCustomName: string = '';
  onSelect?: (taskId: number) => void;
  onNameChange?: (value: string) => void;
  onClose?: () => void;

  private getTaskId(task: DdlTask): string {
    return 'ddl-' + task.id.toString();
  }

  build() {
    Column() {
      Column({ space: 10 }) {
        Text('选择关联DDL')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#5A403A')
        Scroll() {
          Column({ space: 8 }) {
            ForEach(this.tasks, (task: DdlTask) => {
              Button(task.title)
                .width('100%')
                .height(42)
                .fontSize(14)
                .fontColor(this.selectedTaskId === task.id ? '#FFFFFF' : '#5A403A')
                .backgroundColor(this.selectedTaskId === task.id ? '#FF8F9F' : '#FFF4F7')
                .borderRadius(21)
                .onClick(() => {
                  if (this.onSelect !== undefined) {
                    this.onSelect(task.id);
                  }
                })
            }, (task: DdlTask) => this.getTaskId(task))
            Button('自定义专注（无DDL）')
              .width('100%')
              .height(42)
              .fontSize(14)
              .fontColor(this.selectedTaskId === -1 ? '#FFFFFF' : '#5A403A')
              .backgroundColor(this.selectedTaskId === -1 ? '#FF8F9F' : '#FFF4F7')
              .borderRadius(21)
              .onClick(() => {
                if (this.onSelect !== undefined) {
                  this.onSelect(-1);
                }
              })
            if (this.selectedTaskId === -1) {
              TextInput({ placeholder: '输入专注名称...', text: this.focusCustomName })
                .height(42)
                .fontSize(14)
                .backgroundColor('#FFF4F7')
                .borderRadius(21)
                .onChange((value: string) => {
                  if (this.onNameChange !== undefined) {
                    this.onNameChange(value);
                  }
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
            if (this.onClose !== undefined) {
              this.onClose();
            }
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
}

@Component
export struct ShopAsOverlay {
  @Prop shopTab: number = 0;
  @Prop coins: number = 0;
  @Prop shopItems: ShopItem[] = [];
  onBuy?: (index: number) => void;
  onTabChange?: (index: number) => void;
  onClose?: () => void;

  build() {
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
              if (this.onClose !== undefined) {
                this.onClose();
              }
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
            ForEach(this.shopItems, (item: ShopItem, globalIndex: number) => {
              this.ShopCard(item, globalIndex)
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
        if (this.onTabChange !== undefined) {
          this.onTabChange(index);
        }
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
              if (this.onBuy !== undefined) {
                this.onBuy(globalIndex);
              }
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
      if (item.category === 'furniture') {
        Text('效果：舒适度+')
          .fontSize(12)
          .fontColor('#F5A6C8')
          .width('100%')
      }
    }
    .width('100%')
    .padding(14)
    .backgroundColor('#FFFFFC')
    .borderRadius(20)
  }
}

@Component
export struct SearchFriendOverlay {
  @Prop searchKeyword: string = '';
  @Prop searchResults: FriendInfo[] = [];
  @Prop friends: FriendInfo[] = [];
  onKeywordChange?: (value: string) => void;
  onSearch?: () => void;
  onAdd?: (friendId: number) => void;
  onClose?: () => void;

  private isAlreadyFriend(friendId: number): boolean {
    for (let i: number = 0; i < this.friends.length; i++) {
      if (this.friends[i].id === friendId) {
        return true;
      }
    }
    return false;
  }

  build() {
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
            if (this.onKeywordChange !== undefined) {
              this.onKeywordChange(value);
            }
          })
        Button('搜索')
          .width('100%')
          .height(42)
          .fontSize(14)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
          .backgroundColor('#FF8F9F')
          .borderRadius(21)
          .onClick(() => {
            if (this.onSearch !== undefined) {
              this.onSearch();
            }
          })
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
            if (this.isAlreadyFriend(user.id)) {
              Text('已是好友')
                .fontSize(12)
                .fontColor('#CBBFBC')
                .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            } else {
              Button('添加好友')
                .height(34)
                .fontSize(12)
                .fontColor('#FFFFFF')
                .fontWeight(FontWeight.Bold)
                .backgroundColor('#8BC8A5')
                .borderRadius(17)
                .onClick(() => {
                  if (this.onAdd !== undefined) {
                    this.onAdd(user.id);
                  }
                })
            }
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
            if (this.onClose !== undefined) {
              this.onClose();
            }
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
}

@Component
export struct ProfileOverlay {
  @Prop profileName: string = '';
  @Prop level: number = 1;
  @Prop syncVersion: number = 0;
  @Prop coins: number = 0;
  @Prop gems: number = 0;
  @Prop focusMinutesToday: number = 0;
  @Prop focusCount: number = 0;
  onNameChange?: (value: string) => void;
  onSave?: () => void;
  onClose?: () => void;

  build() {
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
              if (this.onClose !== undefined) {
                this.onClose();
              }
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
                if (this.onNameChange !== undefined) {
                  this.onNameChange(value);
                }
              })
          }
          .width('100%')
          this.UserRow('等级', 'Lv.' + this.level.toString())
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
            if (this.onSave !== undefined) {
              this.onSave();
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
}

@Component
export struct DialogueOverlay {
  @Prop dialogueSpeakerEmoji: string = '';
  @Prop dialogueSpeakerName: string = '';
  @Prop dialogueTypewriterText: string = '';
  @Prop dialogueTypewriterFull: string = '';
  @Prop dialogueOptions: DialogueOption[] = [];
  @Prop dialogueEffectText: string = '';
  @Prop dialogueEffectColor: string = '#FF8F9F';
  @Prop dialogueShowOptions: boolean = false;
  onOptionSelect?: (optionIndex: number) => void;
  onContinue?: () => void;
  onClose?: () => void;

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#00000000')
        .onClick(() => {
          if (!this.dialogueShowOptions && this.dialogueTypewriterText === this.dialogueTypewriterFull) {
            if (this.onContinue !== undefined) {
              this.onContinue();
            }
          } else if (this.onClose !== undefined) {
            this.onClose();
          }
        })

      Column({ space: 10 }) {
        Row() {
          Button('×')
            .width(28)
            .height(28)
            .fontSize(14)
            .fontColor('#9B7D76')
            .backgroundColor('#FFF4F7')
            .borderRadius(14)
            .onClick(() => {
              if (this.onClose !== undefined) {
                this.onClose();
              }
            })
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
                .onClick(() => {
                  if (this.onOptionSelect !== undefined) {
                    this.onOptionSelect(index);
                  }
                })
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
  }
}

@Component
export struct BentoPickerOverlay {
  @Prop catName: string = '';
  @Prop likedBento: string[] = [];
  @Prop coins: number = 0;
  @Prop bentoList: CatBento[] = [];
  onSend?: (bentoId: string) => void;
  onClose?: () => void;

  build() {
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
              if (this.onClose !== undefined) {
                this.onClose();
              }
            })
        }
        .width('100%')

        Text('💡 ' + this.catName + '喜欢：' + this.likedBento.join('、'))
          .fontSize(13)
          .fontColor('#8BC8A5')
          .width('100%')
          .padding(10)
          .backgroundColor('#F0FFF4')
          .borderRadius(12)

        Text('当前余额：' + this.coins.toString() + ' 三叶草币')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FF7F95')
          .width('100%')
          .textAlign(TextAlign.Center)

        ForEach(this.bentoList, (bento: CatBento) => {
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
                if (this.onSend !== undefined) {
                  this.onSend(bento.id);
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
}

@Component
export struct BentoResultOverlay {
  @Prop bentoReactionEmoji: string = '';
  @Prop bentoReactionText: string = '';
  @Prop catAffectionFloat: string = '';
  onClose?: () => void;

  build() {
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
            if (this.onClose !== undefined) {
              this.onClose();
            }
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
}

@Component
export struct LevelUpOverlay {
  @Prop levelUpText: string = '';
  onClose?: () => void;

  build() {
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
            if (this.onClose !== undefined) {
              this.onClose();
            }
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
}
