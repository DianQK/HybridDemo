class NativeError { // extends Error {
  constructor ({ code, message }) {
    // super()
    this.code = code
    this.message = message
  }
}

class Native {

  get embedded () {
    return window.webkit != undefined // You can change this, write your embedded
  }

  set title (title) {
    title = title || ''
    this.perform('title', { title })
  }

  set rightBarTitle (title) {
    title = title || ''
    this.perform('rightBarTitle', { title })
  }

  _loadingCount = 0
  set $loading (value) {
    if (value) {
      this._loadingCount = this._loadingCount + 1
    } else {
      if (this._loadingCount <= 0) {
        return
      }
      this._loadingCount = this._loadingCount - 1
    }
    if (this._loadingCount === 0) {
      this.event('loading', false)
    }
    if (this._loadingCount === 1) {
      this.event('loading', true)
    }
  }
  get $loading () {
    return this._loadingCount > 0
  }

  callbacks = {}

  event (name, params) {
    let uuid = generateUUID()
    let message = {
      callbackId: uuid,
      content: params || {}
    }
    let promise = new Promise((resolve, reject) => {
      this.callbacks[uuid] = {
        callback: (res) => {
          if (res.error) {
            reject(new NativeError(res.error))
          } else {
            resolve(res)
          }
          delete this.callbacks[uuid]
        }
      }
    })
    this.perform(name, message)
    return promise
  }

  perform (name, message) {
    if (!this.embedded) {
      return
    }
    if ((window.webkit) && window.webkit.messageHandlers[name]) {
      window.webkit.messageHandlers[name].postMessage(message)
    }
  }

  constructor() {
    window.$native = this
  }

}

const native = new Native()

function generateUUID () {
  var d = new Date().getTime()
  var uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    var r = (d + Math.random()*16)%16 | 0
    d = Math.floor(d/16)
    return (c=='x' ? r : (r&0x7|0x8)).toString(16)
  })
  return uuid
}

export default native
