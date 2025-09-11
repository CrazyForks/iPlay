import { EmbyApi } from "../../../api/emby/EmbyApi";
import { iPlayDataSourceApi, nil, SiteModel } from "../../../api/iPlayDataSource"
import { kv } from "../../../module/KVStorage";

export enum AppThemeMode {
    LIGHT = 'light',
    DARK = 'dark',
    AUTO = 'auto'
}

export class Store {
    site: SiteModel|nil;
    sites: SiteModel[]|nil;
    api: iPlayDataSourceApi|nil;
    // 外观设置
    themeMode: AppThemeMode = AppThemeMode.LIGHT;

    addSite(site: SiteModel) {
      this.site = site;
      this.sites = [...(this.sites ?? []), this.site]
      this.save()
    }

    switchSite(site: SiteModel) {
      this.site = site;
      if (this.site != null) {
        let api = new EmbyApi()
        api.setSite(site)
        this.api = api
      }
      this.save()
    }
    
    // 更新主题模式
    setThemeMode(mode: AppThemeMode) {
      this.themeMode = mode;
      this.save();
    }

    load() {
      let old = kv.get<Store>("@store")
      this.site = old?.site
      this.sites = old?.sites
      if (this.site != null) {
        let api = new EmbyApi()
        this.api = api
      }
    }

    save() {
      kv.set("@store", this)
    }
}

export const store = new Store()