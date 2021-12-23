const { DB } = require("../etc/mysqldb");
const csv = require("csv");
const fsp = require("fs/promises");
const path = require("path");

const fileLocation = path.join(
    __dirname,
    "..",
    "old",
    "LeadScore",
    "Master_New.csv"
);

const { exec } = require("child_process");

const newfileLocation = fn =>
    path.join(__dirname, "..", "old", "LeadScore", fn);
const Models = {
    async updateFile() {
        const db = await DB.db();
        const [res] = await db.execute("select * from models");
        const updatedData = res;
        const data = await new Promise((res, rej) => {
            csv.stringify(
                updatedData,
                {
                    columns: [
                        { key: "id", header: "Modelid" },
                        { key: "model_desc", header: "Description" },
                        { key: "model_loc", header: "Model File" },
                        { key: "data_loc", header: "Input Data File" },
                        { key: "pred_loc", header: "Output Data File" },
                        { key: "createdAt", header: "Date" },
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
        const [res] = await db.execute("select * from models");
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
        const [res] = await db.execute("select * from models where id=?", [id]);

        return res[0] ?? null;
    },
    async getAllCSV() {
        const results = await this.getAll();
        return new Promise((res, rej) => {
            // console.log('inside',results)
            csv.stringify(results, (err, output) => {
                if (err) {
                    console.log("error");
                    rej(err);
                    return;
                }
                console.log("resolving");
                res(output);
            });
        });
    },
    /**
     *
     * @param {number} id
     */ async getDataCSV(id) {
        const results = await this.getOne(id);
        console.log("got", results);
        console.log("");
        const fp = path.join(
            __dirname,
            "..",
            "old",
            "LeadScore",
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
        console.log("got", results);
        if (results?.pred_loc) {
            console.log("");
            const fp = path.join(
                __dirname,
                "..",
                "old",
                "LeadScore",
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
                console.log("ready");
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
                console.log("ready");
                res(output);
            });
        });
    },
    async addOne(data) {
        const db = await DB.db();
        const [res] = await db.execute(
            "insert into models(model_desc,model_loc,data_loc,pred_loc) values(?,?,?,?)",
            [data.model_desc, data.model_loc, data.data_loc, null]
        );

        const id = res.insertId;

        // update the file
        await this.updateFile();

        // call the subprocess

        const returnval = await new Promise((res, rej) => {
            const proc = exec(
                `Rscript ./old/LeadScore/NandiToyota_LeadScore.R ${id}`
            );

            // for debug
            let data = "";
            proc.stdout.on("data", d => (data += d));

            proc.on("error", err => {
                rej(err);
            });
            proc.on("exit", err => {
                res(err);
            });
            proc.on("close", err => {
                res(err);
            });
        });

        const ppp = path.parse(data.data_loc);
        ppp.base = undefined;
        ppp.name = `${ppp.name} - scored`;
        const newFileName = path.format(ppp);

        const updateResults = await db.execute(
            "update models set pred_loc=? where id=?",
            [newFileName, id]
        );

        const debugdata = await this.getOne(id);

        return id;
    },
};

module.exports.Models = Models;
