/**
 * 이미지 파일 압축 유틸리티
 */

// 최대 파일 크기 상수
export const MAX_PDF_SIZE_MB = 1;
export const MAX_IMAGE_SIZE_MB = 1;

/**
 * 이미지 압축 함수
 * @param file 원본 이미지 파일
 * @param maxSizeMB 최대 허용 크기 (MB 단위)
 * @returns 압축된 이미지 파일
 */
export const compressImage = async (
  file: File,
  maxSizeMB: number = MAX_IMAGE_SIZE_MB
): Promise<File> => {
  // 이미 충분히 작은 파일은 그대로 반환
  if (file.size <= maxSizeMB * 1024 * 1024) {
    return file;
  }

  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.readAsDataURL(file);
    reader.onload = (event) => {
      const img = new Image();
      img.src = event.target?.result as string;

      img.onload = async () => {
        const canvas = document.createElement("canvas");
        let width = img.width;
        let height = img.height;

        // 최대 크기 설정 (1200px 제한)
        const MAX_WIDTH = 1200;
        const MAX_HEIGHT = 1200;

        if (width > height) {
          if (width > MAX_WIDTH) {
            height = Math.round((height * MAX_WIDTH) / width);
            width = MAX_WIDTH;
          }
        } else {
          if (height > MAX_HEIGHT) {
            width = Math.round((width * MAX_HEIGHT) / height);
            height = MAX_HEIGHT;
          }
        }

        canvas.width = width;
        canvas.height = height;

        const ctx = canvas.getContext("2d");
        ctx?.drawImage(img, 0, 0, width, height);

        // 원본 파일 크기에 따라 압축 품질 조절
        let quality = 0.8; // 기본 80% 품질
        if (file.size > 3 * 1024 * 1024) {
          quality = 0.6; // 3MB 이상은 60% 품질
        } else if (file.size > 5 * 1024 * 1024) {
          quality = 0.4; // 5MB 이상은 40% 품질
        }

        const dataUrl = canvas.toDataURL("image/jpeg", quality);

        // dataURL을 Blob으로 변환
        const byteString = atob(dataUrl.split(",")[1]);
        const mimeString = dataUrl.split(",")[0].split(":")[1].split(";")[0];
        const ab = new ArrayBuffer(byteString.length);
        const ia = new Uint8Array(ab);

        for (let i = 0; i < byteString.length; i++) {
          ia[i] = byteString.charCodeAt(i);
        }

        const blob = new Blob([ab], { type: mimeString });
        let compressedFile = new File([blob], file.name, {
          type: "image/jpeg",
        });

        // 2차 압축 시도 (첫 번째 압축으로 충분하지 않은 경우)
        if (compressedFile.size > maxSizeMB * 1024 * 1024) {
          const secondCanvas = document.createElement("canvas");
          // 더 작은 크기로 조절
          const SECOND_MAX_WIDTH = 800;
          const SECOND_MAX_HEIGHT = 800;

          let secondWidth = width;
          let secondHeight = height;

          if (secondWidth > secondHeight) {
            if (secondWidth > SECOND_MAX_WIDTH) {
              secondHeight = Math.round(
                (secondHeight * SECOND_MAX_WIDTH) / secondWidth
              );
              secondWidth = SECOND_MAX_WIDTH;
            }
          } else {
            if (secondHeight > SECOND_MAX_HEIGHT) {
              secondWidth = Math.round(
                (secondWidth * SECOND_MAX_HEIGHT) / secondHeight
              );
              secondHeight = SECOND_MAX_HEIGHT;
            }
          }

          secondCanvas.width = secondWidth;
          secondCanvas.height = secondHeight;

          const secondCtx = secondCanvas.getContext("2d");
          secondCtx?.drawImage(img, 0, 0, secondWidth, secondHeight);

          // 더 낮은 품질로 압축
          const secondDataUrl = secondCanvas.toDataURL("image/jpeg", 0.5);

          const secondByteString = atob(secondDataUrl.split(",")[1]);
          const secondAb = new ArrayBuffer(secondByteString.length);
          const secondIa = new Uint8Array(secondAb);

          for (let i = 0; i < secondByteString.length; i++) {
            secondIa[i] = secondByteString.charCodeAt(i);
          }

          const secondBlob = new Blob([secondAb], { type: mimeString });
          compressedFile = new File([secondBlob], file.name, {
            type: "image/jpeg",
          });
        }

        resolve(compressedFile);
      };

      img.onerror = (error) => {
        reject(error);
      };
    };

    reader.onerror = (error) => {
      reject(error);
    };
  });
};

/**
 * 스토리 파일(PDF, JPG) 압축 함수
 * @param file 원본 파일
 * @returns 압축된 파일
 */
export const compressStoryFile = async (file: File): Promise<File> => {
  // 이미 충분히 작은 파일은 그대로 반환
  if (file.size <= MAX_PDF_SIZE_MB * 1024 * 1024) {
    return file;
  }

  // PDF 파일인 경우 JPG로 변환 후 압축
  if (file.type === "application/pdf") {
    alert("PDF 파일이 너무 큽니다. JPG 형식으로 변환하여 업로드해주세요.");
    return file; // 현재는 PDF 압축을 지원하지 않으므로 원본 반환
  }

  // JPG 파일인 경우 압축 진행
  if (file.type === "image/jpeg" || file.type === "image/jpg") {
    return await compressImage(file, MAX_PDF_SIZE_MB);
  }

  return file;
};
