const router = require("express").Router();
const { StatusError, manageError } = require("../../etc/StatusError");
const {authTokenMiddleware} = require("../../middleware/Auth");
const { Models } = require("../../services/models");

router.get("/",authTokenMiddleware, async (req, res, next) => {
    try {
        const models = await Models.getAll();
        res.json(models);
    } catch (e) {
        manageError(next, e);
    }
});

router.get("/csv",authTokenMiddleware, async (req, res, next) => {
    try {
        const models = await Models.getAllCSV();
        res.send(models);
    } catch (e) {
        manageError(next, e);
    }
});

router.delete("/:id",authTokenMiddleware, async (req, res, next) => {
    try {
        const id = req.params.id;
        const resp = await Models.deleteOne(id);
        res.json(resp);
    } catch (e) {
        manageError(next, e);
    }
});

router.get("/preds/:id/csv",authTokenMiddleware, async (req, res, next) => {
    try {
        const id = req.params.id;
        const models = await Models.getPredsCSV(id);
        res.send(models);
    } catch (e) {
        manageError(next, e);
    }
});
router.get("/preds/:id",authTokenMiddleware, async (req, res, next) => {
    try {
        const id = req.params.id;
        const models = await Models.getPreds(id);
        res.send(models);
    } catch (e) {
        manageError(next, e);
    }
});

router.get("/:id",authTokenMiddleware, async (req, res, next) => {
    try {
        const id = req.params.id;
        const models = await Models.getData(id);
        res.send(models);
    } catch (e) {
        manageError(next, e);
    }
});

router.post("/",authTokenMiddleware, async (req, res, next) => {
    try {
        // const { } = req.body;
        if (
            (typeof req.body.model_desc !== "string" &&
                typeof req.body.model_loc !== "string",
            typeof req.body.data_loc !== "string")
        )
            throw new StatusError("Incorrect data", 400);
        const resp = await Models.addOne(req.body);
        res.json(resp);
    } catch (e) {
        manageError(next, e);
    }
});
router.get("/:id/csv",authTokenMiddleware, async (req, res, next) => {
    try {
        const id = req.params.id;
        const models = await Models.getDataCSV(id);
        res.send(models);
    } catch (e) {
        manageError(next, e);
    }
});
module.exports = router;
