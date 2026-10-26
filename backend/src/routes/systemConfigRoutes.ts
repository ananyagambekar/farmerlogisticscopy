import { Router } from 'express';
import { getSystemConfigs, updateSystemConfig } from '../controllers/systemConfigController';
import { authenticateJWT, authorizeRoles } from '../middleware/auth';

const router = Router();

router.use(authenticateJWT);
router.get('/', getSystemConfigs);
router.put('/:key', authorizeRoles('ADMIN'), updateSystemConfig);

export default router;
