// This file creates the schema for MongoDB

const mongoose = require("mongoose");

// schema contains username and password, as well as some requirements
const userSchema = new mongoose.Schema({
  username: {
    type: String,
    //required: true,
    unique: true,
    trim: true,
    minlength: 1
  },
  
},  {
  timestamps: true,
});

// export the schema to passport and then to index.js
const User = mongoose.model('User', userSchema);
module.exports = User;