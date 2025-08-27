import { MediaModel, nil } from '../../../api/iPlayDataSource'
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
        if (this.medias?.length ?? 0 > 0) {
          Row() {
            Text("喜爱的电影")
          }
        }
        Row() {
          Grid() {
            ForEach(this.medias, (item: MediaModel) => {
              GridItem() {
                MediaCellView({ model: item, layout: "2/3" })
              }
            }, (item: MediaModel) => item.id)
          }
        }

        if (this.series?.length ?? 0 > 0) {
          Text("喜爱的剧")
        }
        Grid() {
          ForEach(this.series, (item: MediaModel) => {
            GridItem() {
              MediaCellView({ model: item, layout: "2/3" })
            }
          }, (item: MediaModel) => item.id)
        }

        if (this.episodes?.length ?? 0 > 0) {
          Text("喜爱的集")
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
      this.isLoading = true
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
      this.isLoading = false
    })
  }
}