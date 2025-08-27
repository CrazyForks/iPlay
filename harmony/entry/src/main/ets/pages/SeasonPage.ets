import { ActorModel, MediaModel, nil } from '../../../api/iPlayDataSource'
import { Dict, router } from '../../../module/Router'
import { store } from '../store/Store'
import { ActorCellView } from '../view/ActorCellView'
import { MediaCellView } from '../view/MediaCellView'
import { MediaInlineCellView } from '../view/MediaInlineCellView'

@Entry
@Component
struct SeasonPage {
  @State params: Dict = router.params()
  @State media: MediaModel|nil = null
  @State episodes: MediaModel[]|nil = null
  @State isLoading: boolean = false

  private  seasonEpisodes: MediaModel[][]|nil = null

  constructor() {
    super()
  }

  build() {
    Stack( {alignContent: Alignment.Center }) {
      Scroll() {
        Column() {
          List({ space: 5, initialIndex: 0 }) {
            ForEach(this.episodes, (item: MediaModel) => {
              ListItem() {
                MediaInlineCellView({
                  model: item
                })
              }
            }, (item: MediaModel) => item.id)
          }
          .padding(5)
          .width("100%")
          .flexGrow(0)
          .flexShrink(1)
          .margin({ top: 10 })
        }
        .height("100%")
      }

      if (this.isLoading) {
        LoadingProgress()
          .width(80)
          .height(80)
      }
    }
    .width("100%")
    .height("100%")
  }

  onPageShow(): void {
    this.media = this.params["media"]
    this.episodes = this.params["episodes"]
    if (this.episodes == undefined) {
      new Promise<void>(async () => {
        this.isLoading = true
        let episodes = await store.api?.getEpisodes(this.media?.seriesId,  this.media?.id);
        this.episodes = episodes
        this.isLoading = false
      })
    }
  }

  imageUrl() {
    let type = this.media?.type?.toLowerCase()
    if (type == "movie") {
      return this.media?.image?.backdrop ?? ""
    }
    return this.media?.image?.primary ?? ""
  }

}