import { MediaModel, SiteModel } from '../api/iPlayDataSource'

export interface StarAction {
  onStarUpdate(media: MediaModel)
}