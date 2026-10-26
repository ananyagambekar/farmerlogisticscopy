import { Request, Response } from 'express';
import { hashPassword, comparePassword } from '../utils/password';
import { generateToken } from '../utils/jwt';
import { store, UserRecord } from '../services/store';
import { AuthenticatedRequest } from '../middleware/auth';

export async function register(req: Request, res: Response) {
  try {
    await store.seedInitialData();
    const { phone, email, password, fullName, role } = req.body;

    // Check if phone already registered
    for (const u of store.users.values()) {
      if (u.phone === phone) {
        return res.status(409).json({ success: false, message: 'Phone number already registered' });
      }
      if (email && u.email === email) {
        return res.status(409).json({ success: false, message: 'Email address already registered' });
      }
    }

    const hashedPassword = await hashPassword(password);
    const newUser: UserRecord = {
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

    store.users.set(newUser.id, newUser);

    const token = generateToken({
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
  } catch (error: any) {
    return res.status(500).json({ success: false, message: error.message || 'Internal server error' });
  }
}

export async function login(req: Request, res: Response) {
  try {
    await store.seedInitialData();
    const { phone, email, password } = req.body;

    let user: UserRecord | undefined;
    for (const u of store.users.values()) {
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

    const isMatch = await comparePassword(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ success: false, message: 'Invalid phone/email or password' });
    }

    const token = generateToken({
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
  } catch (error: any) {
    return res.status(500).json({ success: false, message: error.message || 'Internal server error' });
  }
}

export async function getMe(req: AuthenticatedRequest, res: Response) {
  try {
    await store.seedInitialData();
    if (!req.user) {
      return res.status(401).json({ success: false, message: 'Unauthorized' });
    }

    const user = store.users.get(req.user.userId);
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
  } catch (error: any) {
    return res.status(500).json({ success: false, message: error.message || 'Internal server error' });
  }
}
