export interface TokenPayload {
    userId: string;
    phone: string;
    role: string;
}
export declare function generateToken(payload: TokenPayload): string;
export declare function verifyToken(token: string): TokenPayload;
