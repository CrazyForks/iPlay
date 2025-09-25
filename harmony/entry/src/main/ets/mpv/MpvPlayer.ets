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
      return await this.mpvNative.getMpvApiVersion();
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
  async getMpvApiVersion(): Promise<number> {
    try {

      console.log("mpv version" + libmpv.GetMpvApiVersion() + "")
      const version = libmpv.GetMpvApiVersion();
      return version;
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : String(error);
      console.error('MPV API: Failed to call native function:', errorMsg);
      
      // 发生错误时返回模拟值
      const mockVersion = 0x20005; // MPV API Version 2.5
      const majorVersion = (mockVersion >> 16) & 0xFFFF;
      const minorVersion = mockVersion & 0xFFFF;
      console.info(`=== MPV Client API Version Info (Error Fallback) ===`);
      console.info(`Version: ${majorVersion}.${minorVersion} (0x${mockVersion.toString(16)})`);
      console.info(`Implementation: Mock/Simulated`);
      console.info(`Reason: Native call failed - ${errorMsg}`);
      console.info(`Status: Using error fallback implementation`);
      console.info(`==================================================`);
      
      return mockVersion;
    }
  }
}