const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');

// Form-based authentication
router.post('/login', authController.realizarLogin);

// Logout route
router.post('/logout', authController.realizarLogout);

router.put('/update-fcm-token', authController.updateFcmToken);

module.exports = router;
