const express = require("express");
const bodyParser = require("body-parser");
const mongoose = require("mongoose");
require("dotenv").config();
const cors = require("cors");

const app = express();
const routes = require("./routes/index");
app.use(bodyParser.json());
app.use(cors());
app.use(require("morgan")("dev"));
const port = process.env.PORT || 3001;
app.use(routes);

const startServer = async () => {
    const mdbURL = process.env.MONGO_URI || "mongodb://localhost:27017/7to7";
    await mongoose.connect(
        mdbURL,
        {
            useNewUrlParser: true,
            useUnifiedTopology: true,
        },
        () => {
            console.log("Connected to MongoDB", ` on ${mdbURL}`);
            app.listen(port, () => {
                console.log(`Listening on port http://localhost:${port}`);
            });
        }
    );
};

startServer();
