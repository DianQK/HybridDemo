<template>
  <div class="http">
    <NativeTitle title="HTTP" />
    <router-link to="go">Go</router-link>
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
      this.result = []
      let count = [1, 2, 3, 4, 5, 6, 7, 8, 9]
      count.forEach(value => {
        this.sendCount(value)
      })
    },
    async sendCount (count) {
      this.$native.$loading = true
      try {
        let res = await this.$native.event('http', { query : { count : count } })
        this.result.push(res.args)
      } catch (e) {
        console.log(e.code)
        this.result.push(e)
      }
      this.$native.$loading = false
    }
  }
}
</script>
