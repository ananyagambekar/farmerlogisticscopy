import { Response } from 'express';
import { store, SystemConfigRecord } from '../services/store';
import { AuthenticatedRequest } from '../middleware/auth';

export async function getSystemConfigs(req: AuthenticatedRequest, res: Response) {
  await store.seedInitialData();
  const list = Array.from(store.configs.values());
  return res.status(200).json({ success: true, count: list.length, data: list });
}

export async function updateSystemConfig(req: AuthenticatedRequest, res: Response) {
  await store.seedInitialData();
  const { key } = req.params;
  const { value, description } = req.body;

  let config: SystemConfigRecord | undefined;
  for (const c of store.configs.values()) {
    if (c.key === key) {
      config = c;
      break;
    }
  }

  if (!config) {
    config = {
      id: `cfg-${Date.now()}`,
      key,
      value: String(value),
      description: description || '',
      updatedAt: new Date().toISOString(),
    };
  } else {
    config.value = String(value);
    if (description !== undefined) config.description = description;
    config.updatedAt = new Date().toISOString();
  }

  store.configs.set(config.id, config);
  return res.status(200).json({ success: true, message: 'System configuration updated', data: config });
}
