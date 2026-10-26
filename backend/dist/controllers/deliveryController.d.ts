import { Response } from 'express';
import { AuthenticatedRequest } from '../middleware/auth';
export declare function getIncomingDeliveries(req: AuthenticatedRequest, res: Response): Promise<Response<any, Record<string, any>>>;
export declare function confirmDelivery(req: AuthenticatedRequest, res: Response): Promise<Response<any, Record<string, any>>>;
export declare function getDeliveryHistory(req: AuthenticatedRequest, res: Response): Promise<Response<any, Record<string, any>>>;
