import window from '@ohos.window';
import { Dict, router } from '../../../module/Router';
import { MediaModel, PlaybackModel } from '../../../api/iPlayDataSource';
import { store } from '../store/Store';
import { display } from '@kit.ArkUI';
import { 
  StandardGSYVideoPlayer, 
  StandardGSYVideoModel, 
  GlobalContext, 
  PlayerType,
  BaseVideoPlayer 
} from '@ohos/gsyvideoplayer';
import { MpvPlayer, MpvConfig, MpvPlayState, MpvApiTest } from '../mpv/index';

@Builder
export function PageBuilder() {
  FullscreenVideoPlayer()
}

@Entry
@Component
struct FullscreenVideoPlayer {
  @State params: Dict = router.params()
  @State isFullScreen: boolean = false;
  @State title: string = ""
  @State isLoading: boolean = false;
  @State videoSrc: string = '';
  @State showMpvTest: boolean = false;
  
  // GSYVideoPlayer 相关
  private videoModel: StandardGSYVideoModel = new StandardGSYVideoModel();
  
  // MPV播放器相关
  @State mpvPlayer: MpvPlayer = new MpvPlayer();
  @State mpvApiVersion: number = 0;
  @State useMpvPlayer: boolean = false; // 切换播放器的标志
  @State mpvTestResults: string[] = [];
  
  private screenWidth: number = 0;
  private screenHeight: number = 0;
  // 获取窗口对象
  private windowClass: window.Window | null = null;

  aboutToAppear() {
    // 设置播放器类型为系统AVPlayer
    GlobalContext.getContext().setObject("playType", PlayerType.SYSTEM_AVPLAYER);

    // 获取屏幕尺寸
    display.getDefaultDisplay().then(displayInfo => {
      this.screenWidth = displayInfo.width;
      this.screenHeight = displayInfo.height;
    });

    // 初始化MPV并获取API版本
    this.initMpv();

    // 初始化视频数据
    this.initVideoData();

    // 设置窗口为横屏和全屏
    window.getLastWindow(this.getUIContext().getHostContext()).then((win: window.Window) => {
      this.windowClass = win;
      let block = async () => {
        await win.setPreferredOrientation(window.Orientation.LANDSCAPE);
        await win.setWindowSystemBarEnable([]); // 隐藏状态栏
        await win.setWindowLayoutFullScreen(true);
        this.isFullScreen = true
      }
      block()
    });
  }

  /**
   * 初始化MPV播放器
   */
  private async initMpv() {
    try {
      // 获取MPV API版本 - 这里调用了mpv_client_api_version函数
      this.mpvApiVersion = await this.mpvPlayer.getApiVersion();
      console.info(`MPV API Version: ${this.mpvApiVersion}`);
      
      this.mpvTestResults.push(`MPV API Version: ${this.mpvApiVersion}`);
      this.mpvTestResults.push(`Major: ${(this.mpvApiVersion >> 16) & 0xFFFF}, Minor: ${this.mpvApiVersion & 0xFFFF}`);
      
      // 如果成功获取到版本，说明MPV可用
      if (this.mpvApiVersion > 0) {
        const config: MpvConfig = {
          vo: 'gpu',
          ao: 'audiotrack',
          hwdec: true,
          msgLevel: 'info'
        };
        
        const initialized = await this.mpvPlayer.initialize(config);
        if (initialized) {
          console.info('MPV initialized successfully');
          this.mpvTestResults.push('✅ MPV initialized successfully');
          // 可以选择使用MPV播放器
          // this.useMpvPlayer = true;
        } else {
          this.mpvTestResults.push('❌ MPV initialization failed');
        }
      } else {
        this.mpvTestResults.push('❌ Invalid MPV API version');
      }
    } catch (error) {
      console.error('MPV initialization failed:', error);
      this.mpvTestResults.push(`❌ MPV Error: ${error}`);
      // 降级到GSY播放器
      this.useMpvPlayer = false;
    }
  }

  /**
   * 运行MPV API测试
   */
  private async runMpvTests() {
    const apiTest = new MpvApiTest();
    try {
      this.mpvTestResults = ['🚀 Starting MPV API Tests...'];
      await apiTest.runAllTests();
      this.mpvTestResults.push('🎉 All tests completed successfully!');
    } catch (error) {
      this.mpvTestResults.push(`💥 Tests failed: ${error}`);
    }
  }

  private async initVideoData() {
    // 获取媒体信息
    let media = this.params["media"] as MediaModel
    if (media != undefined) {
      this.title = media.title ?? ""
    }

    // 获取播放信息
    let playback = this.params["playback"] as PlaybackModel
    if (playback != undefined) {
      this.videoSrc = playback.sources?.[0].url ?? ""
    } else {
      this.isLoading = true
      let playback = await this.fetchPlayback()
      if (playback) {
        this.videoSrc = playback.sources?.[0].url ?? ""
      }
      this.isLoading = false
    }

    // 配置视频模型
    this.setupVideoModel();
  }

