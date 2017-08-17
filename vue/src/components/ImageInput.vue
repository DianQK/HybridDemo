<template>
  <a @click="selectImage">选择图片</a>
</template>

<script>
export default {
  methods: {
    async selectImage () {
      let response = await this.$native.event('selectImage')
      this.$emit('imageSelected', response.image)
    }
  }
}
</script>
