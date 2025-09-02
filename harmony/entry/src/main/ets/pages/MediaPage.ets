import { ActorModel, MediaModel, nil } from '../../../api/iPlayDataSource'
import { Dict, router } from '../../../module/Router'
import { store } from '../store/Store'
import { ActorCellView } from '../view/ActorCellView'
import { MediaCellView } from '../view/MediaCellView'

@Entry
@Component
struct MediaPage {
  @State params: Dict = router.params()
  @State media: MediaModel|nil = null
  @State seasons: MediaModel[]|nil = null
  @State episodes: MediaModel[]|nil = null

  private  seasonEpisodes: MediaModel[][]|nil = null

  constructor() {
    super()
  }

  @State isFavorite: boolean = false
  
  build() {
    NavDestination() {
      Column() {
        Scroll() {
          Column() {
            Image(this.imageUrl())
              .width("100%")
              .aspectRatio(16 / 9)
              .onClick(() => {
                store.api?.getPlayback(this.media?.id ?? "").then(playback => {
                  router.pushPage("pages/PlayerPage", {
                    "playback": playback
                  })
                })
              })

            if (this.media?.type?.toLowerCase() != "series") {
              Button('播 放')
                .width('90%')
                .height(40)
                .margin({ top: 10 })
                .backgroundColor('#000000')
                .fontColor(Color.White)
                .onClick(() => {
                  store.api?.getPlayback(this.media?.id ?? "").then(playback => {
                    router.pushPage("pages/PlayerPage", {
                      "playback": playback,
                      "media": this.media
                    })
                  })
                })
            }

            Row() {
              List({ space: 5, initialIndex: 0 }) {
                ForEach(this.media?.tags, (item: string) => {
                  ListItem() {
                    Text(item)
                      .fontColor("#ffffff")
                      .margin(5)
                  }
                  .backgroundColor("#000000")
                  .borderRadius(5)
                }, (item: string) => item)
              }
              .height(32)
              .listDirection(Axis.Horizontal)
            }
            .padding(5)
            .width("100%")
            .height("auto")
            .flexGrow(0)
            .flexShrink(1)
            .margin({ top: 10 })

            Row() {
              Text(this.media?.overview ?? "")
                .fontSize(14)
                .width("100%")
            }
            .padding(5)
            .width("100%")

            Text($r("app.string.media_actor_list"))
              .width("100%")
              .fontWeight(FontWeight.Bold)
              .margin({ top: 5, bottom: 5 })
              .padding({ left: 5, right: 5 })
            Row() {
              List({ space: 5, initialIndex: 0 }) {
                ForEach(this.media?.actors, (actor: ActorModel) => {
                  ListItem() {
                    ActorCellView({
                      model: actor
                    })
                  }
                }, (item: ActorModel) => item.id)
              }
              .width("100%")
              .height(150)
              .listDirection(Axis.Horizontal)
              .scrollBar(BarState.Off)
            }

            Row() {
              List({ space: 5, initialIndex: 0 }) {
                if (this.seasons?.length ?? 0 > 0) {
                  ListItem() {
                    Text("All")
                      .fontColor("#ffffff")
                      .margin(5)
                  }
                  .onClick(() => {
                    this.episodes = this.seasons
                  })
                  .backgroundColor("#000000")
                  .borderRadius(5)
                }
                ForEach(this.seasons, (item: MediaModel, idx: number) => {
                  ListItem() {
                    Text(item.title ?? "")
                      .fontColor("#ffffff")
                      .margin(5)
                  }
                  .backgroundColor("#000000")
                  .borderRadius(5)
                  .onClick(() => {
                    this.episodes = this.seasonEpisodes?.[idx] ?? []
                  })
                }, (item: MediaModel) => item.id)
              }
              .height(32)
              .listDirection(Axis.Horizontal)
            }
            .padding(5)
            .width("100%")
            .height("auto")
            .flexGrow(0)
            .flexShrink(1)
            .margin({ top: 10 })

            Row() {
              List({ space: 5, initialIndex: 0 }) {
                ForEach(this.episodes, (item: MediaModel) => {
                  ListItem() {
                    MediaCellView({
                      model: item,
                      layout: "auto"
                    })
                  }
                  .borderRadius(5)
                  .onSelect((selected) => {

                  })
                }, (item: MediaModel) => item.id)
              }
              .height(180)
              .listDirection(Axis.Horizontal)
            }
            .padding(5)
            .width("100%")
            .height("auto")
            .flexGrow(0)
            .flexShrink(1)
            .margin({ top: 10 })
          }
        }
        .layoutWeight(1)
      }
      .height('100%')
    }
    .title(this.media?.title ?? "媒体详情")
    .menus([
      {
        value: "收藏",
        icon: this.isFavorite ? $r('app.media.star_filled') : $r('app.media.star_outline'),
        action: () => {
          this.toggleFavorite()
        }
      },
    ])
  }

  onPageShow(): void {
    this.media = this.params["media"]
    
    // 检查是否已收藏
    this.checkFavoriteStatus()
    
    new Promise<void>(async () => {
      let seasons = await store.api?.getSeasons(this.media?.id ?? "") ?? []
      seasons.forEach(season => console.log(`${season.title}`))
      this.seasons = seasons;

      this.episodes = seasons;
      // get episodes for each season
      let seasonEpisodes = await Promise.all(seasons.map(async season => await store.api?.getEpisodes(this.media?.id ?? "", season.id ?? "")));
      seasonEpisodes.forEach(items => items?.forEach(item => console.log(`${item.title}`)))
      this.seasonEpisodes = seasonEpisodes as MediaModel[][]
    })
  }
  
  // 检查收藏状态
  async checkFavoriteStatus() {
    if (!this.media?.id) return;
    
    try {
      // 根据媒体类型使用不同的查询参数
      const mediaType = this.media.type?.toLowerCase() === "series" ? "Series" : "Movie";
      
      // 此处假设可以通过查询获取收藏项目，参数Filters=IsFavorite
      const favorites = await store.api?.getMedias({
        "Filters": "IsFavorite",
        "IncludeItemTypes": mediaType,
        "Limit": "100"
      });
      
      // 检查当前媒体是否在收藏列表中
      this.isFavorite = favorites?.some(item => item.id === this.media?.id) ?? false;
    } catch (error) {
      console.error('获取收藏状态失败:', error);
    }
  }

  imageUrl() {
    let type = this.media?.type?.toLowerCase()
    if (type == "movie") {
      return this.media?.image?.backdrop ?? ""
    }
    return this.media?.image?.primary ?? ""
  }
  
  // 切换收藏状态
  async toggleFavorite() {
    if (!this.media?.id) return;
    
    const newState = !this.isFavorite;
    
    try {
      // 直接使用API的toggleFavorite方法
      const success = await store.api?.toggleFavorite(this.media.id, newState);
      
      if (success) {
        this.isFavorite = newState;
        // 显示提示
        this.getUIContext().getPromptAction().showToast({
          message: this.isFavorite ? '已添加到收藏' : '已从收藏中移除',
          duration: 2000
        });
      } else {
        throw new Error('操作失败');
      }
    } catch (error) {
      console.error('收藏操作失败:', error);
      // 显示错误提示
      this.getUIContext().getPromptAction().showToast({
        message: '收藏操作失败',
        duration: 2000
      });
    }
  }
}