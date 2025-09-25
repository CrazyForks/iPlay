import { MpvPlayer } from '../mpv/MpvPlayer';

/**
 * 简单的MPV API测试
 */
export class MpvApiTest {
  private mpvPlayer: MpvPlayer;

  constructor() {
    this.mpvPlayer = new MpvPlayer();
  }

  /**
   * 测试MPV API版本获取
   */
  async testMpvApiVersion(): Promise<void> {
    try {
      console.info('Testing MPV API version...');
      
      // 调用mpv_client_api_version函数
      const apiVersion = await this.mpvPlayer.getApiVersion();
      
      console.info(`MPV API Version: ${apiVersion}`);
      console.info(`MPV API Major Version: ${(apiVersion >> 16) & 0xFFFF}`);
      console.info(`MPV API Minor Version: ${apiVersion & 0xFFFF}`);
      
      if (apiVersion > 0) {
        console.info('✅ MPV API version test PASSED');
        return Promise.resolve();
      } else {
        console.error('❌ MPV API version test FAILED - Invalid version returned');
        return Promise.reject('Invalid API version');
      }
    } catch (error) {
      console.error('❌ MPV API version test FAILED:', error);
      return Promise.reject(error);
    }
  }

  /**
   * 测试MPV实例创建
   */
  async testMpvInstanceCreation(): Promise<void> {
    try {
      console.info('Testing MPV instance creation...');
      
      const initialized = await this.mpvPlayer.initialize();
      
      if (initialized && this.mpvPlayer.isInitialized()) {
        console.info('✅ MPV instance creation test PASSED');
        
        // 清理实例
        await this.mpvPlayer.destroy();
        return Promise.resolve();
      } else {
        console.error('❌ MPV instance creation test FAILED');
        return Promise.reject('Failed to create MPV instance');
      }
    } catch (error) {
      console.error('❌ MPV instance creation test FAILED:', error);
      return Promise.reject(error);
    }
  }

  /**
   * 运行所有测试
   */
  async runAllTests(): Promise<void> {
    console.info('🚀 Starting MPV API Tests...');
    
    try {
      await this.testMpvApiVersion();
      await this.testMpvInstanceCreation();
      
      console.info('🎉 All MPV API tests PASSED!');
    } catch (error) {
      console.error('💥 MPV API tests FAILED:', error);
      throw error;
    }
  }
}