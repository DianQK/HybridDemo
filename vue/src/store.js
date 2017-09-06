import Vuex from 'vuex'
import Vue from 'vue'
import logo from './assets/logo.png'

Vue.use(Vuex)

const store = new Vuex.Store({
  state: {
    count: 0,
    rightBarTitle: '',
    hybridPageTitle: 'Hybrid Page',
    selectedImage: logo,
    response: []
  },
  mutations: {
    increment (state) {
      state.count++
    },
    selectImage (state, image) {
      state.selectedImage = image
    }
  }
})

export default store
