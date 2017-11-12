const express = require('express');
const app = express();
const fs = require("fs");

app.use(express.static("./public"));

app.get('/', function (req, res) {
    res.sendFile("./public/index.html");
});

app.get('/api/list', function (req, res) {
    var files = fs.readdirSync("./public/photos");
    res.send(files);
});

app.listen(3000, function () {
    console.log('Example app listening on port 3000!');
});

