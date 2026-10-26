import { Router } from 'express';
import {
  getTrips,
  getAssignedTrips,
  getTripById,
  createTrip,
  updateTripStatus,
  addTrackingLog,
  getTripTrackingLogs,
} from '../controllers/tripController';
import { authenticateJWT, authorizeRoles } from '../middleware/auth';

const router = Router();

router.use(authenticateJWT);

router.get('/', getTrips);
router.get('/assigned', authorizeRoles('DRIVER', 'AGENT', 'ADMIN'), getAssignedTrips);
router.get('/:id', getTripById);
router.post('/', authorizeRoles('AGENT', 'ADMIN'), createTrip);
router.patch('/:id/status', authorizeRoles('DRIVER', 'AGENT', 'RECEIVER', 'ADMIN'), updateTripStatus);
router.post('/:id/tracking', authorizeRoles('DRIVER', 'AGENT', 'ADMIN'), addTrackingLog);
router.get('/:id/tracking', getTripTrackingLogs);

export default router;
