import { Router } from 'express';
import { getCrops, createCrop, updateCrop, updateCropStatus, deleteCrop } from '../controllers/cropController';
import { authenticateJWT, authorizeRoles } from '../middleware/auth';

const router = Router();

router.use(authenticateJWT);
router.get('/', getCrops);
router.post('/', authorizeRoles('FARMER', 'AGENT', 'ADMIN'), createCrop);
router.put('/:id', authorizeRoles('FARMER', 'AGENT', 'ADMIN'), updateCrop);
router.patch('/:id/status', authorizeRoles('FARMER', 'AGENT', 'ADMIN'), updateCropStatus);
router.delete('/:id', authorizeRoles('FARMER', 'AGENT', 'ADMIN'), deleteCrop);

export default router;
