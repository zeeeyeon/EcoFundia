interface GoogleUser {
    getAuthResponse(): {
        id_token: string;
        access_token: string;
    };
}

interface Auth2 {
    getAuthInstance(): Promise<{
        signIn(): Promise<GoogleUser>;
    }>;
}

interface Gapi {
    auth2: Auth2;
    load(api: string, callback: () => void): void;
}

declare global {
    interface Window {
        gapi: Gapi;
    }
} 