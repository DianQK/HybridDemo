<template>
  <a @click="selectImage()">
    选择图片
    <input type="file" accept="image/*" @change="selectImage" v-show="false" ref="imageInput"/>
  </a>
</template>

<script>
export default {
  methods: {
    async selectImage (e) {
      if (e) {
        let files = e.target.files;
        if (files.length === 0) {
          this.$emit('imageSelected', null)
          return
        }
        let reader = new FileReader();
        reader.onload = (e) => {
          this.$emit('imageSelected', e.target.result)
        }
        reader.readAsDataURL(files[0])
      } else if (window.$native.embedded) {
        let response = await this.$native.event('selectImage')
        this.$emit('imageSelected', response.image)
      } else {
        this.$refs.imageInput.click()
      }
    }
  }
}
</script>
