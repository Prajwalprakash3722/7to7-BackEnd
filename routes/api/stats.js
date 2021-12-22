const router = require('express').Router();
const { DB } = require('../../etc/mysqldb');
const { StatusError, manageError } = require("../../etc/StatusError");

router.get('/monthQuery/:id',async(req,res,next)=>{
    try{
        const id = req.params.id;
        const db = await DB.db();
        
    }catch(e){
        manageError(next,e);
    }
})
router.get('/:id',async(req,res,next)=>{
    try{
        const id = req.params.id;
        const db = await DB.db();
        const [data] = await db.execute('select * from modelpreds where modelnum=?',[id]);
        res.json(data)
    }catch(e){
        manageError(next,e);
    }
});
module.exports = router;