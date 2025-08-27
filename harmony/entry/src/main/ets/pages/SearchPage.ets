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
}