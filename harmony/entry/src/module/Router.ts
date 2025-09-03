import { nil } from "../api/iPlayDataSource";
import { router as officialRouter } from "@kit.ArkUI";

export type Dict = {
  [key: string]: any | nil;
};

export interface Router {
  pushPage(name: string, params: Dict);
  replacePage(name: string, params: Dict);
  popPage();
  canGoBack(): boolean;
  goBack();
  params(): Dict;
  clear();
  setTarget(target: Router)
}


class ArkTsRouter implements Router {
  target?: Router = null
  setTarget(target: Router): void {
    this.target = target
  }

  replacePage(name: string, params: Dict): void {
    officialRouter.replaceUrl({
      url: name,
      params
    })
  }

  pushPage(name: string, params: Dict): void {
    if (this.target) {
      this.target.pushPage(name, params)
      return
    }
    officialRouter.pushUrl({
      url: name,
      params
    }, officialRouter.RouterMode.Standard)
  }

  popPage(): void {
    officialRouter.back()
  }

  canGoBack(): boolean {
    return true;
  }

  goBack(): void {
    officialRouter.back()
  }

  params(): Dict {
    return officialRouter.getParams()
  }

  clear(): void {
    officialRouter.clear()
  }
}

export const router: Router = new ArkTsRouter()