<template>
  <img ref="targetImage"
    class="target-image"
    v-bind:class="{'fade-in': fadeIn}"
    :src="src"
    v-show="show"
    @click="displayImage"
    >
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
      show: true,
      fadeIn: false
    }
  },
  methods: {
    async displayImage () {
      if (!this.fullScreen) { return }
      if (window.$native.embedded) {
        let width = this.$refs.targetImage.width
        let height = this.$refs.targetImage.height
        let x = this.$refs.targetImage.offsetLeft
        let y = this.$refs.targetImage.offsetTop
        this.show = false
        await this.$native.event('displayImage', { x, y, width, height, image: this.src })
        this.show = true
      } else {
        this.fadeIn = !this.fadeIn
      }
    }
  }
}
</script>

<style lang="less" scoped>
.target-image {
  width: 200px;
  margin-top: 20px;


  &.fade-in {
    height: 100%;
    width: 100%;
    transform-origin: 100px;
    // transform: scale(1);
    // max-width: 100%;
    // width: 100%;
    // max-height: 100%;
    // bottom: 0;
    // left: 0;
    // margin: auto;
    // overflow: auto;
    // position: fixed;
    // right: 0;
    // top: 0;
  }

  transition: all 0.3s ease-in-out;
}
</style>
