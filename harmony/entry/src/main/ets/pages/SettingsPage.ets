import { router } from '../../../module/Router'
import { store } from '../store/Store'

@Builder
export function PageBuilder() {
  SettingsPage()
}

@Entry
@Component
export struct SettingsPage {
  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopEnd }) {
        Column() {
          List() {
            // ListItem() {
            //   this.SettingsItem("外观", "设置应用主题和显示模式", () => {
            //     router.pushPage("pages/AppearanceSettingsPage", {})
            //   })
            // }

            ListItem() {
              this.SettingsItem("其他", "服务协议和隐私政策", () => {
                router.pushPage("pages/OtherSettingsPage", {})
              })
            }
          }
          .width('100%')
          .layoutWeight(1)
        }
        .width('100%')
        .height('100%')
      }
    }
    .title("设置")
  }
  
  @Builder
  SettingsItem(title: string, description: string, onClick: () => void) {
    Row() {
      Column() {
        Text(title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
        
        if (description) {
          Text(description)
            .fontSize(14)
            .fontColor(Color.Gray)
            .margin({top: 4})
        }
      }
      .alignItems(HorizontalAlign.Start)
      .flexGrow(1)
      
      Image($r('app.media.right'))
        .width(20)
        .height(20)
    }
    .width('100%')
    .padding(12)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .margin({top: 8, bottom: 4})
    .onClick(onClick)
  }
}
