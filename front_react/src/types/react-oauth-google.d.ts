declare module "@react-oauth/google" {
  export interface GoogleLoginResponse {
    access_token: string;
  }

  export interface UseGoogleLoginOptions {
    onSuccess?: (response: GoogleLoginResponse) => void;
    onError?: () => void;
    scope?: string;
  }

  export interface GoogleLoginProps {
    onSuccess?: (credentialResponse: { credential: string }) => void;
    onError?: () => void;
    useOneTap?: boolean;
    auto_select?: boolean;
  }

  export function useGoogleLogin(options: UseGoogleLoginOptions): () => void;
  export function GoogleLogin(props: GoogleLoginProps): JSX.Element;
}
