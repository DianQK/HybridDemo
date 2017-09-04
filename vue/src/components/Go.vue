<template>
  <div class="http">
    <NativeTitle title="Go" />
    <a @click="go">Go</a>
  </div>
</template>

<script>
import NativeTitle from './NativeTitle'

export default {
  name: 'go',
  components: {
    NativeTitle
  },
  data () {
    return {
      result: []
    }
  },
  methods: {
    go () {
      this.$router.go(-2)
    }
  }
}
</script>
