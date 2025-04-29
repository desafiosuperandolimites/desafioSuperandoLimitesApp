const express = require('express');
const multer = require('multer');
const { uploadFileFotosPerfil, downloadFileFotosPerfil, uploadFileCapasEvento, downloadFileCapasEvento, uploadFileCapasNoticias, downloadFileCapasNoticias, uploadFileComprovantesKm, downloadFileComprovantesKm, uploadFileComprovantesPagamento, downloadFileComprovantesPagamento } = require('../controllers/fileController');

const router = express.Router();
const multerMiddleware = multer({ 
    storage: multer.memoryStorage(),
    limits: {
        fileSize: 5 * 1024 * 1024, // 5 MB
    }, 
});

router.post('/upload/fotosPerfil', multerMiddleware.single('file'), uploadFileFotosPerfil);
router.get('/download/fotosPerfil/:filename', downloadFileFotosPerfil);

router.post('/upload/capasEvento', multerMiddleware.single('file'), uploadFileCapasEvento);
router.get('/download/capasEvento/:filename', downloadFileCapasEvento);

router.post('/upload/capasNoticias', multerMiddleware.single('file'), uploadFileCapasNoticias);
router.get('/download/capasNoticias/:filename', downloadFileCapasNoticias);

router.post('/upload/comprovantesKm', multerMiddleware.single('file'), uploadFileComprovantesKm);
router.get('/download/comprovantesKm/:filename', downloadFileComprovantesKm);

router.post('/upload/comprovantesPagamento', multerMiddleware.single('file'), uploadFileComprovantesPagamento);
router.get('/download/comprovantesPagamento/:filename', downloadFileComprovantesPagamento);

module.exports = router;
