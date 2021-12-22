const { DB } = require("../etc/mysqldb");
const csv = require("csv");
const Models = {
    async getAll() {
        const db = await DB.db();
        const [res] = await db.execute("select * from models");
        return res;
    },
    /**
     *
     * @param {number} id
     */
    async getOne(id) {
        const db = await DB.db();
        const [res] = await db.execute("select * from models where id=?", [id]);
        return res;
    },
    async getCSV() {
        const results = await this.getAll();
        return new Promise((res, rej) => {
            console.log('inside',results)
            csv.stringify(results, (err, output) => {
                if (err) {
                    console.log('error')
                    rej(err);
                    return;
                }
                console.log('resolving');
                res(output);
            });
        });
    },
};

module.exports.Models = Models;
