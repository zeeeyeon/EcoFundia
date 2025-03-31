import client from "../../../shared/api/client";

// API 요청 DTO 타입
export interface ProductRegistrationDto {
  title: string;
  description: string;
  price: number;
  targetAmount: number;
  startDate: string; // ISO 8601 format (YYYY-MM-DDTHH:mm:ss)
  endDate: string; // ISO 8601 format (YYYY-MM-DDTHH:mm:ss)
  category: string;
}

// API 응답 상태 타입
export interface ApiResponseStatus {
  code: number;
  message: string;
}

// 펀딩 상품 등록 API 응답 타입
export interface ProductRegistrationResponse {
  status: ApiResponseStatus;
  content: null; // API 명세서 기준
}

// 에러 응답 타입 정의
interface ErrorResponse {
  response?: {
    status: number;
    data?: {
      status?: {
        message: string;
      };
    };
  };
}

/**
 * 펀딩 상품 등록 API 호출
 * @param dto 펀딩 상품 정보 DTO
 * @param storyFile 상세 스토리 PDF 파일
 * @param imageFiles 상품 이미지 파일 배열
 */
export const registerProduct = async (
  dto: ProductRegistrationDto,
  storyFile: File | null,
  imageFiles: File[] | null
): Promise<ProductRegistrationResponse> => {
  const formData = new FormData();

  // dto 객체를 JSON 문자열로 변환하여 추가
  formData.append(
    "dto",
    new Blob([JSON.stringify(dto)], { type: "application/json" })
  );

  // 상세 스토리 파일 추가 (존재하는 경우)
  if (storyFile) {
    formData.append("storyFile", storyFile);
  }

  // 이미지 파일들 추가 (존재하는 경우)
  if (imageFiles && imageFiles.length > 0) {
    imageFiles.forEach((file) => {
      formData.append("imageFiles", file);
    });
  }

  try {
    const response = await client.post<ProductRegistrationResponse>(
      "/seller/funding/registration",
      formData,
      {
        headers: {
          "Content-Type": "multipart/form-data",
        },
      }
    );
    return response.data;
  } catch (error: unknown) {
    console.error("펀딩 상품 등록 API 오류:", error);
    // 기본 에러 응답 반환
    const err = error as ErrorResponse;
    return {
      status: {
        code: err?.response?.status || 500,
        message:
          err?.response?.data?.status?.message ||
          "상품 등록 중 오류가 발생했습니다.",
      },
      content: null,
    };
  }
};
