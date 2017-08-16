<template>
  <div class="hello">
    <NativeTitle title="Hello" />
    <NativeRightBar :title="rightBarTitle" @click="rightBarClick" />
    <ul>
      <router-link to="hybrid">Hybrid</router-link>
      <li><a @click="selectImage">选择图片</a></li>
      <li><a @click="changeRightBarTitle('Forum')">Forum</a></li>
      <li><a @click="changeRightBarTitle('Chat')">Chat</a></li>
      <li><a @click="changeRightBarTitle('')">Remove</a></li>
      {{count}}
      <ImageX :src="selectedImage" style="width: 200px; margin-top: 20px;" fullScreen/>
    </ul>
  </div>
</template>

<script>
import NativeTitle from './NativeTitle'
import NativeRightBar from './NativeRightBar'
import ImageX from './ImageX'
import logo from '../assets/logo.png'

export default {
  name: 'hello',
  components: {
    NativeTitle,
    NativeRightBar,
    ImageX
  },
  data () {
    return {
      selectedImage: logo,
      count: 0,
      rightBarTitle: 'Chat',
    }
  },
  methods: {
    async selectImage () {
      let response = await this.$native.event('selectImage')
      this.selectedImage = response.image
    },
    changeRightBarTitle (title) {
      this.rightBarTitle = title
    },
    rightBarClick () {
      this.count += 1
      console.log({ count: this.count })
    }
  }
}
</script>
