import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { ProductRegistrationDto } from "../services/productRegistrationApi";

// 날짜 형식 유효성 검사 (YYYY-MM-DD 형식으로 변경)
const dateRegex = /^\d{4}-\d{2}-\d{2}$/;

// 최대 파일 크기 설정 (바이트 단위)
export const MAX_IMAGE_SIZE = 1 * 1024 * 1024; // 1MB
export const MAX_STORY_FILE_SIZE = 1 * 1024 * 1024; // 1MB (PDF, JPG 공통)

// 허용되는 스토리 파일 타입
const ALLOWED_STORY_FILE_TYPES = ["application/pdf", "image/jpeg", "image/jpg"];

// Zod 스키마 정의
const productRegistrationSchema = z
  .object({
    title: z.string().min(1, "상품명을 입력해주세요."),
    description: z.string().min(1, "상품 소개를 입력해주세요."),
    category: z.string().min(1, "카테고리를 선택해주세요."),
    price: z
      .string()
      .min(1, "판매 가격을 입력해주세요.")
      .refine(
        (val) => !isNaN(Number(val)) && Number(val) > 0,
        "판매 가격은 0보다 커야 합니다."
      ),
    targetAmount: z
      .string()
      .min(1, "목표 금액을 입력해주세요.")
      .refine(
        (val) => !isNaN(Number(val)) && Number(val) > 0,
        "목표 금액은 0보다 커야 합니다."
      ),
    startDate: z.string(),
    endDate: z.string().refine((val) => dateRegex.test(val), {
      message: "마감 날짜를 선택해주세요.",
    }),
    storyFile: z
      .instanceof(FileList)
      .refine(
        (files: FileList) => files && files.length === 1,
        "상세페이지 파일을 1개 등록해주세요."
      )
      .refine((files: FileList) => {
        if (!files || files.length === 0) return true;
        return ALLOWED_STORY_FILE_TYPES.includes(files[0].type);
      }, "상세페이지 파일은 PDF 또는 JPG 형식만 허용됩니다."),
    imageFiles: z
      .instanceof(FileList)
      .refine(
        (files: FileList) => files && files.length >= 1,
        "대표 이미지를 1개 이상 등록해주세요."
      )
      .refine(
        (files: FileList) => files && files.length <= 5,
        "이미지는 최대 5개까지 등록할 수 있습니다."
      ),
  })
  .refine(
    (data) => {
      // endDate가 현재 날짜보다 미래인지 확인
      if (!data.endDate) return true;

      const endDate = new Date(data.endDate);
      const today = new Date();
      today.setHours(0, 0, 0, 0); // 시간 제거

      return endDate > today;
    },
    {
      message: "마감 날짜는 오늘 이후로 설정해야 합니다.",
      path: ["endDate"],
    }
  );

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
    setValue,
  } = useForm<ProductFormData>({
    resolver: zodResolver(productRegistrationSchema),
    defaultValues: {
      title: "",
      description: "",
      category: "",
      price: "",
      targetAmount: "",
      startDate: "",
      endDate: "",
      storyFile: undefined,
      imageFiles: undefined,
    },
  });

  // Form data를 API DTO 형식으로 변환하는 함수
  const prepareFormData = (
    data: ProductFormData
  ): {
    dto: ProductRegistrationDto;
    storyFile: File | null;
    imageFiles: File[] | null;
  } => {
    // 날짜 형식 변환 (YYYY-MM-DD -> ISO 형식)
    const convertToISODate = (dateStr: string) => {
      if (!dateStr) return "";
      const date = new Date(dateStr);
      return date.toISOString();
    };

    const dto: ProductRegistrationDto = {
      title: data.title,
      description: data.description,
      price: Number(data.price),
      targetAmount: Number(data.targetAmount),
      startDate: new Date().toISOString(), // 현재 시간으로 설정
      endDate: convertToISODate(data.endDate),
      category: data.category,
    };

    const storyFile = data.storyFile ? data.storyFile[0] : null;
    const imageFiles = data.imageFiles
      ? Array.from(data.imageFiles).map((file) => file as File)
      : null;

    return { dto, storyFile, imageFiles };
  };

  // 내일 날짜 문자열 반환 (YYYY-MM-DD)
  const getTomorrowDate = () => {
    const tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 1);
    return tomorrow.toISOString().split("T")[0];
  };

  return {
    register,
    handleSubmit,
    errors,
    reset,
    imagePreviews: [], // 빈 배열 반환 (호환성 유지)
    prepareFormData,
    setValue,
    getTomorrowDate,
  };
};

// 카테고리 옵션 (실제 프로젝트에 맞게 수정 필요)
export const categoryOptions = [
  { value: "FOOD", label: "식품" },
  { value: "FASHION", label: "패션/잡화" },
  { value: "ELECTRONICS", label: "전자기기" },
  { value: "HOUSEHOLD", label: "생활용품" },
  { value: "INTERIOR", label: "인테리어" },
];
