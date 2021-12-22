const express = require("express");
const dotenv = require("dotenv").config();

const router = express.Router();
router.use("/api", require("./api"));
//Some test endpoints

router.get("/test", (_req, res) => {
  res.json({
    ok: true,
  });
});

module.exports = router;
