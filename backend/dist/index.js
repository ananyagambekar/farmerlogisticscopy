"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const dotenv_1 = __importDefault(require("dotenv"));
const rateLimiter_1 = require("./middleware/rateLimiter");
const authRoutes_1 = __importDefault(require("./routes/authRoutes"));
const userRoutes_1 = __importDefault(require("./routes/userRoutes"));
const cropRoutes_1 = __importDefault(require("./routes/cropRoutes"));
const bookingRoutes_1 = __importDefault(require("./routes/bookingRoutes"));
const tripRoutes_1 = __importDefault(require("./routes/tripRoutes"));
const deliveryRoutes_1 = __importDefault(require("./routes/deliveryRoutes"));
const vehicleRoutes_1 = __importDefault(require("./routes/vehicleRoutes"));
const systemConfigRoutes_1 = __importDefault(require("./routes/systemConfigRoutes"));
const store_1 = require("./services/store");
dotenv_1.default.config();
const app = (0, express_1.default)();
const PORT = process.env.PORT || 3000;
app.use((0, cors_1.default)({ origin: process.env.CORS_ORIGIN || '*' }));
app.use(express_1.default.json());
app.use(rateLimiter_1.apiLimiter);
// Health check endpoint
app.get('/api/v1/health', async (req, res) => {
    await store_1.store.seedInitialData();
    return res.status(200).json({
        status: 'UP',
        timestamp: new Date().toISOString(),
        service: 'Dynamic Agri-Logistics Backend API',
        version: '1.0.0',
        environment: process.env.NODE_ENV || 'development',
    });
});
// Routes
app.use('/api/v1/auth', authRoutes_1.default);
app.use('/api/auth', authRoutes_1.default);
app.use('/api/v1/users', userRoutes_1.default);
app.use('/api/users', userRoutes_1.default);
app.use('/api/v1/crops', cropRoutes_1.default);
app.use('/api/crops', cropRoutes_1.default);
app.use('/api/v1/bookings', bookingRoutes_1.default);
app.use('/api/bookings', bookingRoutes_1.default);
app.use('/api/v1/trips', tripRoutes_1.default);
app.use('/api/trips', tripRoutes_1.default);
app.use('/api/v1/deliveries', deliveryRoutes_1.default);
app.use('/api/deliveries', deliveryRoutes_1.default);
app.use('/api/v1/vehicles', vehicleRoutes_1.default);
app.use('/api/vehicles', vehicleRoutes_1.default);
app.use('/api/v1/system-configs', systemConfigRoutes_1.default);
app.use('/api/system-configs', systemConfigRoutes_1.default);
// Global 404 handler
app.use((req, res) => {
    res.status(404).json({ success: false, message: `Route ${req.method} ${req.url} not found` });
});
// Global Error Handler
app.use((err, req, res, next) => {
    console.error('Unhandled Server Error:', err);
    res.status(500).json({ success: false, message: 'Internal Server Error', error: err.message });
});
app.listen(PORT, async () => {
    await store_1.store.seedInitialData();
    console.log(`🌱 Dynamic Agri-Logistics Server listening on port ${PORT}`);
});
exports.default = app;
