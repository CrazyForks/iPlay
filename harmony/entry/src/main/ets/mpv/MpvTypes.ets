/**
 * MPV Native Types - 简化版本，只包含API版本获取功能
 */

export interface MpvNative {
  /**
   * 获取MPV API版本
   */
  getMpvApiVersion(): Promise<number>;
}

/**
 * Native模块接口
 */
export interface NativeMpvModule {
  GetMpvApiVersion(): number;
}