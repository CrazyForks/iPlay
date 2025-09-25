import { MpvPlayer } from './MpvPlayer';
import { MpvConfig, MpvPlayState } from './MpvTypes';

/**
 * MPV测试页面
 */
@Entry
@Component
struct MpvTestPage {
  @State mpvPlayer: MpvPlayer = new MpvPlayer();
  @State apiVersion: number = 0;
  @State isInitialized: boolean = false;
  @State currentState: MpvPlayState = MpvPlayState.IDLE;
  @State errorMessage: string = '';
  @State currentTime: number = 0;
  @State duration: number = 0;
  @State volume: number = 50;

  async aboutToAppear() {
    await this.initializeMpv();
  }

  async aboutToDisappear() {
    await this.mpvPlayer.destroy();
  }

  /**
   * 初始化MPV
   */
  async initializeMpv() {
    try {
      // 获取API版本
      this.apiVersion = await this.mpvPlayer.getApiVersion();
      console.info(`MPV API Version: ${this.apiVersion}`);

      // 初始化配置
      const config: MpvConfig = {
        vo: 'gpu',
        ao: 'audiotrack',
        hwdec: true,
        msgLevel: 'info'
      };

      // 初始化播放器
      this.isInitialized = await this.mpvPlayer.initialize(config);
      if (this.isInitialized) {
        this.currentState = this.mpvPlayer.getPlayState();
        this.errorMessage = '';
        console.info('MPV initialized successfully');
      } else {
        this.errorMessage = 'Failed to initialize MPV';
        console.error(this.errorMessage);
      }
    } catch (error) {
      this.errorMessage = `Initialization error: ${error}`;
      console.error('MPV initialization failed:', error);
    }
  }

  /**
   * 加载并播放视频
   */
  async loadAndPlay() {
    if (!this.isInitialized) {
      this.errorMessage = 'MPV not initialized';
      return;
    }

    try {
      // 这里使用一个测试视频URL
      const videoUrl = 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4';
      const loaded = await this.mpvPlayer.loadFile(videoUrl);
      
      if (loaded) {
        await this.mpvPlayer.play();
        this.currentState = this.mpvPlayer.getPlayState();
        this.errorMessage = '';
        
        // 开始更新播放进度
        this.startProgressUpdate();
      } else {
        this.errorMessage = 'Failed to load video';
      }
    } catch (error) {
      this.errorMessage = `Load error: ${error}`;
      console.error('Failed to load video:', error);
    }
  }

  /**
   * 播放/暂停切换
   */
  async togglePlayPause() {
    if (!this.isInitialized) return;

    try {
      const currentState = this.mpvPlayer.getPlayState();
      if (currentState === MpvPlayState.PLAYING) {
        await this.mpvPlayer.pause();
      } else {
        await this.mpvPlayer.play();
      }
      this.currentState = this.mpvPlayer.getPlayState();
    } catch (error) {
      this.errorMessage = `Playback error: ${error}`;
      console.error('Playback toggle failed:', error);
    }
  }

  /**
   * 停止播放
   */
  async stopPlayback() {
    if (!this.isInitialized) return;

    try {
      await this.mpvPlayer.stop();
      this.currentState = this.mpvPlayer.getPlayState();
      this.currentTime = 0;
      this.duration = 0;
    } catch (error) {
      this.errorMessage = `Stop error: ${error}`;
      console.error('Stop failed:', error);
    }
  }

  /**
   * 设置音量
   */
  async setVolume(volume: number) {
    if (!this.isInitialized) return;

    try {
      this.volume = volume;
      await this.mpvPlayer.setVolume(volume);
    } catch (error) {
      this.errorMessage = `Volume error: ${error}`;
      console.error('Set volume failed:', error);
    }
  }

  /**
   * 跳转进度
   */
  async seekTo(position: number) {
    if (!this.isInitialized || this.duration <= 0) return;

    try {
      const targetTime = (position / 100) * this.duration;
      await this.mpvPlayer.seek(targetTime);
    } catch (error) {
      this.errorMessage = `Seek error: ${error}`;
      console.error('Seek failed:', error);
    }
  }

  /**
   * 开始进度更新
   */
  startProgressUpdate() {
    const updateInterval = setInterval(async () => {
      if (!this.isInitialized || this.currentState !== MpvPlayState.PLAYING) {
        clearInterval(updateInterval);
        return;
      }

      try {
        this.currentTime = await this.mpvPlayer.getCurrentTime();
        if (this.duration === 0) {
          this.duration = await this.mpvPlayer.getDuration();
        }
      } catch (error) {
        console.error('Progress update failed:', error);
      }
    }, 1000);
  }

  /**
   * 格式化时间显示
   */
  formatTime(seconds: number): string {
    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  }

  build() {
    Column({ space: 20 }) {
      Text('MPV Player Test')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)

      // API版本显示
      Text(`MPV API Version: ${this.apiVersion}`)
        .fontSize(16)
        .fontColor(Color.Blue)

      // 状态显示
      Text(`Status: ${this.isInitialized ? 'Initialized' : 'Not Initialized'}`)
        .fontSize(16)
        .fontColor(this.isInitialized ? Color.Green : Color.Red)

      Text(`Play State: ${this.currentState}`)
        .fontSize(16)

      // 错误信息
      if (this.errorMessage) {
        Text(this.errorMessage)
          .fontSize(14)
          .fontColor(Color.Red)
          .margin({ top: 10 })
      }

      // 播放时间信息
      if (this.duration > 0) {
        Text(`${this.formatTime(this.currentTime)} / ${this.formatTime(this.duration)}`)
          .fontSize(16)

        // 进度条
        Slider({
          value: this.duration > 0 ? (this.currentTime / this.duration) * 100 : 0,
          min: 0,
          max: 100,
          step: 1
        })
          .blockColor(Color.Blue)
          .trackColor(Color.Gray)
          .selectedColor(Color.Blue)
          .onChange((value: number) => {
            this.seekTo(value);
          })
          .width('80%')
      }

      // 控制按钮
      Row({ space: 15 }) {
        Button('Load & Play')
          .onClick(() => this.loadAndPlay())
          .enabled(this.isInitialized)

        Button(this.currentState === MpvPlayState.PLAYING ? 'Pause' : 'Play')
          .onClick(() => this.togglePlayPause())
          .enabled(this.isInitialized)

        Button('Stop')
          .onClick(() => this.stopPlayback())
          .enabled(this.isInitialized)
      }

      // 音量控制
      Row({ space: 10 }) {
        Text('Volume:')
        Slider({
          value: this.volume,
          min: 0,
          max: 100,
          step: 1
        })
          .blockColor(Color.Blue)
          .trackColor(Color.Gray)
          .selectedColor(Color.Blue)
          .onChange((value: number) => {
            this.setVolume(value);
          })
          .width(200)

        Text(`${this.volume}%`)
      }

      // 重新初始化按钮
      Button('Re-initialize MPV')
        .onClick(() => this.initializeMpv())
        .backgroundColor(Color.Orange)
        .margin({ top: 20 })
    }
    .width('100%')
    .height('100%')
    .padding(20)
    .justifyContent(FlexAlign.Center)
  }
}