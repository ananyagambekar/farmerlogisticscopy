import { Request, Response } from 'express';
import { store } from '../services/store';

export async function getAllUsers(req: Request, res: Response) {
  await store.seedInitialData();
  const usersList = Array.from(store.users.values()).map(u => ({
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

export async function getUserById(req: Request, res: Response) {
  await store.seedInitialData();
  const { id } = req.params;
  const u = store.users.get(id);
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

export async function updateUserStatus(req: Request, res: Response) {
  await store.seedInitialData();
  const { id } = req.params;
  const { isActive } = req.body;
  const u = store.users.get(id);
  if (!u) {
    return res.status(404).json({ success: false, message: 'User not found' });
  }
  u.isActive = Boolean(isActive);
  u.updatedAt = new Date().toISOString();
  store.users.set(id, u);
  return res.status(200).json({ success: true, message: 'User status updated', data: u });
}
