import { router } from '../../../module/Router'
import { AppThemeMode, store } from '../store/Store'
import window from '@ohos.window'
import promptAction from '@ohos.promptAction'


@Builder
export function PageBuilder() {
  AppearanceSettingsPage()
}

@Entry
@Component
export struct AppearanceSettingsPage {
  @State selectedMode: AppThemeMode = store.themeMode;
  
  aboutToAppear() {
    // 获取当前的主题模式设置
    this.selectedMode = store.themeMode;
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopEnd }) {
        Column() {
          // 导航栏
          Row() {
            Button() {
              Image($r('app.media.back'))
                .width(24)
                .height(24)
            }
            .type(ButtonType.Normal)
            .backgroundColor(Color.Transparent)
            .onClick(() => {
              router.popPage()
            })

            Text("外观设置")
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .flexGrow(1)
              .textAlign(TextAlign.Center)

            // 右侧空按钮，保持对称
            Button() {
              Image($r('app.media.back'))
                .width(24)
                .height(24)
                .opacity(0)
            }
            .type(ButtonType.Normal)
            .backgroundColor(Color.Transparent)
          }
          .width('100%')
          .height(50)
          .padding({ left: 10, right: 10 })

          // 主题模式选择
          Column() {
            Text("主题模式")
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .margin({ top: 20, bottom: 16 })
              .alignSelf(ItemAlign.Start)

            // 浅色模式
            Row() {
              Row() {
                Image($r('app.media.light_mode'))
                  .width(24)
                  .height(24)
                  .margin({ right: 16 })

                Text("浅色模式")
                  .fontSize(16)
              }
              .flexGrow(1)

              Radio({ value: 'light', group: 'themeMode' })
                .checked(this.selectedMode === AppThemeMode.LIGHT)
                .onChange((isChecked: boolean) => {
                  if (isChecked) {
                    this.selectedMode = AppThemeMode.LIGHT;
                    this.applyThemeMode();
                  }
                })
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Color.White)
            .borderRadius(8)
            .margin({ bottom: 8 })

            // 深色模式
            Row() {
              Row() {
                Image($r('app.media.dark_mode'))
                  .width(24)
                  .height(24)
                  .margin({ right: 16 })

                Text("深色模式")
                  .fontSize(16)
              }
              .flexGrow(1)

              Radio({ value: 'dark', group: 'themeMode' })
                .enabled(false)
                .checked(this.selectedMode === AppThemeMode.DARK)
                .onChange((isChecked: boolean) => {
                  if (isChecked) {
                    this.selectedMode = AppThemeMode.DARK;
                    this.applyThemeMode();
                  }
                })
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Color.White)
            .borderRadius(8)
            .margin({ bottom: 8 })

            // 跟随系统
            Row() {
              Row() {
                Image($r('app.media.auto_mode'))
                  .width(24)
                  .height(24)
                  .margin({ right: 16 })

                Text("跟随系统")
                  .fontSize(16)
              }
              .flexGrow(1)

              Radio({ value: 'auto', group: 'themeMode' })
                .checked(this.selectedMode === AppThemeMode.AUTO)
                .onChange((isChecked: boolean) => {
                  if (isChecked) {
                    this.selectedMode = AppThemeMode.AUTO;
                    this.applyThemeMode();
                  }
                })
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Color.White)
            .borderRadius(8)
          }
          .width('100%')
          .padding({ left: 16, right: 16 })
        }
        .width('100%')
        .height('100%')
      }
    }
  }
  
  // 应用主题模式
  applyThemeMode() {
    // 保存设置
    store.setThemeMode(this.selectedMode);
    
    // 根据选择的模式应用主题
    try {
      let isDark = false;
      
      if (this.selectedMode === AppThemeMode.AUTO) {
        // 这里应该检查系统主题，但是模拟器可能没有相关API
        // 所以这里只是一个示例
        isDark = false;  // 默认使用浅色模式
      } else {
        isDark = this.selectedMode === AppThemeMode.DARK;
      }
      
      // 显示提示
      promptAction.showToast({
        message: isDark ? '已切换到深色模式' : '已切换到浅色模式',
        duration: 2000
      });
      
      // 实际应用中，这里可以使用相关API切换主题
      // 例如使用window.getLastWindow()获取窗口然后设置窗口的属性
    } catch (error) {
      console.error('应用主题失败:', error);
    }
  }
}
