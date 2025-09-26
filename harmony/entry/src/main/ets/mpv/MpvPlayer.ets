import { MpvNative, NativeMpvModule } from './MpvTypes';
import libmpv from "libmpvnative.so"

/**
 * MPV播放器包装类 - 简化版本，只提供API版本获取功能
 */
export class MpvPlayer {
  private mpvNative: MpvNative;
  
  constructor() {
    // 创建真实的native模块实现
    this.mpvNative = new MpvNativeImpl();
  }



  /**
   * 获取MPV API版本
   */
  async getApiVersion(): Promise<number> {
    try {
      return await this.mpvNative.GetMpvApiVersion();
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : String(error);
      console.error('Failed to get MPV API version:', errorMsg);
      throw new Error(errorMsg);
    }
  }

  async create(): Promise<number> {
    try {
      return await this.mpvNative.MpvCreate();
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : String(error);
      console.error('Failed to get MPV API version:', errorMsg);
      throw new Error(errorMsg);
    }
  }

  async loadVideo(mpv: number, url: string): Promise<void> {
    try {
      await this.mpvNative.LoadVideo(mpv, url);
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : String(error);
      console.error('Failed to get MPV API version:', errorMsg);
      throw new Error(errorMsg);
    }
  }
}

/**
 * MPV Native实现类
 */
class MpvNativeImpl implements MpvNative {
  async GetMpvApiVersion(): Promise<number> {
    try {
      console.log("mpv version" + libmpv.GetMpvApiVersion() + "")
      const version = libmpv.GetMpvApiVersion();
      return version;
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : String(error);
      console.error('MPV API: Failed to call native function:', errorMsg);
      return -1;
    }
  }

  async MpvCreate(): Promise<number> {
    return libmpv.MpvCreate();
  }

  async LoadVideo(mpv: number, url: string): Promise<void> {
    await libmpv.loadVideo(mpv, url);
  }
}
