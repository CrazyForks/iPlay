import { MediaModel, nil, SiteModel } from '../../../api/iPlayDataSource'
import { context } from '../../../bean/BeanContainer'
import { Dict, router } from '../../../module/Router'
import { store } from '../store/Store'
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
          }
          .type(ButtonType.Normal)
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            this.refreshData()
          })
          
          Text("收藏")
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .flexGrow(1)
            .textAlign(TextAlign.Center)
          
          Button() {
            Image($r('app.media.more'))
              .width(24)
              .height(24)
          }
          .type(ButtonType.Normal)
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            // 显示更多选项
            this.showMoreOptions()
          })
        }
        .width('100%')
        .height(50)
        .padding({left: 10, right: 10})
        if (this.medias?.length ?? 0 > 0) {
          Row() {
            Text("喜爱的电影")
              .flexGrow(1)

            Text("查看更多")
              .flexShrink(0)
              .fontSize(11)
          }
          .width('100%')
        }
        Grid() {
            ForEach(this.medias, (item: MediaModel) => {
              GridItem() {
                MediaCellView({ model: item, layout: "2/3" })
              }
            }, (item: MediaModel) => item.id)
        }

        if (this.series?.length ?? 0 > 0) {
          Row() {
            Text("喜爱的剧")
              .flexGrow(1)

            Text("查看更多")
              .flexShrink(0)
              .fontSize(11)
          }
          .width('100%')
        }
        Grid() {
          ForEach(this.series, (item: MediaModel) => {
            GridItem() {
              MediaCellView({ model: item, layout: "2/3" })
            }
          }, (item: MediaModel) => item.id)
        }

        if (this.episodes?.length ?? 0 > 0) {
          Row() {
            Text("喜爱的集")
              .flexGrow(1)

            Text("查看更多")
              .flexShrink(0)
              .fontSize(11)
          }
          .width('100%')
        }
        Grid() {
          ForEach(this.episodes, (item: MediaModel) => {
            GridItem() {
              MediaCellView({ model: item, layout: "2/3" })
            }
          }, (item: MediaModel) => item.id)
        }
      }
      .width('100%')
      .height('100%')

      if (this.isLoading) {
        LoadingProgress()
          .width(80)
          .height(80)
      }
    }
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
    // 这里可以实现更多选项的菜单，例如设置、关于等
    AlertDialog.show(
      {
        title: '更多选项',
        message: '选择要进行的操作',
        primaryButton: {
          value: '设置',
          action: () => {
            // 跳转到设置页面
          }
        },
        secondaryButton: {
          value: '取消',
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