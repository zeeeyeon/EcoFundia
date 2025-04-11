import React, { useRef } from "react";
import { UseFormSetValue, FieldErrors } from "react-hook-form";
import { ProductFormData } from "../../hooks/useProductForm";
import "../../styles/ProductRegistrationForm.css";

interface StoryFileUploaderProps {
  errors: FieldErrors<ProductFormData>;
  setValue: UseFormSetValue<ProductFormData>;
  pdfFileName: string;
  setPdfFileName: React.Dispatch<React.SetStateAction<string>>;
  compressStoryFile: (file: File) => Promise<File>;
}

const StoryFileUploader: React.FC<StoryFileUploaderProps> = ({
  errors,
  setValue,
  pdfFileName,
  setPdfFileName,
  compressStoryFile,
}) => {
  const pdfInputRef = useRef<HTMLInputElement>(null);
  const MAX_PDF_SIZE_MB = 1; // 최대 파일 크기 상수 (UI 표시용)

  const handlePdfButtonClick = () => {
    pdfInputRef.current?.click();
  };

  const handlePdfChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    // 파일 형식 확인
    const fileType = file.type;
    if (
      fileType !== "application/pdf" &&
      fileType !== "image/jpeg" &&
      fileType !== "image/jpg"
    ) {
      alert("스토리 파일은 PDF 또는 JPG 형식만 허용됩니다.");
      return;
    }

    try {
      // 파일 크기 확인 및 압축
      let processedFile = file;
      if (file.size > MAX_PDF_SIZE_MB * 1024 * 1024) {
        alert(
          `스토리 파일이 ${MAX_PDF_SIZE_MB}MB를 초과하여 자동으로 압축을 시도합니다.`
        );
        processedFile = await compressStoryFile(file);

        // 압축 후에도 크기가 크면 알림
        if (processedFile.size > MAX_PDF_SIZE_MB * 1024 * 1024) {
          alert(
            `압축 후에도 파일 크기가 ${MAX_PDF_SIZE_MB}MB를 초과합니다. 더 작은 파일을 사용해주세요.`
          );
          return;
        }
      }

      // 성공적으로 처리된 파일 설정
      setPdfFileName(processedFile.name);

      // FileList 객체 생성
      const dataTransfer = new DataTransfer();
      dataTransfer.items.add(processedFile);
      setValue("storyFile", dataTransfer.files);
    } catch (error) {
      console.error("스토리 파일 처리 중 오류:", error);
      alert("파일 처리 중 오류가 발생했습니다. 다시 시도해주세요.");
    }
  };

  return (
    <div className="prod-form-section">
      <div className="prod-label-area">스토리 파일</div>
      <div className="prod-input-area">
        <div className="prod-form-group">
          <div className="prod-pdf-area">
            <span className="prod-pdf-notice">(필수)</span>
            <button
              type="button"
              className="prod-file-btn"
              onClick={handlePdfButtonClick}
            >
              파일 선택
            </button>
            <input
              type="file"
              ref={pdfInputRef}
              className="prod-file-input"
              accept=".pdf,.jpg,.jpeg"
              onChange={handlePdfChange}
            />
            {pdfFileName && (
              <span className="prod-file-name">{pdfFileName}</span>
            )}
            <span className="prod-pdf-info">
              허용 형식: PDF 또는 JPG (최대 {MAX_PDF_SIZE_MB}MB, 초과시 자동
              압축)
            </span>
          </div>
          {errors.storyFile && (
            <p className="prod-error-msg">{errors.storyFile.message}</p>
          )}
        </div>
      </div>
    </div>
  );
};

export default StoryFileUploader;
