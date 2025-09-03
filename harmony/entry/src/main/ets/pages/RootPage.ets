import { router } from "../../../module/Router"
import { store } from "../store/Store"
import { Index as HomePage } from './HomePage'
import { Index as StarPage } from './StarPage'
import { Index as SearchPage } from './SearchPage'


@Entry
@Component
struct Index {
  @State currentIndex: number = 1;
  private tabsController: TabsController = new TabsController();

  @Builder
  TabBuilder(title: string, index: number, selectedImg: Resource, normalImg: Resource) {
    Column() {
      Image(this.currentIndex === index ? selectedImg : normalImg)
        .width($r('app.float.mainPage_baseTab_size'))
        .height($r('app.float.mainPage_baseTab_size'))
        .margin({ top: '8vp'})
        .opacity(this.currentIndex === index ? 1.0 : 0.85)
      Text(title)
        .margin({ top: $r('app.float.mainPage_baseTab_top') })
        .fontSize($r('app.float.main_tab_fontSize'))
        .fontColor(this.currentIndex === index ? Color.Black : Color.Gray)
    }
    .justifyContent(FlexAlign.Center)
    .height($r('app.float.mainPage_barHeight'))
    .width("100%")
    .onClick(() => {
      this.currentIndex = index;
      this.tabsController.changeIndex(this.currentIndex);
    })
  }

  build() {
    Tabs({
      barPosition: BarPosition.End,
      index: 1,
      controller: this.tabsController
    }) {
      TabContent() {
        SearchPage()
      }
      .padding({ left: $r('app.float.mainPage_padding'), right: $r('app.float.mainPage_padding') })
      .tabBar(this.TabBuilder("搜索", 0, $r('app.media.search'), $r('app.media.search')))

      TabContent() {
        HomePage()
      }
      .padding({ left: $r('app.float.mainPage_padding'), right: $r('app.float.mainPage_padding') })
      .tabBar(this.TabBuilder("主页", 1, $r('app.media.home'), $r('app.media.home')))

      TabContent() {
        StarPage()
      }
      .padding({ left: $r('app.float.mainPage_padding'), right: $r('app.float.mainPage_padding') })
      .tabBar(this.TabBuilder("收藏", 2, $r('app.media.star'), $r('app.media.star')))
    }
    .width("100%")
    .backgroundColor(Color.White)
    .barHeight($r('app.float.mainPage_barHeight'))
    .barMode(BarMode.Fixed)
    .onChange((index: number) => {
      this.currentIndex = index;
    })
  }

  aboutToAppear(): void {
    store.load()
  }
}