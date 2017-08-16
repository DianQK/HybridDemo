<template>
</template>

<script>
export default {
  name: 'nativeTitle',
  props: {
    title: String
  },
  watch: {
    'title': (newTitle) => {
      window.$native.title = newTitle
    }
  },
  created () {
    this.$native.title = this.title
  }
}
</script>
