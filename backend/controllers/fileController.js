const bucket = require('../storage');

exports.uploadFileFotosPerfil = async (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).send('No file uploaded.');
        }

        const folderName = 'fotosPerfil';
        const fileName = `${folderName}/${req.file.originalname}`;
        console.log(`Saving file to: ${fileName}`);

        const blob = bucket.file(fileName);
        const blobStream = blob.createWriteStream({ resumable: false });

        blobStream.on('error', (err) => {
            console.error('Blob stream error:', err.message);
            res.status(500).send({ message: err.message });
        });

        blobStream.on('finish', () => {
            const publicUrl = `http://storage.googleapis.com/${bucket.name}/${blob.name}`;
            console.log('Upload successful:', publicUrl);
            res.status(200).send({ url: publicUrl });
        });

        blobStream.end(req.file.buffer);
    } catch (err) {
        if (err instanceof multer.MulterError && err.code === 'LIMIT_FILE_SIZE') {
            return res.status(413).send({ message: 'Tamanho do arquivo está acima do limite de 5MB' });
        }
        console.error('Server error:', err.message);
        res.status(500).send({ message: err.message });
    }
};

exports.downloadFileFotosPerfil = async (req, res) => {
    try {
        const folderName = 'fotosPerfil';
        const fileName = `${folderName}/${req.params.filename}`;
        console.log(`Downloading file: ${fileName}`);

        const file = bucket.file(fileName);
        const exists = await file.exists();
        if (!exists[0]) {
            return res.status(404).send('File not found.');
        }

        file.createReadStream().pipe(res);
    } catch (err) {
        console.error('Server error:', err.message);
        res.status(500).send({ message: err.message });
    }
};

exports.uploadFileCapasEvento = async (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).send('No file uploaded.');
        }

        const folderName = 'capasEvento';
        const fileName = `${folderName}/${req.file.originalname}`;
        console.log(`Saving file to: ${fileName}`);

        const blob = bucket.file(fileName);
        const blobStream = blob.createWriteStream({ resumable: false });

        blobStream.on('error', (err) => {
            console.error('Blob stream error:', err.message);
            res.status(500).send({ message: err.message });
        });

        blobStream.on('finish', () => {
            const publicUrl = `http://storage.googleapis.com/${bucket.name}/${blob.name}`;
            console.log('Upload successful:', publicUrl);
            res.status(200).send({ url: publicUrl });
        });

        blobStream.end(req.file.buffer);
    } catch (err) {
        if (err instanceof multer.MulterError && err.code === 'LIMIT_FILE_SIZE') {
            return res.status(413).send({ message: 'Tamanho do arquivo está acima do limite de 5MB' });
        }
        console.error('Server error:', err.message);
        res.status(500).send({ message: err.message });
    }
};

exports.downloadFileCapasEvento = async (req, res) => {
    try {
        const folderName = 'capasEvento';
        const fileName = `${folderName}/${req.params.filename}`;
        console.log(`Downloading file: ${fileName}`);

        const file = bucket.file(fileName);
        const exists = await file.exists();
        if (!exists[0]) {
            return res.status(404).send('File not found.');
        }

        file.createReadStream().pipe(res);
    } catch (err) {
        console.error('Server error:', err.message);
        res.status(500).send({ message: err.message });
    }
};

exports.uploadFileCapasNoticias = async (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).send('No file uploaded.');
        }

        const folderName = 'capasNoticias';
        const fileName = `${folderName}/${req.file.originalname}`;
        console.log(`Saving file to: ${fileName}`);

        const blob = bucket.file(fileName);
        const blobStream = blob.createWriteStream({ resumable: false });

        blobStream.on('error', (err) => {
            console.error('Blob stream error:', err.message);
            res.status(500).send({ message: err.message });
        });

        blobStream.on('finish', () => {
            const publicUrl = `http://storage.googleapis.com/${bucket.name}/${blob.name}`;
            console.log('Upload successful:', publicUrl);
            res.status(200).send({ url: publicUrl });
        });

        blobStream.end(req.file.buffer);
    } catch (err) {
        if (err instanceof multer.MulterError && err.code === 'LIMIT_FILE_SIZE') {
            return res.status(413).send({ message: 'Tamanho do arquivo está acima do limite de 5MB' });
        }
        console.error('Server error:', err.message);
        res.status(500).send({ message: err.message });
    }
};

