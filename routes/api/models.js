const router = require("express").Router();
const { StatusError, manageError } = require("../../etc/StatusError");
const {Models} = require('../../services/models')

router.get("/", async (req, res, next) => {
    try {
        const models = await Models.getAll();
        res.json(models);
    } catch (e) {
        manageError(next, e);
    }
});

router.get("/csv", async (req, res, next) => {
    try {
        const models = await Models.getCSV();
        res.send(models);
    } catch (e) {
        manageError(next, e);
    }
});

module.exports = router;
