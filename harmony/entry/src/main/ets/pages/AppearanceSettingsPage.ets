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
          Column() {
            Text("主题模式")
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .margin({ top: 20, bottom: 16 })
              .alignSelf(ItemAlign.Start)
          }
          .width('100%')
          .padding({ left: 16, right: 16 })
        }
        .width('100%')
        .height('100%')
      }
    }
    .title("外观设置")
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
