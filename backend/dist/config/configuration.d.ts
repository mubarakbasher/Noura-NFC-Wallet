declare const _default: () => {
    port: number;
    nodeEnv: string;
    database: {
        url: string | undefined;
    };
    jwt: {
        secret: string;
        accessTokenExpiration: string;
        refreshTokenExpiration: string;
    };
    encryption: {
        key: string;
    };
    nfc: {
        signingSecret: string;
        tokenValidityMs: number;
    };
    throttle: {
        ttl: number;
        limit: number;
    };
};
export default _default;
