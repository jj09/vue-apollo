<template>
  <div class="hello">
    <h1>{{ msg }}</h1>
    <h2>Hello message: {{ hello }}</h2>
    <button @click="getHello">Get Hello</button>
    <button @click="getHelloAsync">Get Hello Async</button>
    <h2>Cats:</h2>
    <ul>
      <li v-for="cat in cats" v-bind:key="cat.id">{{ cat.name }}</li>
    </ul>
    <button @click="getCatsAsync">Get Cats Async</button>
  </div>
</template>

<script>
import gql from "graphql-tag";

export default {
  name: "HelloWorld",
  props: {
    msg: String,
  },
  async created() {
    console.info("created");
  },
  // apollo: {
  //   hello: gql`
  //     query {
  //       hello
  //     }
  //   `,
  // },
  methods: {
    getHello() {
      this.$apollo
        .query({
          query: gql`
            query {
              hello
            }
          `,
        })
        .then((result) => {
          console.info(result.data);
          this.hello = result.data.hello;
        });
    },
    async getHelloAsync() {
      const {
        data: { hello },
      } = await this.$apollo.query({
        query: gql`
          query {
            hello
          }
        `,
      });
      console.info(hello);
      this.hello = hello;
    },
    async getCatsAsync() {
      const {
        data: { cats },
      } = await this.$apollo.query({
        query: gql`
          query {
            cats {
              id
              name
            }
          }
        `,
      });
      console.info(cats);
      this.cats = cats;
    },
  },
  data() {
    return {
      hello: "",
      cats: [],
    };
  },
};
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
h3 {
  margin: 40px 0 0;
}
ul {
  list-style-type: none;
  padding: 0;
}
li {
  display: inline-block;
  margin: 0 10px;
}
a {
  color: #42b983;
}
</style>
