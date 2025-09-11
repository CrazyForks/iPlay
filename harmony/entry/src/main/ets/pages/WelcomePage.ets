import { router } from '../../../module/Router'
import { store, AppThemeMode } from '../store/Store'
import { common, Want } from '@kit.AbilityKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { kv } from '../../../module/KVStorage'

@Builder
export function PageBuilder() {
  WelcomePage()
}

@Entry
@Component
struct WelcomePage {
  @State agreeTerm: boolean = false
  @State isDarkMode: boolean = store.themeMode === AppThemeMode.DARK

  private context = getContext(this) as common.UIAbilityContext

  // 打开URL的方法
  openUrl(url: string) {
    try {
      let want: Want = {
        action: 'ohos.want.action.viewData',
        entities: ['entity.system.browsable'],
        uri: url,
      }
      this.context.startAbility(want)
        .then(() => {
          console.info('Open browser successfully')
        })
        .catch((err: BusinessError) => {
          console.error('Failed to open browser. Error code: ' + err.code + ', message: ' + err.message)
        })
    } catch (error) {
      console.error('An unexpected error occurred. Error code: ' + error.code + ', message: ' + error.message)
    }
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column() {
        // 顶部空间，占据页面上半部分
        Blank()
          .layoutWeight(1)
        
        // 中间图标部分
        Column({ space: 20 }) {
          // App图标
          Image($r('app.media.foreground'))
            .width(150)
            .height(150)
            .borderRadius(24)
            .objectFit(ImageFit.Contain)
          
          // App名称
          Text($r('app.string.app_name'))
            .fontSize(32)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.isDarkMode ? Color.White : Color.Black)
        }
        .layoutWeight(2)
        .justifyContent(FlexAlign.Center)
        
        // 底部部分，包含协议同意和按钮
        Column({ space: 20 }) {
          // 协议同意部分
          Row() {
            Checkbox()
              .select(this.agreeTerm)
              .onChange(v => {
                this.agreeTerm = v
              })
              .selectedColor(this.isDarkMode ? '#7EC0EE' : '#0A84FF')
            
            Text("已阅读并同意")
              .fontSize(14)
              .fontColor(this.isDarkMode ? Color.White : Color.Black)
            
            Text("服务条款")
              .fontSize(14)
              .fontColor(this.isDarkMode ? '#7EC0EE' : '#0A84FF')
              .onClick(() => {
                router.pushPage("pages/TermsOfServicePage", {})
              })
            
            Text("和")
              .fontSize(14)
              .fontColor(this.isDarkMode ? Color.White : Color.Black)
            
            Text("隐私政策")
              .fontSize(14)
              .fontColor(this.isDarkMode ? '#7EC0EE' : '#0A84FF')
              .onClick(() => {
                router.pushPage("pages/PrivacyPolicyPage", {})
              })
          }
          .margin({ bottom: 20 })
          
          // 开始使用按钮
          Button("开始使用")
            .width('90%')
            .height(50)
            .borderRadius(25)
            .backgroundColor(this.agreeTerm ? 
              (this.isDarkMode ? '#7EC0EE' : '#0A84FF') : 
              (this.isDarkMode ? '#333333' : '#CCCCCC'))
            .fontColor(Color.White)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .enabled(this.agreeTerm)
            .onClick(() => {
              if (this.agreeTerm) {
                // 导航到登录页面
                kv.set("@setting/agree_terms", true)
                router.replacePage("pages/RootPage", {})
              } else {
                // 提示用户需要同意协议
                this.getUIContext().getPromptAction().showToast({
                  message: "请先同意服务条款和隐私政策",
                  duration: 2000,
                  bottom: '50%'
                })
              }
            })
        }
        .layoutWeight(1.5)
        .width('100%')
        .justifyContent(FlexAlign.End)
        .padding({ bottom: 50 })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.isDarkMode ? '#121212' : '#FFFFFF')
  }
  
  aboutToAppear() {
    // 检查主题模式
    this.isDarkMode = store.themeMode === AppThemeMode.DARK || 
      (store.themeMode === AppThemeMode.AUTO && this.getSystemColorMode() === 'dark')
    
    // 如果用户已经登录过，直接跳转到主页
    if (store.site) {
      // 直接跳转到主页
      setTimeout(() => {
        // router.replacePageWithUrl("pages/RootPage", {})
      }, 100)
    }
  }
  
  // 获取系统颜色模式
  getSystemColorMode(): string {
    // 在真实设备上，可以通过系统API获取
    // 这里提供一个简单实现，实际环境应该使用系统API
    return 'light' // 默认返回light模式
  }
}
