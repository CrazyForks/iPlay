import { router } from '../../../module/Router'
import { store, AppThemeMode } from '../store/Store'
import web_webview from '@ohos.web.webview'
import { FontIcon } from '../view/FontIcon'
import { IconDef } from '../view/IconDef'

@Builder
export function PageBuilder() {
  TermsOfServicePage()
}

@Entry
@Component
struct TermsOfServicePage {
  @State isDarkMode: boolean = store.themeMode === AppThemeMode.DARK
  webController: web_webview.WebviewController = new web_webview.WebviewController()
  
  build() {
    NavDestination() {
      Column() {
        Web({ src: 'https://app-doc.ourfor.top/statement/basic/index.html', controller: this.webController })
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
    .title("服务条款")
    .menus([
      {
        value: "退出",
        icon: $r('app.media.close'),
        action: () => {
          router.popPage()
        }
      },
    ])
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
