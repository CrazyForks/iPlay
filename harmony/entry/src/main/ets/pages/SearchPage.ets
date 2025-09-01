import { MediaModel, nil } from '../../../api/iPlayDataSource'
import { Dict, router } from '../../../module/Router'
import { store } from '../store/Store'
import { MediaCellView } from '../view/MediaCellView'

@Entry
@Component
export struct Index {
  @State medias: MediaModel[]|nil = null
  @State keyword: string|nil = null

  constructor() {
    super()
  }

  build() {
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
        
        Text("搜索")
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
          .borderRadius(2)
          .margin({left: 8})
          .onClick(() => {
              this.search(this.keyword ?? "")
          })
      }
      .width('100%')
      .margin({ top: 15 })
      Grid() {
        ForEach(this.medias, (item: MediaModel) => {
          GridItem() {
            MediaCellView({ model: item, layout: "2/3" })
          }
        }, (item: MediaModel) => item.id)
      }
      .columnsTemplate('1fr 1fr 1fr')
      .rowsGap(5)
      .columnsGap(5)
      .width('100%')
      .height('100%')
    }
    .onAppear(() => {

    })
  }

  async search(keyword: string) {
    this.medias = await store.api?.getMedias({
      "SearchTerm": keyword,
      "Limit": "100",
      "IncludeItemTypes": "Series,Movie,Episode",
      "StartIndex": "0",
      "SortBy": "SortName",
      "GroupProgramsBySeries": "true"
    })
  }
  
  // 刷新数据
  refreshData() {
    if (this.keyword) {
      this.search(this.keyword)
    } else {
      // 如果没有关键字，可以清空搜索结果或者显示提示
      this.medias = []
    }
  }
  
  // 显示更多选项
  showMoreOptions() {
    // 这里可以实现更多选项的菜单，例如搜索设置、历史记录等
    AlertDialog.show(
      {
        title: '更多选项',
        message: '选择要进行的操作',
        primaryButton: {
          value: '搜索设置',
          action: () => {
            // 跳转到搜索设置
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