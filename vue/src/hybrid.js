export var native = {}

window.$native = native

window.$native.embedded = window.webkit != undefined // You can change this, write your embedded

function generateUUID () {
  var d = new Date().getTime()
  var uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    var r = (d + Math.random()*16)%16 | 0
    d = Math.floor(d/16)
    return (c=='x' ? r : (r&0x7|0x8)).toString(16)
  })
  return uuid
}

if (window.$native.embedded) {
  Object.defineProperty(native, 'title', { set: (title) => {
    title = title || ''
    window.webkit.messageHandlers.title.postMessage({ title })
  } })

  Object.defineProperty(native, 'rightBarTitle', { set: (title) => {
    title = title || ''
    window.webkit.messageHandlers.rightBarTitle.postMessage({ title })
  } })
}

if (window.$native.embedded) {
  let webLog = console.log

  console.log = (...message) => {
    webLog(message)
    window.webkit.messageHandlers.log.postMessage(`${JSON.stringify(message)}`)
  }
}

if (window.$native.embedded) {
  var callbacks = {}
  native.callbacks = callbacks

  native.event = (name, params) => {
    let uuid = generateUUID()
    callbacks[uuid] = {}
    let message = {
      callbackId: uuid,
      content: params || {}
    }
    let promise = new Promise(function(resolve, reject) {
      callbacks[uuid].callback = (res) => {
        resolve(res)
        delete callbacks[uuid]
      }
    })
    window.webkit.messageHandlers[name].postMessage(message)
    return promise
  }
} else {
  native.event = (name) => {
    console.error('unsupport', name)
  }
}
