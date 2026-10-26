import { Response } from 'express';
import { AuthenticatedRequest } from '../middleware/auth';
export declare function getCrops(req: AuthenticatedRequest, res: Response): Promise<Response<any, Record<string, any>>>;
export declare function createCrop(req: AuthenticatedRequest, res: Response): Promise<Response<any, Record<string, any>>>;
export declare function updateCrop(req: AuthenticatedRequest, res: Response): Promise<Response<any, Record<string, any>>>;
export declare function updateCropStatus(req: AuthenticatedRequest, res: Response): Promise<Response<any, Record<string, any>>>;
export declare function deleteCrop(req: AuthenticatedRequest, res: Response): Promise<Response<any, Record<string, any>>>;
