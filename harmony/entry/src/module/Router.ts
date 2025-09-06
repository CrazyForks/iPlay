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
  addTarget?(target: Router, label: string)
  setCurrentTarget?(label: string)
}


class ArkTsRouter implements Router {
  target?: Router = null
  targets: Map<string, Router> = new Map<string, Router>()
  playerPagePushed = false

  setTarget(target: Router): void {
    this.target = target
  }

  addTarget(target: Router, label: string) {
    this.targets.set(label, target)
  }

  setCurrentTarget(name: string) {
    this.setTarget(this.targets.get(name))
  }

  replacePage(name: string, params: Dict): void {
    officialRouter.replaceUrl({
      url: name,
      params
    })
  }

  pushPage(name: string, params: Dict): void {
    if (name.includes("PlayerPage")) {
      this.playerPagePushed = true
    } else {
      this.playerPagePushed = false
    }

    if (this.target && !this.playerPagePushed) {
      this.target.pushPage(name, params)
      return
    }
    officialRouter.pushUrl({
      url: name,
      params
    }, officialRouter.RouterMode.Standard)
  }

  popPage(): void {
    if (this.playerPagePushed) {
      this.playerPagePushed = false
      officialRouter.back()
    } else if (this.target) {
      this.target.popPage()
    } else {
      officialRouter.back()
    }
  }

  canGoBack(): boolean {
    return true;
  }

  goBack(): void {
    if (this.playerPagePushed) {
      this.playerPagePushed = false
      officialRouter.back()
    } else if (this.target) {
      this.target.goBack()
    } else {
      officialRouter.back()
    }
  }

  params(): Dict {
    if (this.target && !this.playerPagePushed) {
      return this.target.params()
    }
    return officialRouter.getParams()
  }

  clear(): void {
    officialRouter.clear()
  }
}

export const router: Router = new ArkTsRouter()