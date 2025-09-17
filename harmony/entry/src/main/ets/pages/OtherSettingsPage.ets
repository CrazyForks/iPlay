import { router } from '../../../module/Router';
import { AppThemeMode, store } from '../store/Store'


@Builder
export function PageBuilder() {
  OtherSettingsPage()
}

@Entry
@Component
export struct OtherSettingsPage {
  aboutToAppear() {
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopEnd }) {
        Column() {
          List() {
            ListItem() {
              this.SettingsItem("服务协议", "查阅服务协议具体内容", () => {
                router.pushPage("pages/TermsOfServicePage", {})
              })
            }

            ListItem() {
              this.SettingsItem("隐私政策", "查阅隐私政策具体内容", () => {
                router.pushPage("pages/PrivacyPolicyPage", {})
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
    .title("其他")
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
            .margin({ top: 4 })
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
    .margin({top: 8, bottom: 2})
    .onClick(onClick)
  }
}
