import { createApp } from "vue";
import App from "./App.vue";
// import { ApolloClient } from "apollo-client";
// import { createHttpLink } from "apollo-link-http";
// import { InMemoryCache } from "apollo-cache-inmemory";
// import VueApollo from "vue-apollo";
// import Vue from "vue";
import { ApolloClient, InMemoryCache } from "@apollo/client/core";
import { createApolloProvider } from "@vue/apollo-option";

// HTTP connection to the API
// const httpLink = createHttpLink({
//   // You should use an absolute URL here
//   uri: "http://localhost:4000",
// });

// Cache implementation
const cache = new InMemoryCache();

// Create the apollo client
// const apolloClient = new ApolloClient({
//   link: httpLink,
//   cache,
// });

const apolloClient = new ApolloClient({
  cache,
  uri: "http://localhost:4000",
});

//Vue.use(VueApollo);

// const apolloProvider = new VueApollo({
//   defaultClient: apolloClient,
// });

const apolloProvider = createApolloProvider({
  defaultClient: apolloClient,
});

createApp(App).use(apolloProvider).mount("#app");
