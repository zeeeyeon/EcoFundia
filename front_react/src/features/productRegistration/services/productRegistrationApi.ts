import client from "../../../shared/api/client"; // client 다시 사용

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

/**
 * 펀딩 상품 등록 API 호출
 * @param dto 펀딩 상품 정보 DTO
 * @param storyFile 상세 스토리 PDF 또는 이미지 파일 (서버 요구사항에 따라 타입 확인 필요)
 * @param imageFiles 상품 이미지 파일 배열
 */
export const registerProduct = async (
  dto: ProductRegistrationDto,
  storyFile: File | null,
  imageFiles: File[] | null
): Promise<ProductRegistrationResponse> => {
  const formData = new FormData();

  // 1. dto 객체를 JSON 문자열로 변환하여 Blob으로 추가 (Content-Type: application/json 명시)
  const dtoBlob = new Blob([JSON.stringify(dto)], { type: "application/json" });
  formData.append("dto", dtoBlob);
  console.log("DTO 데이터:", dto);

  // 2. 상세 스토리 파일 추가 (존재하는 경우)
  if (storyFile) {
    formData.append("storyFile", storyFile);
    console.log(
      "스토리 파일 추가됨:",
      storyFile.name,
      storyFile.type,
      storyFile.size
    );
  }

  // 3. 이미지 파일들 추가 (존재하는 경우)
  if (imageFiles && imageFiles.length > 0) {
    imageFiles.forEach((file) => {
      let fileToAdd = file;
      // PNG 파일의 MIME 타입 확인 및 보정
      if (file.name.endsWith(".png") && file.type !== "image/png") {
        console.warn(
          `[MIME 타입 보정] ${file.name}: '${file.type}' -> 'image/png'`
        );
        try {
          fileToAdd = new File([file], file.name, { type: "image/png" });
        } catch (e) {
          console.error("File 객체 재생성 중 오류 발생:", e);
          fileToAdd = file;
        }
      }
      formData.append("imageFiles", fileToAdd);
      console.log(
        "이미지 파일 추가됨:",
        fileToAdd.name,
        fileToAdd.type,
        fileToAdd.size
      );
    });
  }

  // FormData 내용 디버깅
  console.log("--- FormData 최종 내용 ---");
  for (const pair of formData.entries()) {
    if (pair[1] instanceof File) {
      console.log(
        `${pair[0]}: File(name=${pair[1].name}, size=${pair[1].size}, type=${pair[1].type})`
      );
    } else {
      console.log(
        `${pair[0]}: ${String(pair[1]).substring(0, 100)}${
          String(pair[1]).length > 100 ? "..." : ""
        }`
      );
    }
  }
  console.log("--------------------------");

  try {
    // client 인스턴스를 사용하여 요청 보내기
    // Content-Type은 설정하지 않아 브라우저가 자동으로 multipart/form-data와 boundary를 설정
    const response = await client.post<ProductRegistrationResponse>(
      "/seller/funding/registration",
      formData,
      {
        headers: {
          // Content-Type을 명시적으로 undefined로 설정하여 client의 기본값 덮어쓰기
          "Content-Type": undefined,
        },
      }
    );

    console.log("상품 등록 성공:", response.data);
    return response.data;
  } catch (error: unknown) {
    console.error("상품 등록 오류:", error);

    // 에러 응답 구조화
    return {
      status: {
        code: 500,
        message: "상품 등록 중 오류가 발생했습니다.",
      },
      content: null,
    };
  }
};
