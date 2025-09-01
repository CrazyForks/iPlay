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

  @State isFavorite: boolean = false
  
  build() {
    Stack( {alignContent: Alignment.Center }) {
      Column() {
        // 导航栏
        Row() {
          Button() {
            Image($r('app.media.back'))
              .width(24)
              .height(24)
          }
          .type(ButtonType.Normal)
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            router.popPage()
          })
          
          Text(this.media?.title ?? "剧集")
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .flexGrow(1)
            .textAlign(TextAlign.Center)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          
          Button() {
            Image(this.isFavorite ? $r('app.media.star_filled') : $r('app.media.star_outline'))
              .width(24)
              .height(24)
          }
          .type(ButtonType.Normal)
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            this.toggleFavorite()
          })
        }
        .width('100%')
        .height(50)
        .padding({left: 10, right: 10})
        
        Scroll() {
          Column() {
          List({ space: 5, initialIndex: 0 }) {
            ForEach(this.episodes, (item: MediaModel) => {
              ListItem() {
                MediaInlineCellView({
                  model: item,
                  layout: "auto"
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
      }
      .height("100%")
      .width("100%")

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
    
    // 检查是否已收藏
    this.checkFavoriteStatus()
    
    if (this.episodes == undefined) {
      new Promise<void>(async () => {
        this.isLoading = true
        let episodes = await store.api?.getEpisodes(this.media?.seriesId,  this.media?.id);
        this.episodes = episodes
        this.isLoading = false
      })
    }
  }
  
  // 检查收藏状态
  async checkFavoriteStatus() {
    if (!this.media?.id) return;
    
    try {
      // 此处假设可以通过查询获取收藏项目，参数Filters=IsFavorite
      const favorites = await store.api?.getMedias({
        "Filters": "IsFavorite",
        "IncludeItemTypes": "Season",
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