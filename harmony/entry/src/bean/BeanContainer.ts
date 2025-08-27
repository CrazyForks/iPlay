import { List } from "@kit.ArkTS"

class BeanContainer {
  beans = new Map<string, any>()
  proxies = new Map<string, any[]>()

  get<T>(type: string): T | null {
    if (this.beans.has(type)) {
      return this.beans.get(type) as T
    }
    return null
  }

  set<T>(type: string, value: T|null) {
    this.beans.set(type, value)
  }

  action<T>(type: string, callback: (bean: T) => void) {
    if (this.proxies.has(type)) {
      let targets = this.proxies.get(type)
      targets?.forEach(callback)
    }
  }

  watch<T>(type: string, observer: T) {
    let targets: T[]
    if (this.proxies.has(type)) {
      targets = this.proxies.get(type)
    } else {
      targets = []
    }
    targets?.push(observer)
    this.proxies.set(type, targets)
  }

  unwatch<T>(type: string, observer: T) {
    let targets: T[]
    if (this.proxies.has(type)) {
      targets = this.proxies.get(type)
    } else {
      targets = []
    }
    targets = targets.filter(target => target != observer)
    this.proxies.set(type, targets)
  }
}

export const context = new BeanContainer()