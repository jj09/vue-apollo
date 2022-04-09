const Cat = require("./models/Cat");

const resolvers = {
  Query: {
    hello: () => "hello",
    name: () => "James",
    cats: async () => await Cat.find({}),
    findCat: async (_, { name }) => await Cat.findOne({ name: name }),
  },
  Mutation: {
    createCat: async (_, { name }) => {
      console.info("Creating cat named", name, "...");
      const kitty = new Cat({ name });
      await kitty.save();
      console.info("Cat created", kitty);
      return kitty;
    },
  },
};

module.exports = resolvers;
