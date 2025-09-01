import { MediaModel, nil } from '../../../api/iPlayDataSource'
import { Dict, router } from '../../../module/Router'
import { store } from '../store/Store'
import { MediaCellView } from '../view/MediaCellView'

@Entry
@Component
struct AlbumPage {
  @State params: Dict = router.params()
  @State medias: MediaModel[]|nil = null
  @State albumId: string|nil = null
  @State actorId: string|nil = null

  constructor() {
    super()
  }

  @State isFavorite: boolean = false
  @State albumTitle: string = "专辑"
  
  build() {
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
        
        Text(this.albumTitle)
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
  }

  onPageShow(): void {
    let albumId: string = this.params["albumId"] ?? "0"
    let actorId: string = this.params["actorId"] ?? "0"
    this.albumId = albumId
    this.actorId = actorId
    
    // 获取专辑标题，如果有的话
    this.albumTitle = this.params["title"] || "专辑"
    
    // 检查是否已收藏
    this.checkFavoriteStatus()
    
    new Promise<void>(async () => {
      let query: Dict = {
        "IncludeItemTypes": "Movie,Series"
      };
      if (albumId != null) {
        query["ParentId"] = albumId
      }
      if (actorId != null) {
        query["PersonIds"] = actorId
      }
      this.medias = await store.api?.getMedias(query)
    })
  }
  
  // 检查收藏状态
  async checkFavoriteStatus() {
    if (!this.albumId && !this.actorId) return;
    
    try {
      let id = this.albumId || this.actorId;
      let itemType = this.albumId ? "Folder" : "Person";
      
      // 此处假设可以通过查询获取收藏项目，参数Filters=IsFavorite
      const favorites = await store.api?.getMedias({
        "Filters": "IsFavorite",
        "IncludeItemTypes": itemType,
        "Limit": "100"
      });
      
      // 检查当前项目是否在收藏列表中
      this.isFavorite = favorites?.some(item => item.id === id) ?? false;
    } catch (error) {
      console.error('获取收藏状态失败:', error);
    }
  }
  
  // 切换收藏状态
  async toggleFavorite() {
    const itemId = this.albumId || this.actorId;
    if (!itemId) return;
    
    const newState = !this.isFavorite;
    
    try {
      // 直接使用API的toggleFavorite方法
      const success = await store.api?.toggleFavorite(itemId, newState);
      
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