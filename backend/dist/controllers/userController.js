"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getAllUsers = getAllUsers;
exports.getUserById = getUserById;
exports.updateUserStatus = updateUserStatus;
const store_1 = require("../services/store");
async function getAllUsers(req, res) {
    await store_1.store.seedInitialData();
    const usersList = Array.from(store_1.store.users.values()).map(u => ({
        id: u.id,
        phone: u.phone,
        email: u.email,
        fullName: u.fullName,
        role: u.role,
        isActive: u.isActive,
        createdAt: u.createdAt,
    }));
    return res.status(200).json({ success: true, count: usersList.length, data: usersList });
}
async function getUserById(req, res) {
    await store_1.store.seedInitialData();
    const { id } = req.params;
    const u = store_1.store.users.get(id);
    if (!u) {
        return res.status(404).json({ success: false, message: 'User not found' });
    }
    return res.status(200).json({
        success: true,
        data: {
            id: u.id,
            phone: u.phone,
            email: u.email,
            fullName: u.fullName,
            role: u.role,
            isActive: u.isActive,
            createdAt: u.createdAt,
        },
    });
}
async function updateUserStatus(req, res) {
    await store_1.store.seedInitialData();
    const { id } = req.params;
    const { isActive } = req.body;
    const u = store_1.store.users.get(id);
    if (!u) {
        return res.status(404).json({ success: false, message: 'User not found' });
    }
    u.isActive = Boolean(isActive);
    u.updatedAt = new Date().toISOString();
    store_1.store.users.set(id, u);
    return res.status(200).json({ success: true, message: 'User status updated', data: u });
}
