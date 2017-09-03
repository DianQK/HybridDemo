<template>
  <div class="http">
    <NativeTitle title="HTTP" />
    <a @click="send">Send</a>
    <div v-for="value in result">
      {{ value }}
    </div>
  </div>
</template>

<script>
import NativeTitle from './NativeTitle'

export default {
  name: 'hello',
  components: {
    NativeTitle
  },
  data () {
    return {
      result: []
    }
  },
  methods: {
    send () {
      let count = [1, 2, 3, 4, 5, 6, 7]
      count.forEach(value => {
        this.sendCount(value)
      })
    },
    async sendCount (count) {
      let res = await this.$native.event('http', { query : { count : count } })
      this.result.push(res.args)
    }
  }
}
</script>
