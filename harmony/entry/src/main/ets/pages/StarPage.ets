import { MediaModel, nil, SiteModel } from '../../../api/iPlayDataSource'
import { context } from '../../../bean/BeanContainer'
import { Dict, Router, router } from '../../../module/Router'
import { store, AppThemeMode } from '../store/Store'
import { MediaCellView } from '../view/MediaCellView'

@Entry
@Component
export struct Index {
  @State medias: MediaModel[] | nil = null
  @State series: MediaModel[] | nil = null
  @State episodes: MediaModel[] | nil = null
  @State isLoading: boolean = false;
  @State path: NavPathStack = new NavPathStack()

  constructor() {
    super()
  }

  build() {
    Navigation(this.path) {
      Stack({ alignContent: Alignment.Center }) {
        Column() {
          Scroll() {
            Column() {
              if (this.medias?.length ?? 0 > 0) {
                Row() {
                  Text("喜爱的电影")
                    .fontSize(18)
                    .fontWeight(FontWeight.Medium)
                    .flexGrow(1)
                    .fontColor(store.themeMode === AppThemeMode.DARK ? Color.White : Color.Black)

                  Text("查看更多")
                    .flexShrink(0)
                    .fontSize(14)
                    .fontColor(store.themeMode === AppThemeMode.DARK ? '#7EC0EE' : '#0A84FF')
                }
                .width('100%')
                .padding({
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: 8
                })

                Grid() {
                  ForEach(this.medias, (item: MediaModel) => {
                    GridItem() {
                      MediaCellView({ model: item, layout: "2/3" })
                    }
                  }, (item: MediaModel) => item.id)
                }
                .columnsTemplate('1fr 1fr 1fr')
                .rowsGap(12)
                .columnsGap(12)
                .padding({ left: 16, right: 16, bottom: 16 })
              }

              if (this.series?.length ?? 0 > 0) {
                Row() {
                  Text("喜爱的剧集")
                    .fontSize(18)
                    .fontWeight(FontWeight.Medium)
                    .flexGrow(1)
                    .fontColor(store.themeMode === AppThemeMode.DARK ? Color.White : Color.Black)

                  // Text("查看更多")
                  //   .flexShrink(0)
                  //   .fontSize(14)
                  //   .fontColor(store.themeMode === AppThemeMode.DARK ? '#7EC0EE' : '#0A84FF')
                }
                .width('100%')
                .padding({
                  left: 16,
                  right: 16,
                  top: 8,
                  bottom: 8
                })

                Grid() {
                  ForEach(this.series, (item: MediaModel) => {
                    GridItem() {
                      MediaCellView({ model: item, layout: "2/3" })
                    }
                  }, (item: MediaModel) => item.id)
                }
                .columnsTemplate('1fr 1fr 1fr')
                .rowsGap(12)
                .columnsGap(12)
                .padding({ left: 16, right: 16, bottom: 16 })
              }

              if (this.episodes?.length ?? 0 > 0) {
                Row() {
                  Text("喜爱的剧集")
                    .fontSize(18)
                    .fontWeight(FontWeight.Medium)
                    .flexGrow(1)
                    .fontColor(store.themeMode === AppThemeMode.DARK ? Color.White : Color.Black)

                  Text("查看更多")
                    .flexShrink(0)
                    .fontSize(14)
                    .fontColor(store.themeMode === AppThemeMode.DARK ? '#7EC0EE' : '#0A84FF')
                }
                .width('100%')
                .padding({
                  left: 16,
                  right: 16,
                  top: 8,
                  bottom: 8
                })

                Grid() {
                  ForEach(this.episodes, (item: MediaModel) => {
                    GridItem() {
                      MediaCellView({ model: item, layout: "2/3" })
                    }
                  }, (item: MediaModel) => item.id)
                }
                .columnsTemplate('1fr 1fr 1fr')
                .rowsGap(12)
                .columnsGap(12)
                .padding({ left: 16, right: 16, bottom: 16 })
              }
            }
            .width('100%')
          }
          .align(Alignment.TopStart)
          .scrollBar(BarState.Auto)
          .edgeEffect(EdgeEffect.Spring)
          .width('100%')
          .layoutWeight(1) // This ensures the scroll area takes all remaining space

        }
        if (this.isLoading) {
          LoadingProgress()
            .width(80)
            .height(80)
            .color(store.themeMode === AppThemeMode.DARK ? '#7EC0EE' : '#0A84FF')
        }
      }
    }
    .title("收藏")
    .titleMode(NavigationTitleMode.Mini)
    .hideBackButton(true)
    .menus([
      {
        value: "刷新",
        icon: $r('app.media.refresh'),
        action: () => {
          this.refreshData()
        }
      }
    ])
    .backgroundColor(store.themeMode === AppThemeMode.DARK ? '#121212' : '#FFFFFF')
    .onAppear(async () => {
      context.watch("SiteAction", this)
      this.isLoading = true
      await this.fetchData()
      this.isLoading = false
      router.addTarget?.(this.router(), "star")
    })
    .onDisAppear(() => {
      context.unwatch("SiteAction", this)
    })
  }

  async fetchData() {
    let typeName = "Movie"
    this.medias = await store.api?.getMedias({
      "Filters": "IsFavorite",
      "Limit": "50",
      "IncludeItemTypes": typeName,
      "StartIndex": "0",
      "SortBy": "SortName"
    })

    typeName = "Series"
    this.series = await store.api?.getMedias({
      "Filters": "IsFavorite",
      "Limit": "50",
      "IncludeItemTypes": typeName,
      "StartIndex": "0",
      "SortBy": "SortName"
    })

    typeName = "Episode"
    this.episodes = await store.api?.getMedias({
      "Filters": "IsFavorite",
      "Limit": "50",
      "IncludeItemTypes": typeName,
      "StartIndex": "0",
      "SortBy": "SortName"
    })
  }

  onSiteUpdate(site: SiteModel) {
    new Promise<void>(async () => {
      this.isLoading = true;
      await this.fetchData()
      this.isLoading = false
    })
  }

  // 刷新数据
  refreshData() {
    new Promise<void>(async () => {
      this.isLoading = true;
      await this.fetchData()
      this.isLoading = false
    })
  }

  router(): Router {
    return {
      params: () => {
        let params: Dict = this.path.getParamByIndex(this.path.size()-1) ?? {}
        return params ?? {}
      },
      setTarget: () => {},
      pushPage: (name, params) => {
        this.path.pushPath({
          name: name,
          param: params
        })
      },
      replacePage: (name, params) => {
        this.path.replacePath({
          name,
          param: params
        })
      },
      popPage: () => {
        this.path.pop(true)
      },
      canGoBack: () => true,
      goBack: () => {},
      clear: () => {}
    }
  }
}