const Usuario = require('../models/usuarioModel');
const PerfisTipoEnum = require('../enums/perfisTipoEnum');

const checkPermissions = async (req, res, next) => {
    // const currentUser = req.user; // Assuming currentUser is set in a previous middleware
    // const targetUserId = req.params.userId || req.body.userId; // Extract targetUserId from request parameters or body

    // console.log('Current User:', currentUser);
    // console.log('Target User ID:', targetUserId);

    // if (currentUser.ID_PERFIL_TIPO === 3) {
    //     if (currentUser.id !== parseInt(targetUserId)) {
    //         console.log('Permission denied: User can only edit their own profile.');
    //         return res.status(403).json({ error: 'Permissão negada. Você só pode editar seu próprio perfil.' });
    //     }
    //     // For PATCH methods like ativarDesativar, Normal users can't toggle their own status either
    //     if (req.method === 'PATCH') {
    //         console.log('Permission denied: Normal users cannot toggle their own status.');
    //         return res.status(403).json({ error: 'Permissão negada. Usuários Normais não podem ativar/desativar status.' });
    //     }
    //     console.log('Permission granted: Proceeding with the request.');
    //     return next(); // Allow Normal User to proceed if it's their own profile and not PATCHing status
    // }

    // // If the current user is an Administrative Assistant, restrict actions to only 'Usuário Normal'
    // if (currentUser.ID_PERFIL_TIPO === 2) {
    //     try {
    //         const targetUser = await Usuario.findByPk(targetUserId);
    //         if (!targetUser || targetUser.ID_PERFIL_TIPO !== PerfisTipoEnum.USU.key) { // Normal User
    //             return res.status(403).json({ error: 'Permissão negada. Assistente Administrativo só pode editar Usuários Normais.' });
    //         }
    //         next();
    //     } catch (error) {
    //         res.status(500).json({ error: error.message });
    //     }
    // } else {
        // Administrators have full access
        next();
    // }
};

module.exports = checkPermissions;