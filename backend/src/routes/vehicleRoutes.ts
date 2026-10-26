import { Router } from 'express';
import { getVehicles, registerVehicle, updateVehicleStatus } from '../controllers/vehicleController';
import { authenticateJWT, authorizeRoles } from '../middleware/auth';

const router = Router();

router.use(authenticateJWT);
router.get('/', getVehicles);
router.post('/', authorizeRoles('DRIVER', 'ADMIN'), registerVehicle);
router.patch('/:id/status', authorizeRoles('DRIVER', 'ADMIN'), updateVehicleStatus);

export default router;
