import { create } from 'zustand';

interface ProductModalState {
    isModalOpen: boolean;
    selectedFundingId: number | null;
    openModal: (fundingId: number) => void;
    closeModal: () => void;
}

const useProductModalStore = create<ProductModalState>((set) => ({
    isModalOpen: false,
    selectedFundingId: null,
    openModal: (fundingId) => {
        // 방어 로직: fundingId가 유효한 숫자가 아니면 무시
        if (isNaN(fundingId) || fundingId === undefined) {
            console.error('Invalid fundingId passed to openModal:', fundingId);
            return;
        }
        console.log('Opening modal with valid fundingId:', fundingId);
        set({ isModalOpen: true, selectedFundingId: fundingId });
    },
    closeModal: () => set({ isModalOpen: false, selectedFundingId: null }),
}));

export default useProductModalStore; 