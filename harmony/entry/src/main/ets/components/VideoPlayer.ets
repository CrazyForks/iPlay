import libmpvnative from 'libplayer.so'
import hilog from '@ohos.hilog';

const LOG_TAG = 'VideoPlayerComponent';
const LOG_DOMAIN = 0x3201;

@Component
export struct VideoPlayer {
  @Prop url: string = "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8";
  private mpvHandle: number | null = null;
  private xcomponentController: XComponentController = new XComponentController();

  static readonly ON_COLOR: string = "rgba(24, 36, 49, 1.0)"
  static readonly OFF_COLOR: string = "rgba(255, 255, 255, 1.0)"

  aboutToAppear() {
    hilog.info(LOG_DOMAIN, LOG_TAG, 'aboutToAppear: Creating mpv instance.');
    this.mpvHandle = libmpvnative.create();
    if (this.mpvHandle) {
      hilog.info(LOG_DOMAIN, LOG_TAG, `libmpvnative.create success, handle: ${this.mpvHandle}`);
    } else {
      hilog.error(LOG_DOMAIN, LOG_TAG, 'libmpvnative.create failed');
    }
  }

  aboutToDisappear() {
    hilog.info(LOG_DOMAIN, LOG_TAG, 'aboutToDisappear: Cleaning up GL resources.');
    if (libmpvnative.destroyGL) {
      libmpvnative.destroyGL();
    }
    if (this.mpvHandle && libmpvnative.destroy) {
      libmpvnative.destroy(this.mpvHandle);
      this.mpvHandle = null;
    }
  }

  build() {
    Stack({
      alignContent: Alignment.TopStart
    }) {
      XComponent({
        id: "entry-ui-surface",
        type: XComponentType.SURFACE,
        libraryname: "player",
        controller: this.xcomponentController
      })
        .onLoad(() => {
          hilog.info(LOG_DOMAIN, LOG_TAG, 'XComponent onLoad callback triggered.');
          if (!this.mpvHandle) {
            hilog.error(LOG_DOMAIN, LOG_TAG, 'Cannot set surface because mpv handle is null.');
            return;
          }

          // Initialize OpenGL surface for rendering
          if (libmpvnative.initSurface) {
            libmpvnative.initSurface("entry-ui-surface");
            hilog.info(LOG_DOMAIN, LOG_TAG, 'libmpvnative.initSurface called.');
          }

          setTimeout(() => {
            if (libmpvnative.setupGL) {
              libmpvnative.setupGL(this.mpvHandle);
              hilog.info(LOG_DOMAIN, LOG_TAG, 'libmpvnative.setupGL called.');
            }

          }, 1000)
          // Set up OpenGL rendering context

        })
        .onDestroy(() => {
          hilog.info(LOG_DOMAIN, LOG_TAG, 'XComponent onDestroy callback triggered.');
          if (libmpvnative.destroyGL) {
            libmpvnative.destroyGL();
          }
        })
        .margin({
          top: 0,
          left: 0,
          right: 0,
          bottom: 0
        })
        .padding({
          top: 0,
          left: 0,
          right: 0,
          bottom: 0
        })
        .height("100%")
        .width("100%")
        .backgroundColor(Color.Black)
    }
    .width("100%")
    .height("100%")
  }
}