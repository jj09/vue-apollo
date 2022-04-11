const mongoose = require("mongoose");

const Book = mongoose.model("Book", { title: String, year: Number });

module.exports = Book;
