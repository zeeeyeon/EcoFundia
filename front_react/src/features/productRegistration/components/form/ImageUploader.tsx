import React, { useRef, useEffect } from "react";
import { UseFormSetValue, FieldErrors } from "react-hook-form";
import { ProductFormData } from "../../hooks/useProductForm";
import "../../styles/ProductRegistrationForm.css";

interface ImageUploaderProps {
  errors: FieldErrors<ProductFormData>;
  setValue: UseFormSetValue<ProductFormData>;
  imageFiles: { file: File; preview: string }[];
  setImageFiles: React.Dispatch<
    React.SetStateAction<{ file: File; preview: string }[]>
  >;
  compressImage: (file: File, maxSizeMB?: number) => Promise<File>;
  setIsLoading: React.Dispatch<React.SetStateAction<boolean>>;
}

const ImageUploader: React.FC<ImageUploaderProps> = ({
  errors,
  setValue,
  imageFiles,
  setImageFiles,
  compressImage,
  setIsLoading,
}) => {
  const imageInputRef = useRef<HTMLInputElement>(null);
  const imageDropAreaRef = useRef<HTMLDivElement>(null);
  const MAX_IMAGE_SIZE_MB = 1; // 최대 이미지 크기 상수

  // 드래그 앤 드롭 이벤트 처리
  useEffect(() => {
    const dropArea = imageDropAreaRef.current;
    if (!dropArea) return;

    const preventDefault = (e: Event) => {
      e.preventDefault();
      e.stopPropagation();
    };

    const handleDragOver = (e: DragEvent) => {
      preventDefault(e);
      if (dropArea.classList) {
        dropArea.classList.add("dragover");
      }
    };

    const handleDragLeave = (e: DragEvent) => {
      preventDefault(e);
      if (dropArea.classList) {
        dropArea.classList.remove("dragover");
      }
    };

    const handleDrop = (e: DragEvent) => {
      preventDefault(e);
      if (dropArea.classList) {
        dropArea.classList.remove("dragover");
      }

      if (e.dataTransfer?.files) {
        handleImageFilesSelected(e.dataTransfer.files);
      }
    };

    dropArea.addEventListener("dragover", handleDragOver);
    dropArea.addEventListener("dragleave", handleDragLeave);
    dropArea.addEventListener("drop", handleDrop);

    return () => {
      dropArea.removeEventListener("dragover", handleDragOver);
      dropArea.removeEventListener("dragleave", handleDragLeave);
      dropArea.removeEventListener("drop", handleDrop);
    };
  }, []);

  const handleImageFilesSelected = async (files: FileList) => {
    if (files && files.length > 0) {
      // 기존 이미지와 새 이미지 합쳐서 최대 5개까지만 허용
      const currentCount = imageFiles.length;
      const newFilesToAdd = Math.min(files.length, 5 - currentCount);

      if (newFilesToAdd <= 0) {
        alert("이미지는 최대 5개까지만 등록 가능합니다.");
        return;
      }

      // 로딩 상태 설정
      setIsLoading(true);

      try {
        // 비동기 처리를 위한 배열
        const fileReadPromises: Promise<{ file: File; preview: string }>[] = [];

        // 각 파일을 압축하고 data URL로 읽기
        for (let i = 0; i < newFilesToAdd; i++) {
          const file = files[i];

          // 이미지 형식 확인
          if (!file.type.startsWith("image/")) {
            alert(
              `${file.name}은(는) 이미지 파일이 아닙니다. 이미지 파일만 업로드해주세요.`
            );
            continue;
          }

          let processedFile = file;
          // 파일 크기가 제한을 초과하는 경우 압축
          if (file.size > MAX_IMAGE_SIZE_MB * 1024 * 1024) {
            console.log(
              `이미지 ${file.name}이(가) ${MAX_IMAGE_SIZE_MB}MB를 초과하여 압축을 시도합니다.`
            );
            processedFile = await compressImage(file);

            // 압축 후에도 크기가 크면 알림
            if (processedFile.size > MAX_IMAGE_SIZE_MB * 1024 * 1024) {
              alert(
                `${file.name} 이미지를 압축했으나 여전히 ${MAX_IMAGE_SIZE_MB}MB를 초과합니다. 더 작은 이미지를 사용해주세요.`
              );
              continue;
            }
          }

          const promise = new Promise<{ file: File; preview: string }>(
            (resolve) => {
              const reader = new FileReader();
              reader.onload = (e) => {
                resolve({
                  file: processedFile,
                  preview: (e.target?.result as string) || "",
                });
              };
              reader.readAsDataURL(processedFile);
            }
          );
          fileReadPromises.push(promise);
        }

        // 모든 파일이 읽히면 상태 업데이트
        const newFileObjects = await Promise.all(fileReadPromises);

        // 파일이 하나도 추가되지 않았다면 처리 중단
        if (newFileObjects.length === 0) {
          setIsLoading(false);
          return;
        }

        const newFiles = [...imageFiles, ...newFileObjects];
        setImageFiles(newFiles);

        // FileList 객체 생성
        const dataTransfer = new DataTransfer();
        newFiles.forEach((item) => dataTransfer.items.add(item.file));
        setValue("imageFiles", dataTransfer.files);
      } catch (err) {
        console.error("이미지 처리 중 오류 발생:", err);
        alert("이미지 처리 중 오류가 발생했습니다.");
      } finally {
        setIsLoading(false);
      }
    }
  };

  const handleImageChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files) {
      handleImageFilesSelected(e.target.files);
    }
  };

  const handleImageDelete = (index: number) => {
    // 이미지 목록에서 해당 인덱스 제거
    const updatedFiles = imageFiles.filter((_, i) => i !== index);
    setImageFiles(updatedFiles);

    // 변경된 이미지 목록으로 새 FileList 생성
    const dataTransfer = new DataTransfer();
    updatedFiles.forEach((item) => dataTransfer.items.add(item.file));
    setValue("imageFiles", dataTransfer.files);
  };

  const handleImageButtonClick = () => {
    imageInputRef.current?.click();
  };

  return (
    <div className="prod-form-section">
      <div className="prod-label-area">이미지</div>
      <div className="prod-input-area">
        <div className="prod-form-group">
          <div className="prod-image-area">
            <div
              className="prod-image-upload"
              ref={imageDropAreaRef}
              onClick={handleImageButtonClick}
            >
              <span className="prod-upload-icon">+</span>
              <div className="prod-drag-text">
                파일을 드래그하여 업로드하거나 클릭하여 파일을 선택하세요
              </div>
              <input
                type="file"
                multiple
                ref={imageInputRef}
                className="prod-file-input"
                accept="image/jpeg, image/png"
                onChange={handleImageChange}
              />
            </div>
            <div className="prod-image-info">
              * 최대 5개 이미지 업로드 가능 (JPG, PNG, 각 {MAX_IMAGE_SIZE_MB}MB
              이하, 초과시 자동 압축)
            </div>
            {imageFiles.length > 0 && (
              <div className="prod-previews">
                {imageFiles.map((item, index) => (
                  <div className="prod-preview-item" key={index}>
                    <img
                      src={item.preview}
                      alt={`preview-${index}`}
                      className="prod-preview-img"
                    />
                    <div className="prod-image-actions">
                      <button
                        type="button"
                        className="prod-delete-btn"
                        onClick={() => handleImageDelete(index)}
                      >
                        ✕
                      </button>
                    </div>
                    <div className="prod-image-name">{item.file.name}</div>
                  </div>
                ))}
              </div>
            )}
            {errors.imageFiles && (
              <p className="prod-error-msg">{errors.imageFiles.message}</p>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default ImageUploader;
