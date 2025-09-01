import { EmbyApi } from '../../../api/emby/EmbyApi';
import { SiteModel } from '../../../api/iPlayDataSource'
import { context } from '../../../bean/BeanContainer';
import { SiteAction } from '../../../bean/SiteAction';
import { logger } from '../../../module/Log';
import { store } from '../store/Store';
import { common, Want } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct LoginPage {
  @State serverAddress: string = '';
  @State username: string = '';
  @State password: string = '';
  @State loading: boolean = false;
  @State agreeTerm: boolean = false;

  private context = getContext(this) as common.UIAbilityContext;

  openUrl(url: string) {
    try {
      let want: Want = {
        action: 'ohos.want.action.viewData',
        entities: ['entity.system.browsable'],
        uri: url,
      };
      this.context.startAbility(want)
        .then(() => {
          console.info('Open browser successfully');
        })
        .catch((err: BusinessError) => {
          console.error('Failed to open browser. Error code: ' + err.code + ', message: ' + err.message);
        });
    } catch (error) {
      console.error('An unexpected error occurred. Error code: ' + error.code + ', message: ' + error.message);
    }
  }

  build() {
    Column() {
      Row() {
        Text("输入你的Emby站点信息")
          .fontSize(22)
          .fontWeight("bold")
          .margin({ top: 12 , bottom: 18 })
      }
      Row() {
        Text('服务器')
          .fontSize(16)
          .margin({ right: 10 })

        TextInput({ text: this.serverAddress, placeholder: "http://media.emby.com:8096" })
          .type(InputType.Normal)
          .width('80%')
          .height(40)
          .flexGrow(1)
          .border({ width: 1, color: '#cccccc' })
          .borderRadius(4)
          .onChange((value: string) => {
            this.serverAddress = value;
          })
      }
      .width('100%')

      Row() {
        Text('用户名')
          .fontSize(16)
          .margin({ right: 10 })

        TextInput({ text: this.username, placeholder: "guest" })
          .type(InputType.Normal)
          .width('80%')
          .flexGrow(1)
          .height(40)
          .border({ width: 1, color: '#cccccc' })
          .borderRadius(4)
          .onChange((value: string) => {
            this.username = value;
          })
      }
      .width('100%')
      .margin({ top: 15 })


      Row() {
        Text('密　码')
          .fontSize(16)
          .margin({ right: 10 })

        TextInput({ text: this.password, placeholder: "password" })
          .type(InputType.Password)
          .width('80%')
          .height(40)
          .flexGrow(1)
          .border({ width: 1, color: '#cccccc' })
          .borderRadius(4)
          .onChange((value: string) => {
            this.password = value;
          })
      }
      .width('100%')
      .margin({ top: 15 })


      Row() {
        Checkbox()
          .select(this.agreeTerm)
          .onChange(v => {
            this.agreeTerm = v
          })
        Text("已阅读并同意")
        Text("服务协议")
          .foregroundColor(Color.Blue)
          .onClick(() => {
            let url = "https://github.com/saltpi/iPlay"
            this.openUrl(url)
          })
        Text("和")
        Text("隐私政策")
          .foregroundColor(Color.Blue)
          .onClick(() => {
            let url = "https://github.com/saltpi/iPlay/blob/develop/PRIVACY.md"
            this.openUrl(url)
          })
      }
      .margin({top: 15})


      Button() {
        if (this.loading) {
          Row() {
            LoadingProgress() // 内置加载进度组件
              .color(Color.White)
            Text("登录中...")
              .foregroundColor(Color.White)
          }
        } else {
          Text("登录")
            .foregroundColor(Color.White)
        }
      }
      .enabled(this.agreeTerm)
      .width('90%')
      .height(40)
      .margin({ top: 30 })
      .backgroundColor('#007DFF')
      .fontColor(Color.White)
      .onClick(() => {
        if (this.serverAddress && this.username && this.password) {
          console.log('尝试登录：', this.serverAddress);
          this.loading = true;
          let api = new EmbyApi()
          let site: SiteModel = {
            id: null,
            type: "emby",
            server: this.serverAddress,
            user: {
              id: null,
              username: this.username,
              password: this.password,
              accessToken: null,
            },
            extra: undefined
          }
          api.login(site).then(site => {
            store.api = api
            store.addSite(site)
            logger.info(`${site}`)
            this.getUIContext().getPromptAction().showToast({
              message: `登录成功`,
              duration: 2000,
              bottom: '50%',
            });
            setTimeout(() => {
              context.action<SiteAction>("SiteAction", bean => bean.onSiteUpdate(site))
              this.getUIContext().getRouter().back()
            }, 500)
            this.loading = false;
          }).catch((err: object) => {
            logger.error(`${err}`)
            this.getUIContext().getPromptAction().showToast({
              message: `${err}`,
              duration: 2000, // 显示时长（毫秒）
              bottom: '50%'   // 距离底部位置
            });
            this.loading = false;
          })
        } else {
          this.getUIContext().getPromptAction().showToast({
            message: `请填写完整登录信息`,
            duration: 2000, // 显示时长（毫秒）
            bottom: '50%'   // 距离底部位置
          });
          console.error('请填写完整登录信息');
        }
      })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
    .padding(10)
  }
}