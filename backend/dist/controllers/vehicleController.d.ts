import { Response } from 'express';
import { AuthenticatedRequest } from '../middleware/auth';
export declare function getVehicles(req: AuthenticatedRequest, res: Response): Promise<Response<any, Record<string, any>>>;
export declare function registerVehicle(req: AuthenticatedRequest, res: Response): Promise<Response<any, Record<string, any>>>;
export declare function updateVehicleStatus(req: AuthenticatedRequest, res: Response): Promise<Response<any, Record<string, any>>>;
