"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.validateRegister = validateRegister;
exports.validateLogin = validateLogin;
const phone_1 = require("../utils/phone");
function validateRegister(req, res, next) {
    const { phone, password, fullName, role } = req.body;
    if (!phone || typeof phone !== 'string') {
        return res.status(400).json({ success: false, message: 'Valid phone number is required' });
    }
    const normalized = (0, phone_1.normalizePhone)(phone);
    if (!(0, phone_1.isValidPhone)(normalized)) {
        return res.status(400).json({ success: false, message: 'Invalid phone number format' });
    }
    req.body.phone = normalized;
    if (!password || typeof password !== 'string' || password.length < 6) {
        return res.status(400).json({ success: false, message: 'Password must be at least 6 characters long' });
    }
    if (!fullName || typeof fullName !== 'string' || fullName.trim().length === 0) {
        return res.status(400).json({ success: false, message: 'Full name is required' });
    }
    const validRoles = ['FARMER', 'AGENT', 'DRIVER', 'RECEIVER'];
    if (!role || !validRoles.includes(role)) {
        return res.status(400).json({
            success: false,
            message: `Invalid role. Allowed registration roles: ${validRoles.join(', ')}. ADMIN role cannot be registered publicly.`
        });
    }
    next();
}
function validateLogin(req, res, next) {
    const { phone, email, password } = req.body;
    if ((!phone && !email) || !password) {
        return res.status(400).json({ success: false, message: 'Phone or Email and Password are required' });
    }
    if (phone) {
        req.body.phone = (0, phone_1.normalizePhone)(phone);
    }
    next();
}
