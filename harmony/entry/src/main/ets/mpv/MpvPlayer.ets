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
      // 先检查native模块是否可用
      console.info('MPV API: Attempting to load native module...');
      
      if (typeof globalThis.requireNapi !== 'function') {
        console.info('MPV API: globalThis.requireNapi is not available - using mock implementation');
        const mockVersion = 0x20005; // MPV API Version 2.5
        const majorVersion = (mockVersion >> 16) & 0xFFFF;
        const minorVersion = mockVersion & 0xFFFF;
        console.info(`=== MPV Client API Version Info ===`);
        console.info(`Mock Version: ${majorVersion}.${minorVersion} (0x${mockVersion.toString(16)})`);
        console.info(`Implementation: Mock/Simulated`);
        console.info(`Status: Native module not available, using fallback`);
        console.info(`=================================`);
        return mockVersion;
      }

      console.log(libmpv.GetMpvApiVersion() + "")
      const mpvNative = globalThis.requireNapi('mpvnative') as NativeMpvModule;
      
      if (!mpvNative) {
        console.info('MPV API: Native module mpvnative not found - using fallback implementation');
        const mockVersion = 0x20005;
        const majorVersion = (mockVersion >> 16) & 0xFFFF;
        const minorVersion = mockVersion & 0xFFFF;
        console.info(`=== MPV Client API Version Info (Fallback) ===`);
        console.info(`Version: ${majorVersion}.${minorVersion} (0x${mockVersion.toString(16)})`);
        console.info(`Implementation: Mock/Simulated`);
        console.info(`Reason: Native module not compiled/loaded`);
        console.info(`Status: Using fallback implementation`);
        console.info(`============================================`);
        return mockVersion;
      }
      
      if (typeof mpvNative.GetMpvApiVersion !== 'function') {
        console.info('MPV API: GetMpvApiVersion function not found - using fallback implementation');
        const mockVersion = 0x20005;
        const majorVersion = (mockVersion >> 16) & 0xFFFF;
        const minorVersion = mockVersion & 0xFFFF;
        console.info(`=== MPV Client API Version Info (Fallback) ===`);
        console.info(`Version: ${majorVersion}.${minorVersion} (0x${mockVersion.toString(16)})`);
        console.info(`Implementation: Mock/Simulated`);
        console.info(`Reason: Native function not found`);
        console.info(`Status: Using fallback implementation`);
        console.info(`============================================`);
        return mockVersion;
      }
      
      console.info('MPV API: Calling native GetMpvApiVersion function');
      
      const version = mpvNative.GetMpvApiVersion();
      console.info(`MPV API: Native function returned version: ${version}`);
      
      const majorVersion = (version >> 16) & 0xFFFF;
      const minorVersion = version & 0xFFFF;
      console.info(`=== MPV Client API Version Info (Native) ===`);
      console.info(`Version: ${majorVersion}.${minorVersion} (0x${version.toString(16)})`);
      console.info(`Implementation: Native C++/NAPI`);
      console.info(`Status: Successfully loaded from native module`);
      console.info(`==========================================`);
      
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