  private setupVideoModel() {
    if (this.videoSrc) {
      // 配置GSYVideoPlayer
      this.videoModel.setUrl(this.videoSrc, false); // 不缓存播放
      this.videoModel.setTitle(this.title);
      
      // 设置返回按钮回调
      this.videoModel.setBackClickListener(() => {
        router.popPage();
      });
      
      // 设置全屏按钮回调（这里可以保持空实现，因为已经是全屏状态）
      this.videoModel.setFullClickListener(() => {
        // 全屏逻辑由GSYVideoPlayer内部处理
      });
    }
  }

  aboutToDisappear() {
    // 停止GSY播放器
    let player = GlobalContext.getContext().getObject("currentPlayer") as BaseVideoPlayer;
    if (player) {
      player.stop();
    }

    // 停止MPV播放器
    if (this.mpvPlayer.isInitialized()) {
      this.mpvPlayer.destroy();
    }

    // 恢复窗口状态
    window.getLastWindow(this.getUIContext().getHostContext()).then((win: window.Window) => {
      this.windowClass = win;
      let block = async () => {
        await win.setPreferredOrientation(window.Orientation.PORTRAIT);
        await win.setWindowSystemBarEnable(['status', 'navigation']); // 显示状态栏
        await win.setWindowLayoutFullScreen(false);
        this.isFullScreen = false
      }
      block()
    });
  }

  onPageShow() {
    let player = GlobalContext.getContext().getObject("currentPlayer") as BaseVideoPlayer;
    if (player) {
      player.resumePlay();
    }
  }

  onPageHide() {
    let player = GlobalContext.getContext().getObject("currentPlayer") as BaseVideoPlayer;
    if (player) {
      player.pause();
    }
  }

  async fetchPlayback() {
    let media = this.params["media"] as MediaModel
    if (media == undefined) {
      return
    }
    let playback = await store.api?.getPlayback(media?.id ?? "")
    return playback
  }

  /**
   * 切换播放器引擎
   */
  private togglePlayerEngine() {
    this.useMpvPlayer = !this.useMpvPlayer;
    console.info(`Switched to ${this.useMpvPlayer ? 'MPV' : 'GSY'} player`);
  }

  /**
   * 显示/隐藏MPV测试界面
   */
  private toggleMpvTest() {
    this.showMpvTest = !this.showMpvTest;
  }

  @Builder
  PlayerEngineSelector() {
    Row({ space: 10 }) {
      Text(`Current: ${this.useMpvPlayer ? 'MPV' : 'GSY'}`)
        .fontSize(14)
        .fontColor(Color.White)
        .backgroundColor('rgba(0,0,0,0.7)')
        .padding(8)
        .borderRadius(4)

      Text(`MPV API: ${this.mpvApiVersion}`)
        .fontSize(12)
        .fontColor(Color.White)
        .backgroundColor('rgba(0,0,0,0.7)')
        .padding(8)
        .borderRadius(4)

      Button('Switch Engine')
        .fontSize(12)
        .height(30)
        .onClick(() => this.togglePlayerEngine())

      Button('MPV Test')
        .fontSize(12)
        .height(30)
        .onClick(() => this.toggleMpvTest())
    }
    .position({ x: 10, y: 10 })
  }

  build() {
    NavDestination() {
      Stack() {
        if (this.videoSrc !== '' && !this.showMpvTest) {
          if (this.useMpvPlayer && this.mpvPlayer.isInitialized()) {
            // 这里可以添加MPV播放器的UI组件
            // 目前先显示GSY播放器
            StandardGSYVideoPlayer({
              videoModel: this.videoModel
            })
            .width('100%')
            .height('100%')
          } else {
            StandardGSYVideoPlayer({
              videoModel: this.videoModel
            })
            .width('100%')
            .height('100%')
          }
        }

        if (this.showMpvTest) {
          // 显示MPV测试页面
          Column({ space: 10 }) {
            Text('MPV API Test Results')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .margin({ bottom: 10 })

            Row({ space: 10 }) {
              Button('Run Tests')
                .onClick(() => this.runMpvTests())
                .backgroundColor(Color.Blue)
                .fontSize(14)

              Button('Close')
                .onClick(() => this.toggleMpvTest())
                .backgroundColor(Color.Red)
                .fontSize(14)
            }

            Scroll() {
              Column({ space: 5 }) {
                ForEach(this.mpvTestResults, (result: string, index: number) => {
                  Text(`${index + 1}. ${result}`)
                    .fontSize(12)
                    .fontColor(Color.White)
                    .backgroundColor('rgba(0,0,0,0.6)')
                    .padding(8)
                    .borderRadius(4)
                    .width('100%')
                    .textAlign(TextAlign.Start)
                }, (result: string, index: number) => `${index}_${result}`)
              }
            }
            .width('90%')
            .height('60%')
            .backgroundColor('rgba(0,0,0,0.3)')
            .borderRadius(8)
            .padding(10)

            Text(`Current MPV API Version: ${this.mpvApiVersion}`)
              .fontSize(14)
              .fontColor(this.mpvApiVersion > 0 ? Color.Green : Color.Red)
              .margin({ top: 10 })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .backgroundColor('rgba(0,0,0,0.8)')
          .padding(20)
        }

        if (this.isLoading) {
          LoadingProgress()
            .width(80)
            .height(80)
            .color(Color.White)
        }

        // 播放器引擎选择器
        this.PlayerEngineSelector()
      }
      .width("100%")
      .height("100%")
    }
  }
}