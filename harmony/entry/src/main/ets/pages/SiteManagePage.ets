import { SiteModel } from '../../../api/iPlayDataSource'
import { context } from '../../../bean/BeanContainer'
import { SiteAction } from '../../../bean/SiteAction'
import { router } from '../../../module/Router'
import { store } from '../store/Store'
import promptAction from '@ohos.promptAction'

@Entry
@Component
export struct SiteManagePage {
  @State siteList: SiteModel[] = []
  @State currentSiteId: string | null = null
  
  aboutToAppear() {
    // 加载站点列表
    this.siteList = store.sites || []
    this.currentSiteId = store.site?.id || null
  }
  
  build() {
    Stack({ alignContent: Alignment.TopEnd }) {
      Column() {
        // 添加导航栏
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
          
          Text("站点管理")
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .flexGrow(1)
            .textAlign(TextAlign.Center)
          
          Button() {
            Image($r('app.media.add'))
              .width(24)
              .height(24)
          }
          .type(ButtonType.Normal)
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            // 跳转到登录页添加新站点
            router.pushPage("pages/LoginPage", {})
          })
        }
        .width('100%')
        .height(50)
        .padding({left: 10, right: 10})
        
        if (this.siteList.length === 0) {
          Column() {
            Text("暂无站点，请点击右上角添加")
              .fontSize(16)
              .margin({ top: 100 })
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        } else {
          List() {
            ForEach(this.siteList, (site: SiteModel, index: number) => {
              ListItem() {
                this.SiteItem(site, index)
              }
              .swipeAction({ end: this.DeleteButton(index) })
            })
          }
          .width('100%')
          .layoutWeight(1)
        }
      }
      .width('100%')
      .height('100%')
    }
  }
  
  @Builder
  SiteItem(site: SiteModel, index: number) {
    Row() {
      Column() {
        Text(site.server || "未知地址")
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: 4 })
        
        Text(`用户名: ${site.user?.username || "未知"}`)
          .fontSize(14)
          .fontColor(Color.Gray)
      }
      .alignItems(HorizontalAlign.Start)
      .flexGrow(1)
      
      if (site.id === this.currentSiteId) {
        Text("当前")
          .fontSize(14)
          .fontColor(Color.Green)
          .margin({ right: 8 })
      } else {
        Button("使用")
          .fontSize(14)
          .height(32)
          .onClick(() => {
            this.switchSite(index)
          })
      }
    }
    .width('100%')
    .padding(15)
    .borderRadius(8)
    .backgroundColor(Color.White)
    .margin({ top: 8, bottom: 8 })
  }
  
  @Builder
  DeleteButton(index: number) {
    Button() {
      Text("删除")
        .fontSize(16)
        .fontColor(Color.White)
    }
    .width(80)
    .height('100%')
    .backgroundColor(Color.Red)
    .onClick(() => {
      this.deleteSite(index)
    })
  }
  
  switchSite(index: number) {
    const site = this.siteList[index]
    store.site = site
    store.save()
    this.currentSiteId = site.id ?? ""
    
    // 通知其他页面站点已更新
    context.action<SiteAction>("SiteAction", bean => bean.onSiteUpdate(site))
    
    promptAction.showToast({
      message: '站点切换成功',
      duration: 2000
    })
  }
  
  deleteSite(index: number) {
    AlertDialog.show({
      title: '确认删除',
      message: '确定要删除此站点吗？',
      primaryButton: {
        value: '确定',
        action: () => {
          // 检查是否删除当前站点
          const isCurrentSite = this.siteList[index].id === this.currentSiteId
          
          // 从列表中移除站点
          this.siteList.splice(index, 1)
          store.sites = this.siteList
          
          // 如果删除的是当前站点，并且还有其他站点，则切换到第一个站点
          if (isCurrentSite && this.siteList.length > 0) {
            store.site = this.siteList[0]
            this.currentSiteId = store.site.id
            
            // 通知其他页面站点已更新
            context.action<SiteAction>("SiteAction", bean => bean.onSiteUpdate(store.site))
          } 
          // 如果删除当前站点且没有其他站点
          else if (isCurrentSite && this.siteList.length === 0) {
            store.site = null
            this.currentSiteId = null
            
            // 跳转回登录页面
            setTimeout(() => {
              router.pushPage("pages/LoginPage", {})
            }, 500)
          }
          
          store.save()
          
          promptAction.showToast({
            message: '站点已删除',
            duration: 2000
          })
        }
      },
      secondaryButton: {
        value: '取消',
        action: () => {
          // 用户取消删除
        }
      }
    })
  }
}
