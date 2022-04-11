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
  },
};

module.exports = resolvers;