exports.downloadFileCapasNoticias = async (req, res) => {
    try {
        const folderName = 'capasNoticias';
        const fileName = `${folderName}/${req.params.filename}`;
        console.log(`Downloading file: ${fileName}`);

        const file = bucket.file(fileName);
        const exists = await file.exists();
        if (!exists[0]) {
            return res.status(404).send('File not found.');
        }

        file.createReadStream().pipe(res);
    } catch (err) {
        console.error('Server error:', err.message);
        res.status(500).send({ message: err.message });
    }
};

exports.uploadFileComprovantesKm = async (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).send('No file uploaded.');
        }

        const folderName = 'comprovantesKm';
        const fileName = `${folderName}/${req.file.originalname}`;
        console.log(`Saving file to: ${fileName}`);

        const blob = bucket.file(fileName);
        const blobStream = blob.createWriteStream({ resumable: false });

        blobStream.on('error', (err) => {
            console.error('Blob stream error:', err.message);
            res.status(500).send({ message: err.message });
        });

        blobStream.on('finish', () => {
            const publicUrl = `http://storage.googleapis.com/${bucket.name}/${blob.name}`;
            console.log('Upload successful:', publicUrl);
            res.status(200).send({ url: publicUrl });
        });

        blobStream.end(req.file.buffer);
    } catch (err) {
        if (err instanceof multer.MulterError && err.code === 'LIMIT_FILE_SIZE') {
            return res.status(413).send({ message: 'Tamanho do arquivo está acima do limite de 5MB' });
        }
        console.error('Server error:', err.message);
        res.status(500).send({ message: err.message });
    }
};

exports.downloadFileComprovantesKm = async (req, res) => {
    try {
        const folderName = 'comprovantesKm';
        const fileName = `${folderName}/${req.params.filename}`;
        console.log(`Downloading file: ${fileName}`);

        const file = bucket.file(fileName);
        const exists = await file.exists();
        if (!exists[0]) {
            return res.status(404).send('File not found.');
        }

        file.createReadStream().pipe(res);
    } catch (err) {
        console.error('Server error:', err.message);
        res.status(500).send({ message: err.message });
    }
};

exports.uploadFileComprovantesPagamento = async (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).send('No file uploaded.');
        }

        const folderName = 'comprovantesPagamento';
        const fileName = `${folderName}/${req.file.originalname}`;
        console.log(`Saving file to: ${fileName}`);

        const blob = bucket.file(fileName);
        const blobStream = blob.createWriteStream({ resumable: false });

        blobStream.on('error', (err) => {
            console.error('Blob stream error:', err.message);
            res.status(500).send({ message: err.message });
        });

        blobStream.on('finish', () => {
            const publicUrl = `http://storage.googleapis.com/${bucket.name}/${blob.name}`;
            console.log('Upload successful:', publicUrl);
            res.status(200).send({ url: publicUrl });
        });

        blobStream.end(req.file.buffer);
    } catch (err) {
        if (err instanceof multer.MulterError && err.code === 'LIMIT_FILE_SIZE') {
            return res.status(413).send({ message: 'Tamanho do arquivo está acima do limite de 5MB' });
        }
        console.error('Server error:', err.message);
        res.status(500).send({ message: err.message });
    }
};

exports.downloadFileComprovantesPagamento = async (req, res) => {
    try {
        const folderName = 'comprovantesPagamento';
        const fileName = `${folderName}/${req.params.filename}`;
        console.log(`Downloading file: ${fileName}`);

        const file = bucket.file(fileName);
        const exists = await file.exists();
        if (!exists[0]) {
            return res.status(404).send('File not found.');
        }

        file.createReadStream().pipe(res);
    } catch (err) {
        console.error('Server error:', err.message);
        res.status(500).send({ message: err.message });
    }
};
