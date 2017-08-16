<template>
</template>

<script>
export default {
  name: 'nativeRightBar',
  props: {
    title: String
  },
  watch: {
    'title': (newTitle) => {
      window.$native.rightBarTitle = newTitle
    }
  },
  created () {
    this.$native.rightBarTitle = this.title
    this.$native.rightBarClick = () => {
      this.$emit('click')
    }
  }
}
</script>
