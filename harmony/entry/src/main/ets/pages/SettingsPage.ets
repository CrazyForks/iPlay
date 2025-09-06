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

            Text("设置")
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

          // 设置项列表
          List() {
            // 外观设置项
            ListItem() {
              this.SettingsItem("外观", "设置应用主题和显示模式", () => {
                router.pushPage("pages/AppearanceSettingsPage", {})
              })
            }

            // 可以添加更多设置项...
          }
          .width('100%')
          .layoutWeight(1)
        }
        .width('100%')
        .height('100%')
      }
    }
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
      
      Image($r('app.media.arrow_right'))
        .width(20)
        .height(20)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .margin({top: 8, bottom: 8})
    .onClick(onClick)
  }
}
