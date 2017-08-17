<template>
  <div>
    <NativeTitle :title="title" />
    hybrid
    <div class="">
      <input type="text" v-model="title">
    </div>
  </div>
</template>

<script>
import NativeTitle from './NativeTitle'

export default {
  name: 'hybrid',
  components: {
    NativeTitle
  },
  data () {
    return {
      title: 'Hybrid Page'
    }
  }
}
</script>

<style scoped>
input {
  height: 30px;
  line-height: 30px;
  box-sizing: border-box;
  padding: 0 15px;
  border: 1px solid #e3e3e3;
  color: #2c3e50;
  outline: none;
  /*border-radius: 15px;*/
  margin-right: 10px;
  transition: border-color 0.2s ease;
  background-size: 20px;
  vertical-align: middle !important;
}

input:focus {
  border-color: #42b983;
}
</style>
