import { Response } from 'express';
import { AuthenticatedRequest } from '../middleware/auth';
export declare function getSystemConfigs(req: AuthenticatedRequest, res: Response): Promise<Response<any, Record<string, any>>>;
export declare function updateSystemConfig(req: AuthenticatedRequest, res: Response): Promise<Response<any, Record<string, any>>>;
