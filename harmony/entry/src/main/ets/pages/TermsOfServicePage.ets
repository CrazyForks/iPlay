import { router } from '../../../module/Router'
import { store, AppThemeMode } from '../store/Store'
import web_webview from '@ohos.web.webview'

@Entry
@Component
struct TermsOfServicePage {
  @State isDarkMode: boolean = store.themeMode === AppThemeMode.DARK
  webController: web_webview.WebviewController = new web_webview.WebviewController()
  
  build() {
    Column() {
      // 导航栏
      Row() {
        Button() {
          Image($r('app.media.back'))
            .width(24)
            .height(24)
            .fillColor(this.isDarkMode ? Color.White : Color.Black)
        }
        .type(ButtonType.Normal)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          router.popPage()
        })
        
        Text("服务条款")
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .flexGrow(1)
          .textAlign(TextAlign.Center)
          .fontColor(this.isDarkMode ? Color.White : Color.Black)
        
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
      .height(56)
      .padding({left: 16, right: 16})
      .backgroundColor(this.isDarkMode ? '#1C1C1E' : '#F5F5F5')
      
      // Web内容区域
      Web({ src: 'https://ourfor.top/raw/harmony/index.html', controller: this.webController })
        .width('100%')
        .layoutWeight(1)
        .onPageBegin(() => {
          console.info('Web page loading started')
        })
        .onPageEnd(() => {
          console.info('Web page loading completed')
        })
        .onErrorReceive((event) => {
          console.error(`Web page loading error: ${event}`)
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.isDarkMode ? '#121212' : '#FFFFFF')
  }
  
  aboutToAppear() {
    // 检查主题模式
    this.isDarkMode = store.themeMode === AppThemeMode.DARK || 
      (store.themeMode === AppThemeMode.AUTO && this.getSystemColorMode() === 'dark')
  }
  
  // 获取系统颜色模式
  getSystemColorMode(): string {
    return 'light' // 默认返回light模式
  }
}
