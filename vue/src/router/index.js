import Vue from 'vue'
import Router from 'vue-router'
import Hello from '@/components/Hello'
import Hybrid from '@/components/Hybrid'
import HTTP from '@/components/HTTP'
import Go from '@/components/Go'

Vue.use(Router)

const router = new Router({
  routes: [
    {
      path: '/',
      name: 'Hello',
      component: Hello,
      meta: { title: 'Hello', rightBarTitle: 'Chat' }
    },
    {
      path: '/hybrid',
      name: 'Hybrid',
      component: Hybrid,
      meta: { title: 'Hybrid Page'}
    },
    {
      path: '/http',
      name: 'Http',
      component: HTTP,
      meta: { title: 'HTTP'}
    },
    {
      path: '/go',
      name: 'Go',
      component: Go,
      meta: { title: 'Go'}
    }
  ]
})

router.go = (n) => {
  window.$native.event('go', n)
  router.history.go(n)
}

router.push = (location, onComplete, onAbort) => {
  window.$native.event('navigation')
  router.history.push(location, onComplete, onAbort)
}

router.afterEach(route => {
  // window.$native.title = route.meta.title
  // window.$native.rightBarTitle = route.meta.rightBarTitle
  // window.$native.title = ''
  // window.$native.rightBarTitle = ''
})

export default router
