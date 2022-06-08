<template>
  <div class="hello">
    <h1>{{ msg }}</h1>
    <h2>Hello message: {{ hello }}</h2>
    <button @click="getHello">Get Hello</button>
    <button @click="getHelloAsync">Get Hello Async</button>
    <h2>Books:</h2>
    <ul>
      <li
        v-for="book in books"
        v-bind:key="book.id"
        style="display: block; margin: 10px"
      >
        <span v-if="isEditingBook(book.id)">
          <label for="edittitle">Title: </label>
          <input type="text" id="edittitle" v-model="edittitle" />
          &nbsp;
          <label for="edityear">Year: </label>
          &nbsp;
          <input type="text" id="edityear" v-model="edityear" />
          &nbsp;
          <button @click="saveBook">Save</button>
        </span>
        <span v-else>
          {{ book.title }} ({{ book.year }})
          <button @click="editBook(book.id, book.title, book.year)">Edit</button
          >&nbsp;
        </span>
        <button @click="deleteBook(book.id)">Delete</button>
      </li>
    </ul>
    <button @click="getBooksAsync">Get Books Async</button>
    <h2>Add Book</h2>
    <label for="title">Title: </label>
    <input type="text" id="title" v-model="title" />
    &nbsp;
    <label for="year">Year: </label>
    &nbsp;
    <input type="text" id="year" v-model="year" />
    &nbsp;
    <button @click="addBook">Add Book</button>
  </div>
</template>

<script>
import gql from "graphql-tag";

const GET_BOOKS_QUERY = gql`
  query {
    books {
      id
      title
      year
    }
  }
`;

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
      this.hello = hello + " async";
    },
    async getBooksAsync() {
      const {
        data: { books },
      } = await this.$apollo.query({
        query: GET_BOOKS_QUERY,
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
              id
              title
              year
            }
          }
        `,
        variables: {
          year: Number(this.year),
          title: this.title,
        },
        update: (store, { data: { book } }) => {
          console.info("created", book.title, book.year);
          console.info("store", store);

          const data = store.readQuery({
            query: GET_BOOKS_QUERY,
          });

          console.info("data before", data);
          console.info("data after", { books: [...data.books, book] });

          store.writeQuery({
            query: GET_BOOKS_QUERY,
            data: { books: [...data.books, book] },
          });
        },
        error: (error) => console.error(error),
      });
      console.info("Book added", book);
      await this.getBooksAsync();
    },
    editBook(id, title, year) {
      this.editingBookId = id;
      this.edittitle = title;
      this.edityear = Number(year);
    },
    isEditingBook(id) {
      return this.editingBookId === id;
    },
    async saveBook() {
      console.info(
        `Saving book ${this.editingBookId}: ${this.edittitle} (${this.edityear})...`
      );
      const {
        data: { editBook },
      } = await this.$apollo.mutate({
        mutation: gql`
          mutation ($id: ID!, $title: String!, $year: Int!) {
            editBook(id: $id, title: $title, year: $year) {
              id
              title
              year
            }
          }
        `,
        variables: {
          id: this.editingBookId,
          title: this.edittitle,
          year: Number(this.edityear),
        },
        update: (store, { data: { editBook } }) => {
          console.info("edited", editBook);
          console.info("store", store);

          const data = store.readQuery({
            query: GET_BOOKS_QUERY,
          });

          console.info("data before", data);
          const books = data.books.map((x) =>
            x.id !== this.editingBookId
              ? x
              : { id: x.id, title: this.edittitle, year: this.edityear }
          );
          console.info("data after", { books: books });

          store.writeQuery({
            query: GET_BOOKS_QUERY,
            data: { books: books },
          });
        },
        error: (error) => console.error(error),
      });
      console.info("Book edited", editBook);
      await this.getBooksAsync();

      this.editingBookId = null;
      this.edittitle = null;
      this.edityear = null;
    },
    async deleteBook(id) {
      console.info(`Deleting book ${id}...`);
      const {
        data: { deleteBook },
      } = await this.$apollo.mutate({
        mutation: gql`
          mutation ($id: ID!) {
            deleteBook(id: $id)
          }
        `,
        variables: {
          id: id,
        },
        update: (store, { data: { deleteBook } }) => {
          console.info("deleted", deleteBook);
          console.info("store", store);

          const data = store.readQuery({
            query: GET_BOOKS_QUERY,
          });

          console.info("data before", data);
          const books = data.books.filter((x) => x.id !== deleteBook);
          console.info("data after", { books: books });

          store.writeQuery({
            query: GET_BOOKS_QUERY,
            data: { books: books },
          });
        },
        error: (error) => console.error(error),
      });
      console.info("Book deleted", deleteBook);
      await this.getBooksAsync();
    },
  },
  data() {
    return {
      hello: "",
      books: [],
      editingBookId: null,
      title: "",
      year: "",
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
