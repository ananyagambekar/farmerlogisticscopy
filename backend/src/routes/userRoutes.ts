import { Router } from 'express';
import { getAllUsers, getUserById, updateUserStatus } from '../controllers/userController';
import { authenticateJWT, authorizeRoles } from '../middleware/auth';

const router = Router();

router.use(authenticateJWT);
router.get('/', authorizeRoles('ADMIN'), getAllUsers);
router.get('/:id', authorizeRoles('ADMIN'), getUserById);
router.patch('/:id/status', authorizeRoles('ADMIN'), updateUserStatus);

export default router;
