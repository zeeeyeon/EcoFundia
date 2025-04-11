import { create } from 'zustand';
import { registerProduct, ProductRegistrationDto } from '../services/productRegistrationApi';

interface ProductRegistrationState {
    isLoading: boolean;
    error: string | null;
    isSuccess: boolean;
    submitForm: (
        dto: ProductRegistrationDto,
        storyFile: File | null,
        imageFiles: File[] | null
    ) => Promise<boolean>; // 성공 여부 반환
    resetState: () => void;
}

const useProductRegistrationStore = create<ProductRegistrationState>((set) => ({
    isLoading: false,
    error: null,
    isSuccess: false,

    submitForm: async (dto: ProductRegistrationDto, storyFile: File | null, imageFiles: File[] | null) => {
        set({ isLoading: true, error: null, isSuccess: false });
        try {
            const response = await registerProduct(dto, storyFile, imageFiles);
            if (response.status.code === 200) {
                set({ isLoading: false, isSuccess: true });
                return true; // 성공
            } else {
                set({ isLoading: false, error: response.status.message, isSuccess: false });
                return false; // 실패
            }
        } catch (err: unknown) {
            const errorMessage = err instanceof Error ? err.message : '알 수 없는 오류가 발생했습니다.';
            set({ isLoading: false, error: errorMessage, isSuccess: false });
            return false; // 실패
        }
    },

    resetState: () => set({ isLoading: false, error: null, isSuccess: false }),
}));

export default useProductRegistrationStore; 