const router = require('express').Router();
const { StatusError, manageError } = require('../../etc/StatusError');
const { authTokenMiddleware } = require('../../middleware/Auth');
const { Models } = require('../../services/models');
const redis = require('redis');
const defExp = 6400;
//? In Development Environment, we can leave the redis client configuration to the default, but when in prod env gotta change that.
const redisClient = redis.createClient();

router.get('/', authTokenMiddleware, async (req, res, next) => {
    try {
        const models = await Models.getAll();
        res.json(models);
    } catch (e) {
        manageError(next, e);
    }
});

router.get('/csv', authTokenMiddleware, async (req, res, next) => {
    try {
        const models = await Models.getAllCSV();
        res.send(models);
    } catch (e) {
        manageError(next, e);
    }
});

router.delete('/:id', authTokenMiddleware, async (req, res, next) => {
    try {
        const id = req.params.id;
        const resp = await Models.deleteOne(id);
        res.json(resp);
    } catch (e) {
        manageError(next, e);
    }
});

router.get('/preds/:id/csv', authTokenMiddleware, async (req, res, next) => {
    try {
        const id = req.params.id;
        const models = await Models.getPredsCSV(id);
        res.send(models);
    } catch (e) {
        manageError(next, e);
    }
});

// * DONE Redis Cache for this endpoint
router.get('/preds/:id', authTokenMiddleware, async (req, res, next) => {
    redisClient.get(`preds${req.params.id}`, async (err, data) => {
        if (data != null) {
            console.log('Redis Cache Hit');
            return res.json(JSON.parse(data));
        } else {
            try {
                const id = req.params.id;
                const models = await Models.getPreds(id);
                redisClient.setex(`preds${id}`, defExp, JSON.stringify(models));
                res.send(models);
                console.log('Redis Cache Miss ');
            } catch (e) {
                manageError(next, e);
            }
        }
    });
});

// confusion matrix
router.get('/conf/:id', authTokenMiddleware, async (req, res, next) => {
    redisClient.get(`conf${req.params.id}`, async (err, data) => {
        if (data != null) {
            console.log('Redis Cache Hit');
            return res.json(JSON.parse(data));
        } else {
            try {
                const id = req.params.id;
                const models = await Models.getConfusion(id);
                redisClient.setex(`conf${id}`, defExp, JSON.stringify(models));
                res.send(models);
                console.log('Redis Cache Miss ');
            } catch (e) {
                manageError(next, e);
            }
        }
    });
});
// confusion matrix
router.get('/conf/:id/csv', authTokenMiddleware, async (req, res, next) => {
    try {
        const id = req.params.id;
        const models = await Models.getConfusionCSV(id);
        res.send(models);
    } catch (e) {
        manageError(next, e);
    }
});
// * DONE Redis Cache for this endpoint
router.get('/:id', authTokenMiddleware, async (req, res, next) => {
    redisClient.get(`model${req.params.id}`, async (err, data) => {
        if (data != null) {
            console.log('Redis Cache Hit');
            return res.json(JSON.parse(data));
        } else {
            try {
                const id = req.params.id;
                const models = await Models.getData(id);
                redisClient.setex(`model${id}`, defExp, JSON.stringify(models));
                res.send(models);
                console.log('Redis Cache Miss ');
            } catch (e) {
                manageError(next, e);
            }
        }
    });
});

router.post('/', authTokenMiddleware, async (req, res, next) => {
    try {
        // const { } = req.body;
        if (
            (typeof req.body.model_desc !== 'string' &&
                typeof req.body.model_loc !== 'string',
            typeof req.body.data_loc !== 'string')
        )
            throw new StatusError('Incorrect data', 400);
        const resp = await Models.addOne(req.body);
        res.json(resp);
    } catch (e) {
        manageError(next, e);
    }
});
router.get('/:id/csv', authTokenMiddleware, async (req, res, next) => {
    try {
        const id = req.params.id;
        const models = await Models.getDataCSV(id);
        res.send(models);
    } catch (e) {
        manageError(next, e);
    }
});

// refresh an entry matrix
router.get('/revalidate/:id', authTokenMiddleware, async (req, res, next) => {
    try {
        const id = req.params.id;
        const modelnum = await Models.revalidate(id);
        res.send(modelnum);
    } catch (e) {
        manageError(next, e);
    }
});
module.exports = router;
