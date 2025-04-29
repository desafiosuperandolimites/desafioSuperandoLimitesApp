const express = require('express');
const router = express.Router();
const googleAuthController = require('../controllers/googleAuthController');

router.post('/auth/google', googleAuthController.googleSignIn);

module.exports = router;
