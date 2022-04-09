const { gql } = require("apollo-server");

const typeDefs = gql`
  type Query {
    hello: String!
    name: String
    cats: [Cat!]!
    findCat(name: String!): Cat
  }
  type Cat {
    id: ID!
    name: String!
  }
  type Mutation {
    createCat(name: String!): Cat!
  }
`;

module.exports = typeDefs;
