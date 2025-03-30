import { useState, useEffect } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { ProductRegistrationDto } from '../services/productRegistrationApi';

// 날짜 형식 유효성 검사 (YYYY-MM-DDTHH:MM:SS - input datetime-local 기본 형식과 약간 다름 주의)
const isoDateTimeRegex = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}(:\d{2})?$/;

// Zod 스키마 정의
const productRegistrationSchema = z.object({
    title: z.string().min(1, '상품명을 입력해주세요.'),
    description: z.string().min(1, '상품 소개를 입력해주세요.'),
    category: z.string().min(1, '카테고리를 선택해주세요.'),
    price: z.number({ invalid_type_error: '가격을 숫자로 입력해주세요.' }).positive('가격은 0보다 커야 합니다.'),
    targetAmount: z.number({ invalid_type_error: '목표 금액을 숫자로 입력해주세요.' }).positive('목표 금액은 0보다 커야 합니다.'),
    startDate: z.string().refine((val: string) => isoDateTimeRegex.test(val) || val === '', {
        message: '시작 날짜 및 시간을 입력해주세요.',
    }),
    endDate: z.string().refine((val: string) => isoDateTimeRegex.test(val) || val === '', {
        message: '마감 날짜 및 시간을 입력해주세요.',
    }),
    storyFile: z.instanceof(FileList)
        .refine((files: FileList) => files && files.length === 1, '상세페이지 PDF 파일을 1개 등록해주세요.'),
    imageFiles: z.instanceof(FileList)
        .refine((files: FileList) => files && files.length >= 1, '대표 이미지를 1개 이상 등록해주세요.')
        .refine((files: FileList) => files && files.length <= 5, '이미지는 최대 5개까지 등록할 수 있습니다.'),
}).refine((data: { startDate: string; endDate: string }) => {
    // startDate와 endDate가 유효한 날짜 형식일 때만 비교
    if (!data.startDate || !data.endDate) return true; // 둘 중 하나라도 비어있으면 비교 생략
    try {
        return new Date(data.startDate) < new Date(data.endDate);
    } catch {
        return false; // 날짜 형식이 잘못되면 비교 불가
    }
}, {
    message: "마감 날짜는 시작 날짜보다 이후여야 합니다.",
    path: ["endDate"],
});

// 타입 추출
export type ProductFormData = z.infer<typeof productRegistrationSchema>;

/**
 * 상품 등록 폼 관리 커스텀 훅
 */
export const useProductForm = () => {
    // 폼 상태 관리
    const {
        register,
        handleSubmit,
        formState: { errors },
        reset,
        watch,
        setValue
    } = useForm<ProductFormData>({
        resolver: zodResolver(productRegistrationSchema),
        defaultValues: {
            title: '',
            description: '',
            category: '',
            price: undefined,
            targetAmount: undefined,
            startDate: '',
            endDate: '',
            storyFile: undefined,
            imageFiles: undefined,
        }
    });

    // 파일 미리보기 로직
    const watchedImageFiles = watch('imageFiles');
    const [imagePreviews, setImagePreviews] = useState<string[]>([]);

    useEffect(() => {
        if (watchedImageFiles && watchedImageFiles.length > 0) {
            const newPreviews = Array.from(watchedImageFiles).map((file: File) => URL.createObjectURL(file));
            setImagePreviews(newPreviews);

            // 컴포넌트 언마운트 시 Object URL 해제
            return () => {
                newPreviews.forEach(url => URL.revokeObjectURL(url));
            };
        } else {
            setImagePreviews([]);
        }
    }, [watchedImageFiles]);

    // Form data를 API DTO 형식으로 변환하는 함수
    const prepareFormData = (data: ProductFormData): {
        dto: ProductRegistrationDto;
        storyFile: File | null;
        imageFiles: File[] | null;
    } => {
        const dto: ProductRegistrationDto = {
            title: data.title,
            description: data.description,
            price: Number(data.price),
            targetAmount: Number(data.targetAmount),
            startDate: data.startDate || new Date().toISOString(),
            endDate: data.endDate,
            category: data.category
        };

        const storyFile = data.storyFile ? data.storyFile[0] : null;
        const imageFiles = data.imageFiles ? Array.from(data.imageFiles).map(file => file as File) : null;

        return { dto, storyFile, imageFiles };
    };

    return {
        register,
        handleSubmit,
        errors,
        reset,
        imagePreviews,
        prepareFormData,
        setValue
    };
};

// 카테고리 옵션 (실제 프로젝트에 맞게 수정 필요)
export const categoryOptions = [
    { value: 'electronics', label: '전자기기' },
    { value: 'fashion', label: '패션/잡화' },
    { value: 'food', label: '식품' },
    { value: 'beauty', label: '뷰티' },
    { value: 'living', label: '리빙/홈' },
    { value: 'eco', label: '친환경' },
    { value: 'etc', label: '기타' }
]; 