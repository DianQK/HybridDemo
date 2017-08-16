import Vue from 'vue'
import Router from 'vue-router'
import Hello from '@/components/Hello'
import Hybrid from '@/components/Hybrid'

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
    }
  ]
})

router.afterEach(route => {
  // window.$native.title = route.meta.title
  // window.$native.rightBarTitle = route.meta.rightBarTitle
  window.$native.title = ''
  window.$native.rightBarTitle = ''
})

export default router
