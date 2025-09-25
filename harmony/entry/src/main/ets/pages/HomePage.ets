import { SiteModel, MediaModel } from "../../../api/iPlayDataSource"
import { context } from "../../../bean/BeanContainer"
import { Dict, Router, router } from "../../../module/Router"
import { AppThemeMode, store } from "../store/Store"
import { AlbumMediaList, AlbumMediasModel } from "../view/AlbumMediaList"
import { MpvPlayer } from "../mpv/MpvPlayer"

@Entry
@Component
export struct Index {
  @State albums: AlbumMediasModel[] = []
  @State isLoading: boolean = false
  @State recommendataions: MediaModel[] = []
  @State path: NavPathStack = new NavPathStack()

  constructor() {
    super()
  }

  build() {
    Navigation(this.path) {
      Stack({ alignContent: Alignment.Center }) {
        Scroll() {
          Column({ space: 16 }) {
            // 轮播组件
            this.buildCarousel()
            
            // 推荐项目
            this.buildRecommendations()
            
            // 其他内容列表
            this.buildContentList()
          }
          .width('100%')
          .padding({ left: 2, right: 2, top: 8, bottom: 8 })
        }
        .width('100%')
        .height('100%')
        .align(Alignment.TopStart)
        .backgroundColor(store.themeMode === AppThemeMode.DARK ? '#121212' : '#FFFFFF')
        .scrollBar(BarState.Off)
        .layoutWeight(1)

        if (this.albums == null || this.albums.length == 0) {
          if (store.api == null) {
            Button("添加数据源")
              .onClick(() => {
                router.pushPage("pages/LoginPage", {})
              })
          }
        }
        if (this.isLoading) {
          LoadingProgress()
            .width(80)
            .height(80)
            .color(store.themeMode === AppThemeMode.DARK ? '#7EC0EE' : '#0A84FF')
        }
      }
    }
    .title("主页")
    .titleMode(NavigationTitleMode.Mini)
    .hideBackButton(true)
    .padding(0)
    .menus([
      {
        value: "刷新",
        icon: $r('app.media.refresh'),
        action: () => {
          this.refreshData()
        }
      },
      {
        value: "更多",
        icon: $r('app.media.more'),
        action: () => {
          this.showMoreOptions()
        }
      },
    ])
    .onAppear(async () => {
      context.watch("SiteAction", this)
      
      // 获取MPV API版本并打印日志
      try {
        const mpvPlayer = new MpvPlayer();
        const apiVersion = await mpvPlayer.getApiVersion();
        const mpv = await mpvPlayer.create();
        // mpvPlayer.loadVideo(mpv, "https://example.com/breaking-bad.mp4");
        const majorVersion = (apiVersion >> 16) & 0xFFFF;
        const minorVersion = apiVersion & 0xFFFF;
        
        console.info(`=== MPV Client API Version Info ===`);
        console.info(`Raw Version: ${apiVersion} (0x${apiVersion.toString(16)})`);
        console.info(`Parsed Version: ${majorVersion}.${minorVersion}`);
        console.info(`MPV Library Integration: Success`);
        console.info(`=================================`);
      } catch (error) {
        console.error('=== MPV API Version Error ===');
        console.error('Failed to get MPV API version:', error);
        console.error('============================');
      }
      
      this.isLoading = true;
      this.albums = await this.fetchData()
      this.isLoading = false
      const myrouter = this.router()
      router.addTarget?.(myrouter, "home")
      router.setTarget(myrouter)
    })
    .onDisAppear(() => {
      context.unwatch("SiteAction", this)
    })
  }

