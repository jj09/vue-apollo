import { createApp } from "vue";
import App from "./App.vue";
import { ApolloClient, InMemoryCache } from "@apollo/client/core";
import { createApolloProvider } from "@vue/apollo-option";

// Cache implementation
const cache = new InMemoryCache();

const apolloClient = new ApolloClient({
  cache,
  uri: "http://localhost:4000", // for prod change to '/api/'
});

const apolloProvider = createApolloProvider({
  defaultClient: apolloClient,
});

createApp(App).use(apolloProvider).mount("#app");
