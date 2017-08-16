<template>
  <img :src="src" v-show="show" @click="displayImage" ref="image">
</template>

<script>
export default {
  props: {
    src: String,
    fullScreen: {
      type: Boolean,
      default: false
    }
  },
  data () {
    return {
      show: true
    }
  },
  methods: {
    async displayImage () {
      if (this.fullScreen) {
        let width = this.$refs.image.width
        let height = this.$refs.image.height
        let x = this.$refs.image.offsetLeft
        let y = this.$refs.image.offsetTop
        this.show = false
        await this.$native.event('displayImage', { x, y, width, height, image: this.src })
        this.show = true
      }
    }
  }
}
</script>

<style scoped>
</style>
