import { Router } from 'express';
import { register, login, getMe } from '../controllers/authController';
import { validateRegister, validateLogin } from '../middleware/validation';
import { authLimiter } from '../middleware/rateLimiter';
import { authenticateJWT } from '../middleware/auth';

const router = Router();

router.post('/register', authLimiter, validateRegister, register);
router.post('/login', authLimiter, validateLogin, login);
router.get('/me', authenticateJWT, getMe);

export default router;
