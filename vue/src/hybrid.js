export var native = {}

window.$native = native

var callbacks = {}

native.callbacks = callbacks

function generateUUID () {
  var d = new Date().getTime()
  var uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    var r = (d + Math.random()*16)%16 | 0
    d = Math.floor(d/16)
    return (c=='x' ? r : (r&0x7|0x8)).toString(16)
  })
  return uuid
}

Object.defineProperty(native, 'title', { set: (title) => {
  title = title || ''
  window.webkit.messageHandlers.title.postMessage({ title })
} })

Object.defineProperty(native, 'rightBarTitle', { set: (title) => {
  title = title || ''
  window.webkit.messageHandlers.rightBarTitle.postMessage({ title })
} })

let webLog = console.log

console.log = (...message) => {
  webLog(message)
  window.webkit.messageHandlers.log.postMessage(`${JSON.stringify(message)}`)
}

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
