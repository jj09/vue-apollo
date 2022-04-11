<template>
  <div class="hello">
    <h1>{{ msg }}</h1>
    <h2>Hello message: {{ hello }}</h2>
    <button @click="getHello">Get Hello</button>
    <button @click="getHelloAsync">Get Hello Async</button>
    <h2>Books:</h2>
    <ul>
      <li v-for="book in books" v-bind:key="book.id">
        {{ book.title }} ({{ book.year }})
      </li>
    </ul>
    <button @click="getBooksAsync">Get Books Async</button>
    <h2>Add Book</h2>
    <label for="title">Title: </label>
    <input type="text" id="title" v-model="title" />
    <br />
    <label for="year">Year: </label>
    <input type="text" id="year" v-model="year" />
    <br />
    <button @click="addBook">Add Book</button>
  </div>
</template>

<script>
import gql from "graphql-tag";

export default {
  name: "HelloWorld",
  props: {
    msg: String,
  },
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
    async getBooksAsync() {
      const {
        data: { books },
      } = await this.$apollo.query({
        query: gql`
          query {
            books {
              id
              title
              year
            }
          }
        `,
      });
      console.info(books);
      this.books = books;
    },
    async addBook() {
      console.info(`Adding book ${this.title} (${this.year})...`);
      const {
        data: { book },
      } = await this.$apollo.mutate({
        mutation: gql`
          mutation ($year: Int!, $title: String!) {
            book: createBook(year: $year, title: $title) {
              title
              year
            }
          }
        `,
        variables: {
          year: Number(this.year),
          title: this.title,
        },
        error: (error) => console.error(error),
      });
      console.info("Book added", book);
    },
  },
  data() {
    return {
      hello: "",
      books: [],
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
