import video from '@ohos.multimedia.media';
import window from '@ohos.window';
import { BusinessError } from '@ohos.base';
import { Dict, router } from '../../../module/Router';
import { MediaModel, PlaybackModel } from '../../../api/iPlayDataSource';
import { FontIcon } from '../view/FontIcon';
import { IconDef } from '../view/IconDef';
import { store } from '../store/Store';
import { display } from '@kit.ArkUI';
import { audio } from '@kit.AudioKit';
import {
  BaseVideoPlayer,
  GlobalContext,
  IjkVideoPlayer,
  IVideoPlayer,
  PlayerType, StandardGSYVideoModel, StandardGSYVideoPlayer } from '@ohos/gsyvideoplayer';


@Builder
export function PageBuilder() {
  FullscreenVideoPlayer()
}

@Entry
@Component
struct FullscreenVideoPlayer {
  private controller: VideoController = new VideoController();
  @State params: Dict = router.params()
  @State isPlaying: boolean = true;
  @State currentTime: number = 0;
  @State duration: number = 0;
  @State isFullScreen: boolean = false;
  @State title: string = ""
  @State isLoading: boolean = false;
  @State videoSrc: string = '';
  // 手势控制相关状态
  @State playbackRate: number = 1.0; // 播放速度
  @State screenBrightness: number = 0.5; // 屏幕亮度 (0-1)
  @State volume: number = 0.5; // 音量 (0-1)
  @State showSpeedTip: boolean = false; // 显示倍速提示
  @State showBrightnessTip: boolean = false; // 显示亮度提示
  @State showVolumeTip: boolean = false; // 显示音量提示
  @State showProgressTip: boolean = false; // 显示进度提示
  @State tipText: string = ''; // 提示文字
  // 手势控制变量
  private longPressTimer: number | undefined = undefined;
  private isLongPressing: boolean = false;
  private originalPlaybackRate: number = 1.0;
  private panStartX: number = 0;
  private panStartY: number = 0;
  private screenWidth: number = 0;
  private screenHeight: number = 0;
  // 获取窗口对象
  private windowClass: window.Window | null = null;
  @State ijkComponentVisible: Visibility = Visibility.Hidden;
  videoModel: StandardGSYVideoModel = new StandardGSYVideoModel();
  videoPlayer?: IVideoPlayer
  videoTimer?: number
  videoInit: (iVideoPlayer: IVideoPlayer, xid: string) => void = (iVideoPlayer: IVideoPlayer, xid: string) => {
    this.videoPlayer = iVideoPlayer
    this.videoPlayer.setUp(this.videoModel.getUrl(), this.videoModel.getCacheWithPlay())

    this.videoPlayer?.play();
    this.videoPlayer.firstOrSeek = true
    this.videoPlayer?.setOnPlayingListener(() => {
      this.duration = (this.videoPlayer?.getDuration() ?? 0) / 1000
      this.currentTime = (this.videoPlayer?.getCurrentPosition() ?? 0) / 1000
    })
  }


  aboutToAppear() {
    GlobalContext.getContext().setObject("playType", PlayerType.IJK_PLAYER);
    // 获取屏幕尺寸
    display.getDefaultDisplay().then(displayInfo => {
      this.screenWidth = displayInfo.width;
      this.screenHeight = displayInfo.height;
    });

    let playback = this.params["playback"] as PlaybackModel
    if (playback != undefined) {
      this.videoSrc = playback.sources?.[0].url ?? ""
    } else {
      new Promise<void>(async () => {
        this.isLoading = true
        let playback = await this.fetchPlayback()
        if (playback) {
          this.ijkComponentVisible = Visibility.Visible
          this.videoSrc = playback.sources?.[0].url ?? ""
          this.videoModel.setUrl(this.videoSrc, false);
          this.videoModel.setTitle(this.title);
        }
        this.isLoading = false
      })
    }
    let media = this.params["media"] as MediaModel
    if (media != undefined) {
      this.title = media.title ?? ""
    }
    window.getLastWindow(this.getUIContext().getHostContext()).then((win: window.Window) => {
      this.windowClass = win;
      let block = async () => {
        await win.setPreferredOrientation(window.Orientation.LANDSCAPE);
        await win.setWindowSystemBarEnable([]); // 隐藏状态栏
        await win.setWindowLayoutFullScreen(true);
        this.isFullScreen = true

        // 初始化亮度和音量
        this.initBrightnessAndVolume();
      }
      block()
    });

    this.videoTimer = setInterval(() => {
      this.currentTime = (this.videoPlayer?.getCurrentPosition() ?? 0) / 1000
    }, 1000)
  }

