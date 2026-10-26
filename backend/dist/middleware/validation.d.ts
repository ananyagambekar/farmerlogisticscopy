import { Request, Response, NextFunction } from 'express';
export declare function validateRegister(req: Request, res: Response, next: NextFunction): Response<any, Record<string, any>> | undefined;
export declare function validateLogin(req: Request, res: Response, next: NextFunction): Response<any, Record<string, any>> | undefined;
