import { Router } from 'express';
import { getBookings, createBooking, estimateBookingCost, updateBookingStatus, assignBooking } from '../controllers/bookingController';
import { authenticateJWT, authorizeRoles } from '../middleware/auth';

const router = Router();

router.use(authenticateJWT);
router.get('/', getBookings);
router.post('/', authorizeRoles('FARMER', 'AGENT', 'ADMIN'), createBooking);
router.post('/estimate', authorizeRoles('FARMER', 'AGENT', 'ADMIN', 'RECEIVER', 'DRIVER'), estimateBookingCost);
router.patch('/:id/status', authorizeRoles('AGENT', 'ADMIN'), updateBookingStatus);
router.post('/:id/assign', authorizeRoles('AGENT', 'ADMIN'), assignBooking);

export default router;
