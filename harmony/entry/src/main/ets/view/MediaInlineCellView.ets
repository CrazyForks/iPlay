import { MediaModel, nil } from "../../../api/iPlayDataSource";
import { logger } from "../../../module/Log";
import { router } from "../../../module/Router";


@Component
export struct MediaInlineCellView {
  @Prop model: MediaModel|nil;
  @Prop layout: string|nil

  public constructor(model: MediaModel|null, layout: string = "auto") {
    super();
    this.model = model;
    this.layout = this.layout
  }

  build() {
    Row() {
      Flex() {
        Image(this.imageUrl())
          .width(this.cellWidth())
          .aspectRatio(this.cellImageAspect())
          .margin(5)
          .borderRadius(10)
          .backgroundColor("#e5e5e5")
          .flexShrink(0)
        Column() {
          Text(this.model?.title)
            .fontSize(15)
            .fontWeight(FontWeight.Normal)
            .lineBreakStrategy(LineBreakStrategy.HIGH_QUALITY)
            .textAlign(TextAlign.Center)
            .maxLines(1)

          Text(this.model?.overview)
            .fontSize(12)
            .foregroundColor(Color.Gray)
            .fontWeight(FontWeight.Normal)
            .lineBreakStrategy(LineBreakStrategy.HIGH_QUALITY)
            .textAlign(TextAlign.Center)
            .maxLines(4)
        }
        .flexGrow(1)
      }
    }
    .onClick(() => {
      logger.info(this.model?.title);
      let type = this.model?.type?.toLowerCase() ?? "movie"
      let page = "pages/AlbumPage"
      switch (type) {
        case "series":
          page = "pages/MediaPage"
          break;
        case "movie":
          page = "pages/MediaPage"
          break;
        case "episode":
          page = "pages/PlayerPage"
          break;
        case "season":
          page = "pages/SeasonPage"
          break;
      }
      router.pushPage(page, {
        media: this.model,
        albumId: this.model?.id
      })
    })
  }

  cellWidth() {
    let type = this.model?.type?.toLowerCase()
    let width = 160;
    return width
  }

  cellImageAspect() {
    let type = this.model?.type?.toLowerCase()
    let width = 16/9;
    return width
  }

  imageUrl() {
    let type = this.model?.type?.toLowerCase()
    if (this.layout == "auto") {
      if (type == "movie") {
        return this.model?.image?.backdrop ?? ""
      }
    } else if (this.layout == "2/3") {
      return this.model?.image?.primary ?? ""
    } else {
      return this.model?.image?.backdrop ?? ""
    }

    return this.model?.image?.primary ?? ""
  }
}