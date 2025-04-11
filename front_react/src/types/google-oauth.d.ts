declare module "@react-oauth/google" {
  export interface TokenResponse {
    credential: string;
    clientId?: string;
    select_by?: string;
  }

  export interface GoogleLoginProps {
    onSuccess: (response: TokenResponse) => void;
    onError?: () => void;
    width?: string | number;
    useOneTap?: boolean;
    auto_select?: boolean;
    theme?: "outline" | "filled_blue" | "filled_black";
    text?: "signin_with" | "signup_with" | "continue_with" | "signin";
    shape?: "rectangular" | "pill" | "circle" | "square";
    locale?: string;
    type?: "standard" | "icon";
    flow?: "implicit";
    responseType?: "token";
    scope?: string;
  }

  export interface GoogleOAuthProviderProps {
    clientId: string;
    children: React.ReactNode;
  }

  export const GoogleLogin: React.FC<GoogleLoginProps>;
  export const GoogleOAuthProvider: React.FC<GoogleOAuthProviderProps>;
}
