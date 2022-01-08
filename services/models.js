const { DB } = require('../etc/mysqldb');
const csv = require('csv');
const fsp = require('fs/promises');
const path = require('path');
const { exec } = require('child_process');

const fileLocation = path.join(
    __dirname,
    '..',
    'old',
    'LeadScore',
    'Master_New.csv'
);

/**
 * new File Location
 * @param {string} fn
 * @returns {string}
 */
const newfileLocation = fn =>
    path.join(__dirname, '..', 'old', 'LeadScore', fn);
const Models = {
    async updateFile() {
        const db = await DB.db();
        const [res] = await db.execute('select * from models');
        const updatedData = res;
        const data = await new Promise((res, rej) => {
            csv.stringify(
                updatedData,
                {
                    columns: [
                        { key: 'id', header: 'Modelid' },
                        { key: 'model_desc', header: 'Description' },
                        { key: 'model_loc', header: 'Model File' },
                        { key: 'data_loc', header: 'Input Data File' },
                        { key: 'pred_loc', header: 'Output Data File' },
                        { key: 'createdAt', header: 'Date' },
                    ],
                    header: true,
                },
                (err, output) => {
                    if (err) {
                        rej(err);
                        return;
                    }
                    res(output);
                }
            );
        });
        await fsp.writeFile(fileLocation, data);
    },
    /**
     *
     * @returns {Promise<Array>}
     */
    async getAll() {
        const db = await DB.db();
        const [res] = await db.execute('select * from models');
        const updatedData = res;
        await this.updateFile();
        return res;
    },
    /**
     *
     * @param {number} id
     */
    async getOne(id) {
        // const res = (await this.getAll()).filter(e => e["Modelid"] == id);
        const db = await DB.db();
        const [res] = await db.execute('select * from models where id=?', [
            id ?? null,
        ]);

        return res[0] ?? null;
    },
    async getAllCSV() {
        const results = await this.getAll();
        return new Promise((res, rej) => {
            // console.log('inside',results)
            csv.stringify(results, (err, output) => {
                if (err) {
                    console.log('error');
                    rej(err);
                    return;
                }
                console.log('resolving');
                res(output);
            });
        });
    },
    /**
     *
     * @param {number} id
     */ async getDataCSV(id) {
        const results = await this.getOne(id);
        console.log('got', results);
        console.log('');
        const fp = path.join(
            __dirname,
            '..',
            'old',
            'LeadScore',
            results.data_loc
        );
        const data = await fsp.readFile(fp);

        return data;
        // TODO call R script and pull out the new preds here and update the db to store it
    },
    /**
     *
     * @param {number} id
     */
    async getPredsCSV(id) {
        const results = await this.getOne(id);
        console.log('got', results);
        if (results?.pred_loc) {
            console.log('');
            const fp = path.join(
                __dirname,
                '..',
                'old',
                'LeadScore',
                results.pred_loc
            );
            const data = await fsp.readFile(fp);

            return data;
        }
        // TODO call R script and pull out the new preds here and update the db to store it
        return null;
    },
    /**
     * Get CSV and make
     * @param {number} id
     */
    async getPreds(id) {
        const results = await this.getPredsCSV(id);
        if (!results) return null;
        return new Promise((res, rej) => {
            csv.parse(results, { columns: true }, (err, output) => {
                if (err) {
                    rej(err);
                    return;
                }
                console.log('ready');
                res(output);
            });
        });
    },
    /**
     * Get CSV and make
     * @param {number} id
     */
    async getData(id) {
        const results = await this.getDataCSV(id);
        if (!results) return null;
        return new Promise((res, rej) => {
            csv.parse(results, { columns: true }, (err, output) => {
                if (err) {
                    rej(err);
                    return;
                }
                console.log('ready');
                res(output);
            });
        });
    },
    /**
     *
     * @param {number} id
     * @returns
     */
    async getConfusion(id) {
        return this.getConfusionCSV(id).then(
            results =>
                new Promise((res, rej) => {
                    csv.parse(
                        results,
                        { columns: false, from: 2 },
                        (err, output) => {
                            if (err) {
                                rej(err);
                                return;
                            }
                            res(output.map(e => [parseInt(e[1]??0)||0, parseInt(e[2]??0)||0 ]));
                        }
                    );
                })
        );
    },
    async getConfusionCSV(id) {
        const results = await this.getOne(id);
        if (results?.conf_loc) {
            /** @type {string} */
            const conf_loc = results.conf_loc;
            const fp = newfileLocation(conf_loc);
            return fsp.readFile(fp);
        }
        return null;
    },
    async addOne(data) {
        const db = await DB.db();
        const [res] = await db.execute(
            'insert into models(model_desc,model_loc,data_loc,pred_loc) values(?,?,?,?)',
            [data.model_desc, data.model_loc, data.data_loc, null]
        );

        const id = res.insertId;

        // const debugdata = await this.getOne(id);
        await this.revalidate(id, data.data_loc);

        return id;
    },
    /**
     * revalidate an entry
     * @param {number} id
     * @param {string} data_loc will fetch if not given
     * @returns
     */
    async revalidate(id, data_loc = undefined) {
        // get db and update file parallely
        const [db] = await Promise.all([DB.db(), this.updateFile()]);
        // await this.updateFile();
        if (!data_loc) {
            console.log('recalcing data loc for id',id)
            data_loc = (await this.getOne(id)).data_loc;
        }
        /** @type {number} return value of process */
        const returnval = await new Promise((res, rej) => {
            const proc = exec(
                `Rscript ./old/LeadScore/NandiToyota_LeadScore.R ${id}`
            );

            // for debug
            let data = '';
            let errordata = '';
            proc.stdout.on('data', d => (data += d));

            proc.stderr.on('data', d => (errordata += d));
            proc.on('error', err => {
                rej(err);
            });
            proc.on('exit', err => {
                res(err);
            });
            proc.on('close', err => {
                res(err);
            });
        });

        const ppp = path.parse(data_loc);
        const originalName = ppp.name;
        ppp.base = undefined;
        ppp.name = `${originalName} - scored`;
        const newPredName = path.format(ppp);
        ppp.name = `${originalName} - confusion`;
        const newConfusionName = path.format(ppp);

        const updateResults = await db.execute(
            'update models set pred_loc=?,conf_loc=? where id=?',
            [newPredName, newConfusionName, id]
        );
        return returnval;
    },
    /**
     *
     * @param {number} id
     */
    async deleteOne(id) {
        const db = await DB.db();
        const [res] = await db.execute('delete from models where id=?', [id]);
        return res.affectedRows;
    },
};

module.exports.Models = Models;
