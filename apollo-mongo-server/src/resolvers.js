const Book = require("./models/Book");

const resolvers = {
  Query: {
    hello: () => "hello",
    name: () => "Jacob J",
    books: async () => await Book.find({}),
    findBook: async (_, { title }) => await Book.findOne({ title: title }),
  },
  Mutation: {
    createBook: async (_, { title, year }) => {
      console.info(`Creating book ${title} (${year})...`);
      const book = new Book({ title, year });
      await book.save();
      console.info("Book created", book);
      return book;
    },
    deleteBook: async (_, { id }) => {
      const book = await Book.findOne({ _id: id });
      console.info(`Deleting book ${book.title} (${book.year})...`);
      const result = await Book.deleteOne({
        _id: id,
      });
      console.info("Book deleted", result);
      if (result.acknowledged && result.deletedCount === 1) {
        return id;
      }

      return null;
    },
  },
};

module.exports = resolvers;
