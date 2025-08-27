import { SiteModel } from '../api/iPlayDataSource'

export interface SiteAction {
  onSiteUpdate(site: SiteModel)
}