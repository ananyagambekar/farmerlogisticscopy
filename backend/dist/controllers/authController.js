"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.register = register;
exports.login = login;
exports.getMe = getMe;
const password_1 = require("../utils/password");
const jwt_1 = require("../utils/jwt");
const store_1 = require("../services/store");
async function register(req, res) {
    try {
        await store_1.store.seedInitialData();
        const { phone, email, password, fullName, role } = req.body;
        // Check if phone already registered
        for (const u of store_1.store.users.values()) {
            if (u.phone === phone) {
                return res.status(409).json({ success: false, message: 'Phone number already registered' });
            }
            if (email && u.email === email) {
                return res.status(409).json({ success: false, message: 'Email address already registered' });
            }
        }
        const hashedPassword = await (0, password_1.hashPassword)(password);
        const newUser = {
            id: `usr-${Date.now()}`,
            phone,
            email: email || undefined,
            password: hashedPassword,
            fullName: fullName.trim(),
            role,
            isActive: true,
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString(),
        };
        store_1.store.users.set(newUser.id, newUser);
        const token = (0, jwt_1.generateToken)({
            userId: newUser.id,
            phone: newUser.phone,
            role: newUser.role,
        });
        return res.status(201).json({
            success: true,
            message: 'Registration successful',
            data: {
                token,
                user: {
                    id: newUser.id,
                    phone: newUser.phone,
                    email: newUser.email,
                    fullName: newUser.fullName,
                    role: newUser.role,
                    isActive: newUser.isActive,
                    createdAt: newUser.createdAt,
                },
            },
        });
    }
    catch (error) {
        return res.status(500).json({ success: false, message: error.message || 'Internal server error' });
    }
}
async function login(req, res) {
    try {
        await store_1.store.seedInitialData();
        const { phone, email, password } = req.body;
        let user;
        for (const u of store_1.store.users.values()) {
            if ((phone && u.phone === phone) || (email && u.email === email)) {
                user = u;
                break;
            }
        }
        if (!user) {
            return res.status(401).json({ success: false, message: 'Invalid phone/email or password' });
        }
        if (!user.isActive) {
            return res.status(403).json({ success: false, message: 'Account is deactivated. Please contact administrator.' });
        }
        const isMatch = await (0, password_1.comparePassword)(password, user.password);
        if (!isMatch) {
            return res.status(401).json({ success: false, message: 'Invalid phone/email or password' });
        }
        const token = (0, jwt_1.generateToken)({
            userId: user.id,
            phone: user.phone,
            role: user.role,
        });
        return res.status(200).json({
            success: true,
            message: 'Login successful',
            data: {
                token,
                user: {
                    id: user.id,
                    phone: user.phone,
                    email: user.email,
                    fullName: user.fullName,
                    role: user.role,
                    isActive: user.isActive,
                    createdAt: user.createdAt,
                },
            },
        });
    }
    catch (error) {
        return res.status(500).json({ success: false, message: error.message || 'Internal server error' });
    }
}
async function getMe(req, res) {
    try {
        await store_1.store.seedInitialData();
        if (!req.user) {
            return res.status(401).json({ success: false, message: 'Unauthorized' });
        }
        const user = store_1.store.users.get(req.user.userId);
        if (!user) {
            return res.status(404).json({ success: false, message: 'User not found' });
        }
        return res.status(200).json({
            success: true,
            data: {
                id: user.id,
                phone: user.phone,
                email: user.email,
                fullName: user.fullName,
                role: user.role,
                isActive: user.isActive,
                createdAt: user.createdAt,
                updatedAt: user.updatedAt,
            },
        });
    }
    catch (error) {
        return res.status(500).json({ success: false, message: error.message || 'Internal server error' });
    }
}
