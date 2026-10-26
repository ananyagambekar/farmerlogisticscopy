import { Router } from 'express';
import { getIncomingDeliveries, confirmDelivery, getDeliveryHistory } from '../controllers/deliveryController';
import { authenticateJWT, authorizeRoles } from '../middleware/auth';

const router = Router();

router.use(authenticateJWT);

router.get('/incoming', authorizeRoles('RECEIVER', 'AGENT', 'ADMIN'), getIncomingDeliveries);
router.post('/:id/confirm', authorizeRoles('RECEIVER', 'AGENT', 'ADMIN'), confirmDelivery);
router.get('/history', authorizeRoles('RECEIVER', 'AGENT', 'ADMIN'), getDeliveryHistory);

export default router;
