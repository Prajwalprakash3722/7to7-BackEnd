const router = require("express").Router();
const { DB } = require("../../etc/mysqldb");
const { StatusError, manageError } = require("../../etc/StatusError");
const fsp = require("fs/promises");
const path = require("path");
const fileLocation = path.join(__dirname, "..", "..", "old", "LeadScore");

const upload = require('multer')({dest:fileLocation});
router.get("/", async (req, res, next) => {
    try {
        const data = await fsp.readdir(fileLocation, { withFileTypes: true });
        res.json(
            data.filter(e => {
                const ext= path.extname(e.name).toLowerCase();
                console.log(ext);return ext==='.csv'||ext==='.rds';
            })
        );
    } catch (e) {
        manageError(next, e);
    }
});
router.get("/models", async (req, res, next) => {
    try {
        const data = await fsp.readdir(fileLocation, { withFileTypes: true });
        res.json(
            data.filter(e => {
                const ext= path.extname(e.name).toLowerCase();
                console.log(ext);return ext==='.rds';
            })
        );
    } catch (e) {
        manageError(next, e);
    }
});
router.get("/data", async (req, res, next) => {
    try {
        const data = await fsp.readdir(fileLocation, { withFileTypes: true });
        res.json(
            data.filter(e => {
                const ext= path.extname(e.name).toLowerCase();
                console.log(ext);return ext==='.csv';
            })
        );
    } catch (e) {
        manageError(next, e);
    }
});


router.post('/',upload.single('misc'),async(req,res)=>{
    res.json({ok:true});
});


module.exports = router;
