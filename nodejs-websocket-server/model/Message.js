// This file creates the schema for MongoDB

const mongoose = require("mongoose");

// message schema contains group name, user, the msg, and current time
const messageSchema = new mongoose.Schema({
  name: {
    type: String
  },
  username: {
    type: String
    },
  text: {
    type: String
  },
  time: {
    type: String
  },
  
  },
    {
      timestamps: true
});

// export to index.js
module.exports = mongoose.model("Message", messageSchema);