//@ts-check
const mysql = require("mysql2");
/**@typedef {{createdAt:string,createdBy:number,modifiedAt:string,modifiedBy:number}} AuditFields*/
exports.DB = class DB {
    /**
     * Singleton DB conn
     * @type {import('mysql2/promise').Pool|null} */
    static #dbconn = null;
    static async db() {
        if (DB.#dbconn === null) {
            const dbcon = mysql
                .createPool({
                    user: process.env.MYSQL_USER ?? "seven4seven",
                    password: process.env.MYSQL_PASSWORD ?? "no",
                    database: process.env.DBNAME ?? "seven4seven",
                    host: process.env.DBHOST ?? "localhost",
                })
                .promise();
            DB.#dbconn = dbcon;
        }
        return DB.#dbconn;
    }
};
