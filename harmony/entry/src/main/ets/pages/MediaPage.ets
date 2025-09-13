import { ActorModel, MediaModel, nil } from '../../../api/iPlayDataSource'
import { Dict, router } from '../../../module/Router'
import { store } from '../store/Store'
import { ActorCellView } from '../view/ActorCellView'
import { MediaCellView } from '../view/MediaCellView'
import { LengthMetrics } from '@kit.ArkUI'


@Builder
export function PageBuilder() {
  MediaPage()
}

@Entry
@Component
struct MediaPage {
  @State params: Dict = router.params()
  @State media: MediaModel|nil = null
  @State seasons: MediaModel[]|nil = null
  @State episodes: MediaModel[]|nil = null
  @State selectedImageIndex: number = 0
  @State displayImages: string[] = []

  private  seasonEpisodes: MediaModel[][]|nil = null

  constructor() {
    super()
  }

  @State isFavorite: boolean = false
  
  build() {
    NavDestination() {
      Column() {
        Scroll() {
          Column({ space: 16 }) {
            // 第一行：主要图片显示区域
            this.buildMainImageArea()
            
            // 第二行：图片列表（与第一行联动）
            this.buildImageGallery()
            
            // 播放按钮
            this.buildPlayButton()
            
            // 标签区域
            this.buildTagsArea()
            
            // 描述区域
            this.buildDescriptionArea()
            
            // 演员列表
            this.buildActorsList()
            
            // 季度选择和剧集列表
            this.buildSeasonsAndEpisodes()
          }
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        }
        .scrollBar(BarState.Off)
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

  aboutToAppear(): void {
    this.onPageShow()
  }

  onPageShow(): void {
    this.media = this.params["media"]
    
    // 检查是否已收藏
    this.checkFavoriteStatus()
    
    // 初始化显示图片
    this.updateDisplayImages()
    
    new Promise<void>(async () => {
      let seasons = await store.api?.getSeasons(this.media?.id ?? "") ?? []
      seasons.forEach(season => console.log(`${season.title}`))
      this.seasons = seasons;

      this.episodes = seasons;
      // get episodes for each season
      let seasonEpisodes = await Promise.all(seasons.map(async season => await store.api?.getEpisodes(this.media?.id ?? "", season.id ?? "")));
      seasonEpisodes.forEach(items => items?.forEach(item => console.log(`${item.title}`)))
      this.seasonEpisodes = seasonEpisodes as MediaModel[][]
      
      // 更新图片列表
      this.updateDisplayImages()
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

  // 主要图片显示区域
  @Builder
  buildMainImageArea() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image(this.displayImages[this.selectedImageIndex] || this.imageUrl())
        .width('100%')
        .aspectRatio(16/9)
        .borderRadius(12)
        .objectFit(ImageFit.Cover)
        .onClick(() => {
          store.api?.getPlayback(this.media?.id ?? "").then(playback => {
            router.pushPage("pages/PlayerPage", {
              "playback": playback
            })
          })
        })
      
      // 渐变遮罩
      Column()
        .width('100%')
        .height(80)
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [['rgba(0,0,0,0)', 0], ['rgba(0,0,0,0.7)', 1]]
        })
        .borderRadius({ bottomLeft: 12, bottomRight: 12 })
      
      // 标题信息
      Column({ space: 4 }) {
        Text(this.media?.title || '')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        
        if (this.media?.tags && this.media.tags.length > 0) {
          Text(this.media.tags.slice(0, 3).join(' • '))
            .fontSize(14)
            .fontColor('#E0E0E0')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .padding({ left: 16, right: 16, bottom: 16 })
    }
  }

  // 图片列表（与主图联动）
  @Builder
  buildImageGallery() {
    if (this.displayImages.length > 1) {
      Column({ space: 8 }) {
        Scroll() {
          Row({ space: 8 }) {
            ForEach(this.displayImages, (imageUrl: string, index: number) => {
              Stack() {
                Image(imageUrl)
                  .width(80)
                  .aspectRatio(16/9)
                  .borderRadius(6)
                  .objectFit(ImageFit.Cover)
                
                // 选中状态指示器
                if (this.selectedImageIndex === index) {
                  Column()
                    .width(80 + 8)
                    .aspectRatio(16/9)
                    .borderRadius(6)
                    .border({
                      width: 2,
                      color: '#007AFF'
                    })
                }
              }
              .onClick(() => {
                this.selectedImageIndex = index
              })
            }, (imageUrl: string, index: number) => `${imageUrl}_${index}`)
          }
          .padding({ left: 0, right: 16 })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')
      }
    }
  }

  // 播放按钮
  @Builder
  buildPlayButton() {
    if (this.media?.type?.toLowerCase() != "series") {
      Button('立即播放')
        .width('100%')
        .height(48)
        .backgroundColor('#000000')
        .fontColor(Color.White)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .borderRadius(8)
        .onClick(() => {
          store.api?.getPlayback(this.media?.id ?? "").then(playback => {
            router.pushPage("pages/PlayerPage", {
              "playback": playback,
              "media": this.media
            })
          })
        })
    }
  }

  // 标签区域
  @Builder
  buildTagsArea() {
    if (this.media?.tags && this.media.tags.length > 0) {
      Column({ space: 8 }) {
        Row() {
          Text('标签')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
          Blank()
        }
        .width('100%')
        
        Flex({ wrap: FlexWrap.Wrap, space: { main: new LengthMetrics(8), cross: new LengthMetrics(8) } }) {
          ForEach(this.media?.tags, (tag: string) => {
            Text(tag)
              .fontSize(12)
              .fontColor('#007AFF')
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .backgroundColor('#F0F8FF')
              .borderRadius(16)
          }, (tag: string) => tag)
        }
        .width('100%')
      }
    }
  }

  // 描述区域
  @Builder
  buildDescriptionArea() {
    if (this.media?.overview) {
      Column({ space: 8 }) {
        Row() {
          Text('简介')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
          Blank()
        }
        .width('100%')
        
        Text(this.media.overview)
          .fontSize(14)
          .fontColor('#666666')
          .lineHeight(20)
          .width('100%')
      }
    }
  }

  // 演员列表
  @Builder
  buildActorsList() {
    if (this.media?.actors && this.media.actors.length > 0) {
      Column({ space: 8 }) {
        Row() {
          Text('参演人员')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
          Blank()
        }
        .width('100%')
        
        Scroll() {
          Row({ space: 12 }) {
            ForEach(this.media?.actors, (actor: ActorModel) => {
              ActorCellView({
                model: actor
              })
            }, (actor: ActorModel) => actor.id)
          }
          .padding({ left: 0, right: 16 })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')
        .height(150)
      }
    }
  }

  // 季度选择和剧集列表
  @Builder
  buildSeasonsAndEpisodes() {
    if (this.seasons && this.seasons.length > 0) {
      Column({ space: 12 }) {
        // 季度选择
        Column({ space: 8 }) {
          Row() {
            Text('季度')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
            Blank()
          }
          .width('100%')
          
          Scroll() {
            Row({ space: 8 }) {
              if (this.seasons?.length ?? 0 > 0) {
                Text("全部")
                  .fontSize(14)
                  .fontColor('#007AFF')
                  .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                  .backgroundColor('#F0F8FF')
                  .borderRadius(20)
                  .onClick(() => {
                    this.episodes = this.seasons
                    this.updateDisplayImages()
                  })
              }
              ForEach(this.seasons, (season: MediaModel, idx: number) => {
                Text(season.title ?? "")
                  .fontSize(14)
                  .fontColor('#007AFF')
                  .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                  .backgroundColor('#F0F8FF')
                  .borderRadius(20)
                  .onClick(() => {
                    this.episodes = this.seasonEpisodes?.[idx] ?? []
                    this.updateDisplayImages()
                  })
              }, (season: MediaModel) => season.id)
            }
            .padding({ left: 0, right: 16 })
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width('100%')
        }
        
        // 剧集列表
        if (this.episodes && this.episodes.length > 0) {
          Column({ space: 8 }) {
            Row() {
              Text('剧集')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
              Blank()
            }
            .width('100%')
            
            Scroll() {
              Row({ space: 12 }) {
                ForEach(this.episodes, (episode: MediaModel) => {
                  MediaCellView({
                    model: episode,
                    layout: "auto"
                  })
                }, (episode: MediaModel) => episode.id)
              }
              .padding({ left: 0, right: 16 })
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .width('100%')
            .height(180)
          }
        }
      }
    }
  }

  imageUrl() {
    let type = this.media?.type?.toLowerCase()
    if (type == "movie") {
      return this.media?.image?.backdrop ?? ""
    }
    return this.media?.image?.primary ?? ""
  }

  // 更新显示图片列表
  updateDisplayImages() {
    let images: string[] = []
    
    // 添加主图片
    const mainImage = this.imageUrl()
    if (mainImage) {
      images.push(mainImage)
    }
    
    // 添加剧集图片
    if (this.episodes) {
      this.episodes.forEach(episode => {
        if (episode.image?.primary) {
          images.push(episode.image.primary)
        }
      })
    }
    
    this.displayImages = images
    this.selectedImageIndex = 0
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