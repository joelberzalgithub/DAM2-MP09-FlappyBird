const express = require('express');
const app = express();

app.use(express.json());
app.set('json spaces', 2)

module.exports = app;