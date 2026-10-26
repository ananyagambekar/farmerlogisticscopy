import { Request, Response } from 'express';
export declare function getAllUsers(req: Request, res: Response): Promise<Response<any, Record<string, any>>>;
export declare function getUserById(req: Request, res: Response): Promise<Response<any, Record<string, any>>>;
export declare function updateUserStatus(req: Request, res: Response): Promise<Response<any, Record<string, any>>>;
