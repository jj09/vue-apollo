const { gql } = require("apollo-server");

const typeDefs = gql`
  type Query {
    hello: String!
    name: String
    books: [Book!]!
    findBook(title: String!): Book
  }
  type Book {
    id: ID!
    title: String!
    year: Int!
  }
  type Mutation {
    createBook(title: String!, year: Int!): Book!
    deleteBook(id: ID!): Boolean!
  }
`;

module.exports = typeDefs;
