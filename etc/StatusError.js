//@ts-check
const createHttpError = require("http-errors");

class StatusError extends Error {
    /**
     *
     * @param {string} [msg] Error message
     * @param {number} [status] status number to provide (500)
     */
    constructor(msg, status = 500) {
        super(msg);
        /**@type {number} */
        this.status = status;
    }
}
exports.StatusError = StatusError;

/**
 * Manage Error and send to error manager
 * @param {import('express').NextFunction} next
 * @param {*} e Error
 */
exports.manageError = function manageError(next, e) {
    if (e instanceof StatusError) {
        next(createHttpError(e.status, e));
    } else {
        next(createHttpError(400, e));
    }
};
