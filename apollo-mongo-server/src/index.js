const { ApolloServer } = require("apollo-server");
// import { ApolloServer, gql } from "apollo-server-express";
// import express from "express";
const mongoose = require("mongoose");
const resolvers = require("./resolvers");
const typeDefs = require("./models/typeDefs");

// const app = express();
const startServer = async () => {
  await mongoose.connect("mongodb://localhost:27017/test3", {
    useNewUrlParser: true,
  });

  const server = new ApolloServer({
    typeDefs,
    resolvers,
  });

  server.listen().then(({ url }) => {
    console.log(`🚀  Server ready at ${url}`);
  });
};

startServer();
