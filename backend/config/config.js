require('dotenv').config();

module.exports = {
  development: {
    username: process.env.DB_USER || "postgres",
    password: process.env.DB_PASSWORD || "admin",
    database: process.env.DB_NAME || "superando_limites",
    host: process.env.DB_HOST || "postgres",
    port: process.env.DB_PORT || 5432,
    dialect: "postgres"
  },
  production: {
    username: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    host: process.env.DB_HOST,
    dialect: "postgres",
    dialectOptions: {
      socketPath: process.env.DB_HOST
    }
  }
};
// require('dotenv').config();
// const fs = require('fs');

// // Substituir placeholders no JSON
// const gcpConfig = {
//   type: "service_account",
//   project_id: process.env.GCLOUD_PROJECT_ID,
//   private_key_id: process.env.GCLOUD_PRIVATE_KEY_ID,
//   private_key: process.env.GCLOUD_PRIVATE_KEY.replace(/\\n/g, '\n'),
//   client_email: process.env.GCLOUD_CLIENT_EMAIL,
//   client_id: process.env.GCLOUD_CLIENT_ID,
//   auth_uri: process.env.GCLOUD_AUTH_URI,
//   token_uri: process.env.GCLOUD_TOKEN_URI,
//   auth_provider_x509_cert_url: process.env.GCLOUD_AUTH_PROVIDER_CERT_URL,
//   client_x509_cert_url: process.env.GCLOUD_CLIENT_CERT_URL,
//   universe_domain: process.env.GCLOUD_UNIVERSE_DOMAIN,
// };

// // Salvar o arquivo JSON dinamicamente, se necessário
// fs.writeFileSync('gcp-data-access.json', JSON.stringify(gcpConfig, null, 2));
