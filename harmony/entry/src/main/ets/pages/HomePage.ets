import { EmbyApi } from "../../../api/emby/EmbyApi"
import { SiteModel, MediaModel } from "../../../api/iPlayDataSource"
import { context } from "../../../bean/BeanContainer"
import { SiteAction } from "../../../bean/SiteAction"
import { kv } from "../../../module/KVStorage"
import { router } from "../../../module/Router"
import { store } from "../store/Store"
import { AlbumMediaList, AlbumMediasModel } from "../view/AlbumMediaList"

@Entry
@Component
export struct Index {
  @State albums: AlbumMediasModel[] = []
  @State isLoading: boolean = false

  constructor() {
    super()
  }

  build() {
    Stack ({ alignContent: Alignment.Center }) {
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
        
        Text("主页")
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
      .listDirection(Axis.Vertical)
      .scrollBar(BarState.Off)
      .friction(0.6)
      .divider({ strokeWidth: 2, color: 0xFFFFFF, startMargin: 2, endMargin: 2 }) // 每行之间的分界线
      .edgeEffect(EdgeEffect.Spring)
      .onScrollIndex((firstIndex: number, lastIndex: number, centerIndex: number) => {
        console.info('first' + firstIndex)
        console.info('last' + lastIndex)
        console.info('center' + centerIndex)
      })
      .onScrollVisibleContentChange((start: VisibleListContentInfo, end: VisibleListContentInfo) => {
        console.log(' start index: ' + start.index +
          ' start item group area: ' + start.itemGroupArea +
          ' start index in group: ' + start.itemIndexInGroup)
        console.log(' end index: ' + end.index +
          ' end item group area: ' + end.itemGroupArea +
          ' end index in group: ' + end.itemIndexInGroup)
      })
      .onDidScroll((scrollOffset: number, scrollState: ScrollState) => {
        console.info(`onScroll scrollState = ScrollState` + scrollState + `, scrollOffset = ` + scrollOffset)
      })
      .width('100%')
    }
    .width('100%')
    .height("100%")
    .padding({ top: 5 })

      if (this.isLoading) {
        LoadingProgress()
          .width(80)
          .height(80)
      }

    }
    .onAppear(async () => {
      context.watch("SiteAction", this)
      this.isLoading = true;
      this.albums = await this.fetchData()
      this.isLoading = false
    })
    .onDisAppear(() => {
      context.unwatch("SiteAction", this)
    })
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
    let album = new AlbumMediasModel();
    album.type = "albums"
    album.medias = albums.map(item => {
      let media: MediaModel = {
        id: item.id,
        seriesId: "",
        title: item.title,
        image: item.image,
        type: "album",
        tags: null,
        overview: null,
        actors: null
      }
      return media
    })

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
    return [album, ...albumMedias]
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
  
  // 显示更多选项
  showMoreOptions() {
    AlertDialog.show(
      {
        title: '更多选项',
        message: '选择要进行的操作',
        primaryButton: {
          value: '站点管理',
          action: () => {
            // 跳转到站点管理页面
            router.pushPage("pages/SiteManagePage", {})
          }
        },
        secondaryButton: {
          value: '设置',
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