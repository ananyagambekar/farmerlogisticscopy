import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { apiLimiter } from './middleware/rateLimiter';
import authRoutes from './routes/authRoutes';
import userRoutes from './routes/userRoutes';
import cropRoutes from './routes/cropRoutes';
import bookingRoutes from './routes/bookingRoutes';
import tripRoutes from './routes/tripRoutes';
import deliveryRoutes from './routes/deliveryRoutes';
import vehicleRoutes from './routes/vehicleRoutes';
import systemConfigRoutes from './routes/systemConfigRoutes';
import { store } from './services/store';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors({ origin: process.env.CORS_ORIGIN || '*' }));
app.use(express.json());
app.use(apiLimiter);

// Health check endpoint
app.get('/api/v1/health', async (req, res) => {
  await store.seedInitialData();
  return res.status(200).json({
    status: 'UP',
    timestamp: new Date().toISOString(),
    service: 'Dynamic Agri-Logistics Backend API',
    version: '1.0.0',
    environment: process.env.NODE_ENV || 'development',
  });
});

// Routes
app.use('/api/v1/auth', authRoutes);
app.use('/api/auth', authRoutes);
app.use('/api/v1/users', userRoutes);
app.use('/api/users', userRoutes);
app.use('/api/v1/crops', cropRoutes);
app.use('/api/crops', cropRoutes);
app.use('/api/v1/bookings', bookingRoutes);
app.use('/api/bookings', bookingRoutes);
app.use('/api/v1/trips', tripRoutes);
app.use('/api/trips', tripRoutes);
app.use('/api/v1/deliveries', deliveryRoutes);
app.use('/api/deliveries', deliveryRoutes);
app.use('/api/v1/vehicles', vehicleRoutes);
app.use('/api/vehicles', vehicleRoutes);
app.use('/api/v1/system-configs', systemConfigRoutes);
app.use('/api/system-configs', systemConfigRoutes);

// Global 404 handler
app.use((req, res) => {
  res.status(404).json({ success: false, message: `Route ${req.method} ${req.url} not found` });
});

// Global Error Handler
app.use((err: any, req: express.Request, res: express.Response, next: express.NextFunction) => {
  console.error('Unhandled Server Error:', err);
  res.status(500).json({ success: false, message: 'Internal Server Error', error: err.message });
});

app.listen(PORT, async () => {
  await store.seedInitialData();
  console.log(`🌱 Dynamic Agri-Logistics Server listening on port ${PORT}`);
});

export default app;
