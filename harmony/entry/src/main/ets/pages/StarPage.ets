import { MediaModel, nil, SiteModel } from '../../../api/iPlayDataSource'
import { context } from '../../../bean/BeanContainer'
import { Dict, router } from '../../../module/Router'
import { store, AppThemeMode } from '../store/Store'
import { MediaCellView } from '../view/MediaCellView'

@Entry
@Component
export struct Index {
  @State medias: MediaModel[] | nil = null
  @State series: MediaModel[] | nil = null
  @State episodes: MediaModel[] | nil = null
  @State isLoading: boolean = false;

  constructor() {
    super()
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column() {
        // 添加导航栏
        Row() {
          Button() {
            Image($r('app.media.refresh'))
              .width(24)
              .height(24)
              .fillColor(store.themeMode === AppThemeMode.DARK ? Color.White : Color.Black)
          }
          .type(ButtonType.Normal)
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            this.refreshData()
          })

          Text("收藏")
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .flexGrow(1)
            .textAlign(TextAlign.Center)
            .fontColor(store.themeMode === AppThemeMode.DARK ? Color.White : Color.Black)

          Button() {
            Image($r('app.media.more'))
              .width(24)
              .height(24)
              .fillColor(store.themeMode === AppThemeMode.DARK ? Color.White : Color.Black)
          }
          .type(ButtonType.Normal)
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            // 显示更多选项
            this.showMoreOptions()
          })
        }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })
        .backgroundColor(store.themeMode === AppThemeMode.DARK ? '#1C1C1E' : '#F5F5F5')

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
        .scrollBar(BarState.Auto)
        .edgeEffect(EdgeEffect.Spring)
        .width('100%')
        .layoutWeight(1) // This ensures the scroll area takes all remaining space

        if (this.isLoading) {
          LoadingProgress()
            .width(80)
            .height(80)
            .color(store.themeMode === AppThemeMode.DARK ? '#7EC0EE' : '#0A84FF')
        }
      }
      .backgroundColor(store.themeMode === AppThemeMode.DARK ? '#121212' : '#FFFFFF')
      .onAppear(async () => {
        context.watch("SiteAction", this)
        this.isLoading = true
        await this.fetchData()
        this.isLoading = false
      })
      .onDisAppear(() => {
        context.unwatch("SiteAction", this)
      })
    }
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
  
  // 显示更多选项
  showMoreOptions() {
    // 更现代的菜单样式
    AlertDialog.show(
      {
        title: '更多选项',
        message: '选择要进行的操作',
        autoCancel: true,
        alignment: DialogAlignment.Bottom,
        offset: { dx: 0, dy: -20 },
        primaryButton: {
          value: '设置',
          fontColor: store.themeMode === AppThemeMode.DARK ? '#7EC0EE' : '#0A84FF',
          action: () => {
            // 跳转到设置页面
            router.pushPage("pages/SettingsPage", {})
          }
        },
        secondaryButton: {
          value: '取消',
          fontColor: store.themeMode === AppThemeMode.DARK ? '#999999' : '#666666',
          action: () => {
            // 关闭弹窗
          }
        },
        cancel: () => {
          // 用户点击遮罩区域时触发
        }
      }
    )
  }
}