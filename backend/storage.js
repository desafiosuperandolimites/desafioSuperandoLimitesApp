const { Storage } = require('@google-cloud/storage');
const path = require('path');

const storage = new Storage({
    keyFilename: path.join(__dirname, 'gcp-data-access.json'),
    projectId: 'fit-heaven-443517-j5',
});

const bucket = storage.bucket('superando_limites');

module.exports = bucket;