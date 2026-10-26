import { Response } from 'express';
import { AuthenticatedRequest } from '../middleware/auth';
export declare function getTrips(req: AuthenticatedRequest, res: Response): Promise<Response<any, Record<string, any>>>;
export declare function getAssignedTrips(req: AuthenticatedRequest, res: Response): Promise<Response<any, Record<string, any>>>;
export declare function getTripById(req: AuthenticatedRequest, res: Response): Promise<Response<any, Record<string, any>>>;
export declare function createTrip(req: AuthenticatedRequest, res: Response): Promise<Response<any, Record<string, any>>>;
export declare function updateTripStatus(req: AuthenticatedRequest, res: Response): Promise<Response<any, Record<string, any>>>;
export declare function addTrackingLog(req: AuthenticatedRequest, res: Response): Promise<Response<any, Record<string, any>>>;
export declare function getTripTrackingLogs(req: AuthenticatedRequest, res: Response): Promise<Response<any, Record<string, any>>>;