  aboutToDisappear() {
    clearInterval(this.videoTimer)
    window.getLastWindow(this.getUIContext().getHostContext()).then((win: window.Window) => {
      this.windowClass = win;
      let block = async () => {
        await win.setPreferredOrientation(window.Orientation.PORTRAIT);
        await win.setWindowSystemBarEnable(['status', 'navigation']); // 隐藏状态栏
        await win.setWindowLayoutFullScreen(false);
        this.isFullScreen = false
      }
      block()
    });
  }

  async fetchPlayback() {
    let media = this.params["media"] as MediaModel
    if (media == undefined) {
      return
    }
    let playback = await store.api?.getPlayback(media?.id ?? "")
    return playback
  }

  // 初始化亮度和音量
  private initBrightnessAndVolume() {
    try {
      // 获取当前亮度
      if (this.windowClass) {
        this.screenBrightness = this.windowClass.getWindowProperties().brightness;
      }

      // 获取当前音量
      audio.getAudioManager().getVolumeManager();
    } catch (error) {
      console.error('初始化亮度音量失败:', error);
    }
  }

  // 设置亮度
  private setBrightness(brightness: number) {
    if (this.windowClass && brightness >= 0 && brightness <= 1) {
      this.screenBrightness = brightness;
      this.windowClass.setWindowBrightness(brightness);
      this.showBrightnessTip = true;
      this.tipText = `亮度: ${Math.round(brightness * 100)}%`;
      this.hideTipAfterDelay();
      this.windowClass?.setWindowBrightness(this.screenBrightness)
    }
  }

  // 设置音量
  private setVolume(volume: number) {
    if (volume >= 0 && volume <= 1) {
      this.volume = volume;
      // 这里需要实际设置系统音量的API
      // audio.getAudioManager().getVolumeManager().setVolume(audio.AudioVolumeType.MEDIA, Math.round(volume * 15));
      this.showVolumeTip = true;
      this.tipText = `音量: ${Math.round(volume * 100)}%`;
      this.hideTipAfterDelay();
    }
  }

  // 设置播放速度
  private setPlaybackRate(rate: number) {
    this.playbackRate = rate;
    // 这里需要设置视频播放速度的API
    this.showSpeedTip = true;
    this.tipText = `倍速: ${rate}x`;
    this.hideTipAfterDelay();
  }

  // 隐藏提示
  private hideTipAfterDelay() {
    setTimeout(() => {
      this.showSpeedTip = false;
      this.showBrightnessTip = false;
      this.showVolumeTip = false;
      this.showProgressTip = false;
    }, 1500);
  }

  build() {
    NavDestination() {
      Stack() {
        Stack() {
          if (this.videoSrc !== '') {
            this.VideoPlayerComponent()
          }
          // 手势提示层
          this.GestureTipLayer()

          if (this.isLoading) {
            LoadingProgress()
              .width(80)
              .height(80)
              .color(Color.White)
          }
        }
        .width("100%")
        .height("100%")
        // 添加手势识别
        .gesture(
          GestureGroup(GestureMode.Exclusive,
            // 长按手势 - 倍速播放
            LongPressGesture({ repeat: false, duration: 500 })
              .onAction(() => {
                this.onLongPress();
              })
              .onActionEnd(() => {
                this.onLongPressEnd();
              }),

            // 拖拽手势 - 进度、亮度、音量控制
            PanGesture({ fingers: 1, direction: PanDirection.All, distance: 10 })
              .onActionStart((event: GestureEvent) => {
                this.onPanStart(event);
              })
              .onActionUpdate((event: GestureEvent) => {
                this.onPanUpdate(event);
              })
              .onActionEnd(() => {
                this.onPanEnd();
              }),

            // 双击手势 - 切换播放状态（必须放在单击手势之前）
            TapGesture({ count: 2 })
              .onAction(() => {
                this.togglePlayback();
              }),

            // 点击手势 - 显示/隐藏控制面板
            TapGesture({ count: 1 })
              .onAction(() => {
                this.toggleControls();
              }),
          )
        )

        this.ControlPanel()
      }
    }
  }

  @Builder
  VideoPlayerComponent() {
    Column() {
      IjkVideoPlayer({ videoInit: this.videoInit, isVisible: this.ijkComponentVisible })
    }
    .width('100%')
    .height(this.isFullScreen ? '100%' : 300)
  }

