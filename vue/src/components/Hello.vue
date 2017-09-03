<template>
  <div class="hello">
    <NativeTitle title="Hello" />
    <NativeRightBar :title="rightBarTitle" @click="rightBarClick" />
    <ul>
      <li><router-link to="hybrid">Hybrid</router-link></li>
      <li><router-link to="http">Http</router-link></li>
      <li><ImageInput @imageSelected="imageSelected" /></li>
      <li><a @click="changeRightBarTitle('Forum')">Forum</a></li>
      <li><a @click="changeRightBarTitle('Chat')">Chat</a></li>
      {{count}}
      <ImageX :src="selectedImage" fullScreen/>
    </ul>
  </div>
</template>

<script>
import NativeTitle from './NativeTitle'
import NativeRightBar from './NativeRightBar'
import ImageX from './ImageX'
import ImageInput from './ImageInput'
import logo from '../assets/logo.png'

export default {
  name: 'hello',
  components: {
    NativeTitle,
    NativeRightBar,
    ImageX,
    ImageInput
  },
  data () {
    return {
      selectedImage: logo,
      count: 0,
      rightBarTitle: 'Chat',
    }
  },
  methods: {
    imageSelected (image) {
      this.selectedImage = image
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
