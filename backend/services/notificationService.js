// services/notificationService.js

const admin = require('../firebase');
const Usuario = require('../models/usuarioModel');
const Notificacao = require('../models/notificacoesModel');
const { Op } = require('sequelize');

exports.sendNotificationToAllUsers = async (title, body) => {
  try {
    // Fetch all users with an FCM token
    const users = await Usuario.findAll({
      where: {
        FCM_TOKEN: { [Op.ne]: null }, // Users with non-null FCM tokens
        SITUACAO: true // Optional: Only active users
      },
      attributes: ['ID', 'FCM_TOKEN']
    });

    for (const user of users) {
      const token = user.FCM_TOKEN;
      const message = {
        token: token,
        notification: {
          title: title,
          body: body,
        },
      };

      console.log(`Sending message to token ${token}..., user ID: ${user.ID}`);

      try {
        const response = await admin.messaging().send(message);
        console.log(`Message sent successfully to token ${token}:`, response);

        // Insert a record into NOTIFICACOES table
        await Notificacao.create({
          ID_USUARIO: user.ID,
          TITLE: title,
          BODY: body,
          LIDA: false
        });

      } catch (error) {
        console.error(`Error sending message to token ${token}:`, error);
        if (error.code === 'messaging/invalid-registration-token' || error.code === 'messaging/registration-token-not-registered') {
          // Remove the invalid token from the database
          user.FCM_TOKEN = null;
          await user.save();
          console.log(`Removed invalid FCM token for user ID ${user.ID}`);
        }
      }
    }
  } catch (error) {
    console.error('Error sending notifications:', error);
  }
};

exports.sendNotificationToUser = async (userId, title, body) => {
  try {
    // Fetch the user's FCM token
    const user = await Usuario.findByPk(userId);

    if (!user || !user.FCM_TOKEN) {
      console.log(`User with ID ${userId} does not have a valid FCM token.`);
      return;
    }

    const token = user.FCM_TOKEN;

    const message = {
      token: token,
      notification: {
        title: title,
        body: body,
      },
    };

    try {
      const response = await admin.messaging().send(message);
      console.log(`Message sent successfully to user ID ${userId}:`, response);

      // Insert notification record into NOTIFICACOES table
      await Notificacao.create({
        ID_USUARIO: userId,
        TITLE: title,
        BODY: body,
        LIDA: false
      });

    } catch (error) {
      console.error(`Error sending message to user ID ${userId}:`, error);
      if (error.code === 'messaging/invalid-registration-token' || error.code === 'messaging/registration-token-not-registered') {
        // Remove the invalid token from the database
        user.FCM_TOKEN = null;
        await user.save();
        console.log(`Removed invalid FCM token for user ID ${userId}`);
      }
    }
  } catch (error) {
    console.error(`Error fetching user with ID ${userId}:`, error);
  }
};
