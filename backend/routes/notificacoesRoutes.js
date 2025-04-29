const express = require('express');
const router = express.Router();
const notificacoesController = require('../controllers/notificacoesController');

// Mark a notification as read
router.put('/notificacoes/:id/lida', notificacoesController.markAsRead);

// Get all notifications for a user
router.get('/notificacoes', notificacoesController.getNotificationsForUser);

module.exports = router;
