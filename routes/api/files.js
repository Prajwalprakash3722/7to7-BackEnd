const router = require("express").Router();
const { DB } = require("../../etc/mysqldb");
const { StatusError, manageError } = require("../../etc/StatusError");
const fsp = require("fs/promises");
const fs = require("fs");
const path = require("path");
const fileLocation = path.join(__dirname, "..", "..", "old", "LeadScore");
const multer = require('multer');
const {authTokenMiddleware,authTokenQueryMiddleware} = require("../../middleware/Auth");
const storage = multer.diskStorage({destination:fileLocation,
    filename:(req,file,cb)=>{
        let filename = file.originalname;
        while(fs.existsSync(path.join(fileLocation,filename))){
            const parsedLoc = path.parse(filename);
            parsedLoc.base=undefined;
            parsedLoc.name+='-another';
            filename=path.format(parsedLoc);
        }
        cb(null,filename);
    }
});
// const fileFilter = multer.file;
const upload = multer({storage});
router.get("/", authTokenMiddleware,async (req, res, next) => {
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
router.get("/models", authTokenMiddleware, async (req, res, next) => {
    try {
        const data = await fsp.readdir(fileLocation, { withFileTypes: true });
        res.json(
            data.filter(e => {
                const ext= path.extname(e.name).toLowerCase();
                // console.log(ext);
                return ext==='.rds';
            })
        );
    } catch (e) {
        manageError(next, e);
    }
});
router.get("/data", authTokenMiddleware,async (req, res, next) => {
    try {
        const data = await fsp.readdir(fileLocation, { withFileTypes: true });
        res.json(
            data.filter(e => {
                const ext= path.extname(e.name).toLowerCase();
                // console.log(ext);
                return ext==='.csv';
            })
        );
    } catch (e) {
        manageError(next, e);
    }
});


router.post('/',[authTokenQueryMiddleware,upload.single('misc')],async(req,res)=>{
    res.json({ok:true});
});


module.exports = router;