  @Builder
  GestureTipLayer() {
    Stack() {
      // 倍速提示
      if (this.showSpeedTip) {
        Row() {
          Text(this.tipText)
            .fontColor(Color.White)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .backgroundColor('rgba(0, 0, 0, 0.7)')
            .borderRadius(8)
            .padding({
              top: 8,
              bottom: 8,
              left: 12,
              right: 12
            })
        }
        .justifyContent(FlexAlign.Center)
      }

      // 亮度提示
      if (this.showBrightnessTip && false) {
        Row() {
          Column() {
            FontIcon({
              icon: IconDef.ic_fluent_brightness_high_24_filled,
              iconColor: '#FFFFFF',
              iconSize: 24
            })
            Text(this.tipText)
              .fontColor(Color.White)
              .fontSize(14)
              .margin({ top: 8 })
          }
          .backgroundColor('rgba(0, 0, 0, 0.7)')
          .borderRadius(8)
          .padding(16)
        }
        .justifyContent(FlexAlign.Start)
        .alignItems(VerticalAlign.Center)
        .margin({ left: 50 })
      }

      // 音量提示
      if (this.showVolumeTip && false) {
        Row() {
          Column() {
            FontIcon({
              icon: IconDef.ic_fluent_speaker_2_24_filled,
              iconColor: '#FFFFFF',
              iconSize: 24
            })
            Text(this.tipText)
              .fontColor(Color.White)
              .fontSize(14)
              .margin({ top: 8 })
          }
          .backgroundColor('rgba(0, 0, 0, 0.7)')
          .borderRadius(8)
          .padding(16)
        }
        .justifyContent(FlexAlign.End)
        .alignItems(VerticalAlign.Center)
        .margin({ right: 50 })
      }

      // 进度提示
      if (this.showProgressTip) {
        Row() {
          Text(this.tipText)
            .fontColor(Color.White)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .backgroundColor('rgba(0, 0, 0, 0.7)')
            .borderRadius(8)
            .padding({
              top: 8,
              bottom: 8,
              left: 12,
              right: 12
            })
        }
        .justifyContent(FlexAlign.Center)
        .margin({ bottom: 100 })
      }
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Center)
  }

  @Builder
  ControlPanel() {
    Column() {
      Row() {
        Text(this.title)
          .fontColor("#ffffffff")
          .margin({ top: 10 })
      }
      .flexGrow(0)

      Row() {
        FontIcon({
          icon: IconDef.ic_fluent_dismiss_24_filled,
          iconSize: 18
        })
          .margin(5)
          .onClick(() => {
            router.popPage()
          })
      }
      .justifyContent(FlexAlign.End)
      .width('90%')

      Row() {

      }
      .flexGrow(1)

      Row() {
        // 左侧控制按钮组 - 与进度条左侧对齐
        Row() {

        }
        .margin({ left: 10 }) // 与进度条左侧的padding对齐

        Column()
          .flexGrow(1)
        // FontIcon({
        //   icon: IconDef.ic_fluent_top_speed_24_filled
        // })
        //   .margin(5)
        //   .enabled(false)
        // FontIcon({
        //   icon: IconDef.ic_fluent_orientation_24_filled
        // })
        //   .margin(5)
        //   .enabled(false)
        // FontIcon({
        //   icon: IconDef.ic_fluent_news_24_filled
        // })
        //   .margin(5)
        //   .enabled(false)
      }
      .width('90%')
      .flexGrow(0)
      .margin({ bottom: 5 })

      Row() {
        Row() {
          FontIcon({
            icon: IconDef.ic_fluent_skip_back_10_24_filled,
            iconSize: 18
          })
            .margin(5)
            .onClick(() => {
              this.videoPlayer?.seekTo((this.currentTime - 10) * 1000)
            })
          FontIcon({
            icon: this.isPlaying ? IconDef.ic_fluent_pause_32_filled : IconDef.ic_fluent_play_24_filled,
            iconSize: 18
          })
            .margin(5)
            .onClick(() => {
              this.togglePlayback()
            })
          FontIcon({
            icon: IconDef.ic_fluent_skip_forward_10_24_filled,
            iconSize: 18
          })
            .margin(5)
            .onClick(() => {
              this.videoPlayer?.seekTo((this.currentTime + 10) * 1000)
            })
        }
        .margin({bottom: 8})
        Slider({
          value: this.currentTime,
          min: 0,
          max: this.duration,
          step: 1
        })
          .layoutWeight(1)
          .backgroundColor('#88000000')
          .borderRadius(10)
          .padding({ left: 10, right: 10 })
          .margin({ bottom: 10, left: 10, right: 20 })
          .height(36)
          .onChange((value: number) => {
            // seek
            this.videoPlayer?.seekTo(value * 1000)
          })

        // 时间信息显示
        Text(`${this.formatTime(this.currentTime)} / ${this.formatTime(this.duration)}`)
          .fontColor('#FFFFFF')
          .fontSize(14)
          .margin({ left: 0, bottom: 10, right: 10 })
          .textAlign(TextAlign.End)
      }
      .width('90%')
      .align(Alignment.Center)
      .flexShrink(0)

    }
    .backgroundColor("#00000000")
    .height('100%')
    .width('100%')
    .hitTestBehavior(HitTestMode.Transparent)
    .visibility(this.showControls ? Visibility.Visible : Visibility.Hidden)
  }

