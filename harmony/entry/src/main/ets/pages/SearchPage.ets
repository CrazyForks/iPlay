import { MediaModel, nil } from '../../../api/iPlayDataSource'
import { Dict, Router, router } from '../../../module/Router'
import { AppThemeMode, store } from '../store/Store'
import { MediaCellView } from '../view/MediaCellView'

@Entry
@Component
export struct Index {
  @State medias: MediaModel[] | nil = null
  @State keyword: string | nil = null
  @State isLoading: boolean = false
  @State path: NavPathStack = new NavPathStack()

  constructor() {
    super()
  }

  build() {
    Navigation(this.path) {
      Stack({ alignContent: Alignment.Center }) {
        Column() {
          Row() {
            TextInput({ text: this.keyword, placeholder: "" })
              .type(InputType.Normal)
              .width('80%')
              .flexGrow(1)
              .height(40)
              .border({ width: 1, color: '#cccccc' })
              .borderRadius(11)
              .onChange((value: string) => {
                this.keyword = value;
              })
            Button("搜索")
              .margin({ left: 8 })
              .onClick(() => {
                this.search(this.keyword ?? "")
              })
          }
          .width('100%')
          .margin({ top: 15, bottom: 10 })

          Grid() {
            ForEach(this.medias, (item: MediaModel) => {
              GridItem() {
                MediaCellView({ model: item, layout: "auto" })
              }
            }, (item: MediaModel) => item.id)
          }
          .columnsTemplate('1fr 1fr')
          .width('100%')
          .height('100%')
        }

        if (this.isLoading) {
          LoadingProgress()
            .width(80)
            .height(80)
            .color(store.themeMode === AppThemeMode.DARK ? '#7EC0EE' : '#0A84FF')
        }
      }
    }
    .title("搜索")
    .titleMode(NavigationTitleMode.Mini)
    .hideBackButton(true)
    .menus([
      {
        value: "刷新",
        icon: $r('app.media.refresh'),
        action: () => {
          this.refreshData()
        }
      },
    ])
    .onAppear(() => {
      router.addTarget?.(this.router(), "search")
    })
  }

  async search(keyword: string) {
    this.isLoading = true
    this.medias = await store.api?.getMedias({
      "SearchTerm": keyword,
      "Limit": "100",
      "IncludeItemTypes": "Series,Movie,Episode",
      "StartIndex": "0",
      "SortBy": "SortName",
      "GroupProgramsBySeries": "true"
    })
    this.isLoading = false
  }

  refreshData() {
    if (this.keyword) {
      this.search(this.keyword)
    } else {
      this.medias = []
    }
  }

  showMoreOptions() {
    AlertDialog.show(
      {
        title: '更多选项',
        message: '选择要进行的操作',
        primaryButton: {
          value: '搜索设置',
          action: () => {
          }
        },
        secondaryButton: {
          value: '取消',
          action: () => {
          }
        },
        cancel: () => {
        }
      }
    )
  }

  router(): Router {
    return {
      params: () => {
        let params: Dict = this.path.getParamByIndex(this.path.size() - 1) ?? {}
        return params ?? {}
      },
      setTarget: () => {
      },
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
      goBack: () => {
      },
      clear: () => {
      }
    }
  }
}