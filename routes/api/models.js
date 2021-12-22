const router = require("express").Router();
const { StatusError, manageError } = require("../../etc/StatusError");
const { Models } = require("../../services/models");

// TODO add auth
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
        const models = await Models.getAllCSV();
        res.send(models);
    } catch (e) {
        manageError(next, e);
    }
});

router.get("/preds/:id/csv", async (req, res, next) => {
    try {
        const id = req.params.id;
        const models = await Models.getPredsCSV(id);
        res.send(models);
    } catch (e) {
        manageError(next, e);
    }
});
router.get("/preds/:id", async (req, res, next) => {
    try {
        const id = req.params.id;
        const models = await Models.getPreds(id);
        res.send(models);
    } catch (e) {
        manageError(next, e);
    }
});

router.get("/:id", async (req, res, next) => {
    try {
        const id = req.params.id;
        const models = await Models.getData(id);
        res.send(models);
    } catch (e) {
        manageError(next, e);
    }
});

router.post("/", async (req, res, next) => {
    try {
        // const { } = req.body;
        const resp = await Models.addOne(req.body);
        res.json(resp)
    } catch (e) {
        manageError(next,e);
    }
});
router.get("/:id/csv", async (req, res, next) => {
    try {
        const id = req.params.id;
        const models = await Models.getDataCSV(id);
        res.send(models);
    } catch (e) {
        manageError(next, e);
    }
});
module.exports = router;