  private async toggleFullscreen() {
    if (!this.windowClass) {
      return;
    }

    try {
      if (!this.isFullScreen) {
        await this.windowClass.setPreferredOrientation(window.Orientation.LANDSCAPE);
        await this.windowClass.setWindowSystemBarEnable([]); // 隐藏状态栏
        await this.windowClass.setWindowLayoutFullScreen(true);
        this.isFullScreen = true;
        this.controller.requestFullscreen(true);
      } else {
        await this.windowClass.setPreferredOrientation(window.Orientation.PORTRAIT);
        await this.windowClass.setWindowSystemBarEnable(['status', 'navigation']);
        await this.windowClass.setWindowLayoutFullScreen(false);
        this.isFullScreen = false;
        this.controller.exitFullscreen();
      }
    } catch (error) {
      console.error('全屏切换失败:', (error as BusinessError).message);
    }
  }

  @State showControls: boolean = true;

  private toggleControls() {
    this.showControls = !this.showControls;
  }

  private togglePlayback() {
    let player = this.videoPlayer
    if (player) {
      if (this.isPlaying) player.pause();
      else player.resumePlay();
    }

    this.isPlaying = !this.isPlaying;
  }

  private formatTime(seconds: number): string {
    const min = Math.floor(seconds / 60);
    const sec = Math.floor(seconds % 60);
    return `${min.toString().padStart(2, '0')}:${sec.toString().padStart(2, '0')}`;
  }

  // 手势处理方法
  private onLongPress() {
    this.isLongPressing = true;
    this.originalPlaybackRate = this.playbackRate;
    this.setPlaybackRate(2.0); // 长按2倍速播放
  }

  private onLongPressEnd() {
    if (this.isLongPressing) {
      this.isLongPressing = false;
      this.setPlaybackRate(this.originalPlaybackRate); // 恢复原始速度
    }
  }

  private onPanStart(event: GestureEvent) {
    this.panStartX = event.fingerList[0].localX;
    this.panStartY = event.fingerList[0].localY;
  }

  private onPanUpdate(event: GestureEvent) {
    const currentX = event.fingerList[0].localX;
    const currentY = event.fingerList[0].localY;
    const deltaX = currentX - this.panStartX;
    const deltaY = currentY - this.panStartY;

    // 判断是横向滑动还是纵向滑动
    if (Math.abs(deltaX) > Math.abs(deltaY)) {
      // 横向滑动 - 调整进度
      this.handleProgressGesture(deltaX);
    } else {
      // 纵向滑动 - 调整亮度或音量
      if (this.panStartX < this.screenWidth / 2) {
        // 左侧 - 调整亮度
        this.handleBrightnessGesture(deltaY);
      } else {
        // 右侧 - 调整音量
        this.handleVolumeGesture(deltaY);
      }
    }
  }

  private onPanEnd() {
    // 滑动结束，可以在这里添加一些结束处理
  }

  private handleProgressGesture(deltaX: number) {
    if (this.duration <= 0) {
      return;
    }

    // 计算进度变化（屏幕宽度对应总时长）
    const progressChange = (deltaX / this.screenWidth) * this.duration;
    let newTime = this.currentTime + progressChange;

    // 确保时间在有效范围内
    newTime = Math.max(0, Math.min(newTime, this.duration));

    this.showProgressTip = true;
    this.tipText = `${this.formatTime(newTime)} / ${this.formatTime(this.duration)}`;
    this.hideTipAfterDelay();

    // 实际调整播放进度
    this.controller.setCurrentTime(newTime);
  }

  private handleBrightnessGesture(deltaY: number) {
    // 纵向滑动调整亮度（向上增加亮度，向下降低亮度）
    const brightnessChange = -(deltaY / this.screenHeight);
    let newBrightness = this.screenBrightness + brightnessChange;

    // 确保亮度在0-1范围内
    newBrightness = Math.max(0, Math.min(1, newBrightness));
    this.setBrightness(newBrightness);
  }

  private handleVolumeGesture(deltaY: number) {
    // 纵向滑动调整音量（向上增加音量，向下降低音量）
    const volumeChange = -(deltaY / this.screenHeight);
    let newVolume = this.volume + volumeChange;

    // 确保音量在0-1范围内
    newVolume = Math.max(0, Math.min(1, newVolume));
    this.setVolume(newVolume);
  }
}