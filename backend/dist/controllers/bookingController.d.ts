import { Response } from 'express';
import { AuthenticatedRequest } from '../middleware/auth';
export declare function getBookings(req: AuthenticatedRequest, res: Response): Promise<Response<any, Record<string, any>>>;
export declare function createBooking(req: AuthenticatedRequest, res: Response): Promise<Response<any, Record<string, any>>>;
export declare function estimateBookingCost(req: AuthenticatedRequest, res: Response): Promise<Response<any, Record<string, any>>>;
export declare function updateBookingStatus(req: AuthenticatedRequest, res: Response): Promise<Response<any, Record<string, any>>>;
export declare function assignBooking(req: AuthenticatedRequest, res: Response): Promise<Response<any, Record<string, any>>>;