  router(): Router {
    return {
      params: () => {
        let params: Dict = this.path.getParamByIndex(this.path.size()-1) ?? {}
        return params ?? {}
      },
      setTarget: () => {},
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
        this.path.pop(true)
      },
      clear: () => {}
    }
  }

  async fetchData() {
    // local emby server for test
    let api = store.api
    let site = store.site
    if (api == null || site == null) {
      return []
    }
    api.setSite(site)
    let albums = await api.getAllAlbums()
    albums = albums.filter(item => item.type != "music")
    albums.forEach(album => console.info("album: " + album.title + album.image?.primary))
    // let album = new AlbumMediasModel();
    // album.type = "albums"
    // album.medias = albums.map(item => {
    //   let media: MediaModel = {
    //     id: item.id,
    //     seriesId: "",
    //     title: item.title,
    //     image: item.image,
    //     type: "album",
    //     tags: null,
    //     overview: null,
    //     actors: null
    //   }
    //   return media
    // })

    let recommendations = await api!.getMedias({
      "SortBy": "IsFavoriteOrLiked,Random",
      "IncludeItemTypes": "Movie,Series",
      "Limit": "20",
      "Recursive": "true",
      "ImageTypeLimit": "0",
      "Fields": "BasicSyncInfo,People,Genres,SortName,Overview,CanDelete,Container,PrimaryImageAspectRatio,Prefix,DateCreated,ProductionYear,Status,EndDate"
    })
    this.recommendataions = recommendations

    let resumes = await api!.getResume()
    let resumeAlbum = new AlbumMediasModel()
    resumeAlbum.id = "-2" ?? ""
    resumeAlbum.title = "Continue" ?? ""
    resumeAlbum.type = "resume"
    resumeAlbum.medias = resumes

    let albumMedias = await Promise.all(albums.map(async album => {
      let medias = await api!.getAlbumLatestMedias(album.id)
      let model = new AlbumMediasModel()
      model.id = album.id ?? ""
      model.title = album.title ?? ""
      model.type = "medias"
      model.medias = medias
      return model
    }))
    albumMedias = [resumeAlbum, ...albumMedias].filter(item => item.medias.length > 0)
    return [...albumMedias]
  }

  onPageShow(): void {
    new Promise<void>(async () => {
      this.isLoading = true;
      this.albums = await this.fetchData()
      this.isLoading = false
    })
  }

  onSiteUpdate(site: SiteModel) {
    new Promise<void>(async () => {
      this.isLoading = true;
      this.albums = await this.fetchData()
      this.isLoading = false
    })
  }

  // 刷新数据
  refreshData() {
    new Promise<void>(async () => {
      this.isLoading = true;
      this.albums = await this.fetchData()
      this.isLoading = false
    })
  }

  // 轮播组件
  @Builder
  buildCarousel() {
    if (this.recommendataions.length) {
      Swiper() {
        ForEach(this.recommendataions, (media: MediaModel) => {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(media.image?.primary || '')
              .width('100%')
              .aspectRatio(16/9)
              .borderRadius(12)
              .objectFit(ImageFit.Cover)
              .alt($r('app.media.background'))
            
            // 渐变遮罩
            Column()
              .width('100%')
              .height(80)
              .linearGradient({
                direction: GradientDirection.Bottom,
                colors: [['rgba(0,0,0,0)', 0], ['rgba(0,0,0,0.7)', 1]]
              })
              .borderRadius({ bottomLeft: 12, bottomRight: 12 })
            
            // 标题和描述
            Column({ space: 4 }) {
              Text(media.title || '')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
              
              if (media.overview) {
                Text(media.overview)
                  .fontSize(14)
                  .fontColor('#E0E0E0')
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
            }
            .alignItems(HorizontalAlign.Start)
            .padding({ left: 2, right: 2, bottom: 16 })
          }
          .onClick(() => {
            // 点击跳转到详情页
            router.pushPage("pages/MediaPage", { media: media })
          })
          .margin({bottom: 28})
        }, (media: MediaModel) => media.id)
      }
      .width('100%')
      // .aspectRatio(16/11)
      .borderRadius(12)
      .autoPlay(true)
      .interval(4000)
      .indicator(
        new DotIndicator()
          .itemWidth(8)
          .itemHeight(8)
          .selectedItemWidth(16)
          .selectedItemHeight(8)
          .color(Color.Gray)
          .selectedColor(Color.Black)
      )
    }
  }

  // 推荐项目
  @Builder
  buildRecommendations() {
    if (this.albums.length > 1) {
      Column({ space: 12 }) {
        Row() {
          Text('推荐')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(store.themeMode === AppThemeMode.DARK ? '#FFFFFF' : '#000000')
          Blank()
        }
        .width('100%')
        
        Row({ space: 12 }) {
          ForEach(this.recommendataions.length > 2 ? this.recommendataions.slice(0, 2) : this.recommendataions, (media: MediaModel) => {
            if (this.recommendataions.length > 0) {
              Stack({ alignContent: Alignment.BottomStart }) {
                Image(media.image?.primary || '')
                  .width('100%')
                  .aspectRatio(16/9)
                  .borderRadius(8)
                  .objectFit(ImageFit.Cover)
                  .alt($r('app.media.background'))
                
                // 渐变遮罩
                Column()
                  .width('100%')
                  .height(60)
                  .linearGradient({
                    direction: GradientDirection.Bottom,
                    colors: [['rgba(0,0,0,0)', 0], ['rgba(0,0,0,0.8)', 1]]
                  })
                  .borderRadius({ bottomLeft: 8, bottomRight: 8 })
                
                Column({ space: 2 }) {
                  Text(media.title || '')
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Color.White)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                  
                  // Text(`${this.recommendataions.length} 项`)
                  //   .fontSize(12)
                  //   .fontColor('#C0C0C0')
                }
                .alignItems(HorizontalAlign.Start)
                .padding({ left: 12, right: 12, bottom: 12 })
              }
              .layoutWeight(1)
              .onClick(() => {
                // 点击跳转到专辑页面
                router.pushPage("pages/MediaPage", { media: media })
              })
            }
          }, (album: AlbumMediasModel) => album.id)
        }
        .width('100%')
      }
    }
  }

  // 内容列表
  @Builder
  buildContentList() {
    if (this.albums.length > 0) {
      Column({ space: 16 }) {
        List({ space: 5, initialIndex: 0 }) {
          ForEach(this.albums, (item: AlbumMediasModel) => {
            ListItem() {
              Column() {
                AlbumMediaList({
                  model: item
                })
              }
            }
          }, (item: AlbumMediasModel) => item.id)
        }
      }
    }
  }

  // 显示更多选项
  showMoreOptions() {
    AlertDialog.show(
      {
        title: '更多选项',
        message: '选择要进行的操作',
        autoCancel: true,
        alignment: DialogAlignment.Bottom,
        offset: { dx: 0, dy: -20 },
        primaryButton: {
          value: '站点管理',
          fontColor: store.themeMode === AppThemeMode.DARK ? '#7EC0EE' : '#0A84FF',
          action: () => {
            // 跳转到站点管理页面
            router.pushPage("pages/SiteManagePage", {})
          }
        },
        secondaryButton: {
          value: '设置',
          fontColor: store.themeMode === AppThemeMode.DARK ? '#7EC0EE' : '#0A84FF',
          action: () => {
            // 跳转到设置页面
            router.pushPage("pages/SettingsPage", {})
          }
        },
        cancel: () => {
          // 用户点击遮罩区域时触发
        }
      }
    )
  }
}