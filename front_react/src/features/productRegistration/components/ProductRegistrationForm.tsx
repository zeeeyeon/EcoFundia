import React, { useState, useRef, useEffect } from "react";
import { SubmitHandler } from "react-hook-form";
import { LoadingSpinner } from "../../../shared";
import {
  useProductForm,
  ProductFormData,
  categoryOptions,
} from "../hooks/useProductForm";
import { registerProduct } from "../services/productRegistrationApi";
import "./ProductRegistrationForm.css";

const ProductRegistrationForm: React.FC = () => {
  const {
    register,
    handleSubmit,
    errors,
    reset,
    prepareFormData,
    setValue,
    getTomorrowDate,
  } = useProductForm();
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [pdfFileName, setPdfFileName] = useState<string>("");
  const [imageFiles, setImageFiles] = useState<
    { file: File; preview: string }[]
  >([]);
  const pdfInputRef = useRef<HTMLInputElement>(null);
  const imageInputRef = useRef<HTMLInputElement>(null);
  const imageDropAreaRef = useRef<HTMLDivElement>(null);
  const formRef = useRef<HTMLFormElement>(null);

  // 최대 파일 크기 상수 (UI 표시용)
  const MAX_PDF_SIZE_MB = 1;
  const MAX_IMAGE_SIZE_MB = 1;

  // 내일 날짜 설정
  const tomorrowDate = getTomorrowDate();

  // useEffect 수정 - data URL을 사용하므로 메모리 해제가 필요 없습니다
  useEffect(() => {
    // data URL은 가비지 컬렉션에 의해 자동으로 정리되므로
    // 별도의 메모리 해제 작업이 필요하지 않습니다
    return () => {};
  }, [imageFiles]);

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

  const onSubmit: SubmitHandler<ProductFormData> = async (
    data: ProductFormData
  ) => {
    setIsLoading(true);
    setError(null);

    try {
      const { dto, storyFile, imageFiles } = prepareFormData(data);

      // 파일 크기 및 형식 로그 출력 (디버깅용)
      if (storyFile) {
        console.log(
          `스토리 파일 타입: ${storyFile.type}, 크기: ${(
            storyFile.size /
            (1024 * 1024)
          ).toFixed(2)}MB`
        );
      }

      if (imageFiles && imageFiles.length > 0) {
        imageFiles.forEach((file, index) => {
          console.log(
            `이미지 ${index + 1} 크기: ${(file.size / (1024 * 1024)).toFixed(
              2
            )}MB`
          );
        });
      }

      const response = await registerProduct(dto, storyFile, imageFiles);

      if (response.status.code === 200) {
        alert("상품이 성공적으로 등록되었습니다!");
        reset(); // 폼 초기화
        setPdfFileName("");
        setImageFiles([]);
      } else {
        setError(response.status.message || "상품 등록에 실패했습니다.");
      }
    } catch (err: unknown) {
      console.error("등록 오류:", err);

      // 413 오류 특별 처리
      if (
        err &&
        typeof err === "object" &&
        "response" in err &&
        err.response &&
        typeof err.response === "object" &&
        "status" in err.response
      ) {
        if (err.response.status === 413) {
          setError(
            "파일 크기가 너무 큽니다. 이미지나 PDF 파일의 크기를 줄여주세요."
          );
          return;
        }
      }

      // 일반적인 에러 메시지 설정
      if (
        err &&
        typeof err === "object" &&
        "message" in err &&
        typeof err.message === "string"
      ) {
        setError(err.message);
      } else {
        setError("상품 등록 중 오류가 발생했습니다.");
      }
    } finally {
      setIsLoading(false);
    }
  };

  const handleReset = () => {
    reset();
    setPdfFileName("");
    setImageFiles([]);
  };

  // 스토리 파일(PDF, JPG) 압축 함수
  const compressStoryFile = async (file: File): Promise<File> => {
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

  // 이미지 압축 함수 수정
  const compressImage = async (
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

  const handlePdfButtonClick = () => {
    pdfInputRef.current?.click();
  };

  const handleImageButtonClick = () => {
    imageInputRef.current?.click();
  };

  const handleSubmitForm = () => {
    if (formRef.current) {
      formRef.current.dispatchEvent(
        new Event("submit", { cancelable: true, bubbles: true })
      );
    }
  };

  return (
    <div className="prod-form-wrapper">
      <form
        ref={formRef}
        onSubmit={handleSubmit(onSubmit)}
        className="prod-registration-form"
      >
        <div className="prod-form-header">기본정보</div>
        <div className="prod-form-container">
          {/* 상품명 */}
          <div className="prod-form-section">
            <div className="prod-label-area">상품명</div>
            <div className="prod-input-area">
              <div className="prod-form-group">
                <input
                  id="title"
                  type="text"
                  className="prod-input-text"
                  placeholder="상품명을 입력하세요 ex) 따뜻한 환경 칫솔"
                  {...register("title")}
                />
                {errors.title && (
                  <p className="prod-error-msg">{errors.title.message}</p>
                )}
              </div>
            </div>
          </div>

          {/* 상품 소개 */}
          <div className="prod-form-section">
            <div className="prod-label-area">상품 소개</div>
            <div className="prod-input-area">
              <div className="prod-form-group">
                <input
                  id="description"
                  type="text"
                  className="prod-input-text"
                  style={{ width: "95%" }}
                  placeholder="ex) 나무로 만든 친환경 칫솔."
                  {...register("description")}
                />
                {errors.description && (
                  <p className="prod-error-msg">{errors.description.message}</p>
                )}
              </div>
            </div>
          </div>

          {/* 카테고리 */}
          <div className="prod-form-section">
            <div className="prod-label-area">카테고리</div>
            <div className="prod-input-area">
              <div className="prod-form-group">
                <div className="prod-category-select">
                  <select
                    id="category"
                    className="prod-select"
                    {...register("category")}
                  >
                    <option value="">카테고리 선택</option>
                    {categoryOptions.map((option) => (
                      <option key={option.value} value={option.value}>
                        {option.label}
                      </option>
                    ))}
                  </select>
                </div>
                {errors.category && (
                  <p className="prod-error-msg">{errors.category.message}</p>
                )}
              </div>
            </div>
          </div>

          {/* 판매 가격 */}
          <div className="prod-form-section">
            <div className="prod-label-area">판매 가격</div>
            <div className="prod-input-area">
              <div className="prod-form-group">
                <div className="prod-price-area">
                  <input
                    id="price"
                    type="number"
                    className="prod-price-input"
                    placeholder="판매 가격을 숫자만 입력해주세요"
                    min="1"
                    {...register("price")}
                  />
                  <span className="prod-unit-label">원</span>
                </div>
                {errors.price && (
                  <p className="prod-error-msg">{errors.price.message}</p>
                )}
              </div>
            </div>
          </div>

          {/* 펀딩 목표 금액 */}
          <div className="prod-form-section">
            <div className="prod-label-area">목표 금액</div>
            <div className="prod-input-area">
              <div className="prod-form-group">
                <div className="prod-target-area">
                  <input
                    id="targetAmount"
                    type="number"
                    className="prod-target-input"
                    placeholder="목표 금액을 숫자만 입력해주세요"
                    min="1"
                    {...register("targetAmount")}
                  />
                  <span className="prod-unit-label">원</span>
                </div>
                {errors.targetAmount && (
                  <p className="prod-error-msg">
                    {errors.targetAmount.message}
                  </p>
                )}
              </div>
            </div>
          </div>

          {/* 펀딩 마감일 */}
          <div className="prod-form-section">
            <div className="prod-label-area">마감일</div>
            <div className="prod-input-area">
              <div className="prod-form-group">
                <div className="prod-date-area">
                  <input
                    id="endDate"
                    type="date"
                    className="prod-input-date"
                    min={tomorrowDate}
                    {...register("endDate")}
                  />
                </div>
                {errors.endDate && (
                  <p className="prod-error-msg">{errors.endDate.message}</p>
                )}
              </div>
            </div>
          </div>

          {/* 스토리 파일 (PDF 또는 JPG) */}
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
                    허용 형식: PDF 또는 JPG (최대 {MAX_PDF_SIZE_MB}MB, 초과시
                    자동 압축)
                  </span>
                </div>
                {errors.storyFile && (
                  <p className="prod-error-msg">{errors.storyFile.message}</p>
                )}
              </div>
            </div>
          </div>

          {/* 이미지 업로드 */}
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
                    * 최대 5개 이미지 업로드 가능 (JPG, PNG, 각{" "}
                    {MAX_IMAGE_SIZE_MB}MB 이하, 초과시 자동 압축)
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
                          <div className="prod-image-name">
                            {item.file.name}
                          </div>
                        </div>
                      ))}
                    </div>
                  )}
                  {errors.imageFiles && (
                    <p className="prod-error-msg">
                      {errors.imageFiles.message}
                    </p>
                  )}
                </div>
              </div>
            </div>
          </div>
          {error && <p className="prod-error-msg prod-form-error">{error}</p>}
        </div>
        {isLoading && <LoadingSpinner />}
      </form>

      {/* 버튼 영역 - 폼 밖으로 이동 */}
      <div className="prod-btn-container">
        <button type="button" className="prod-reset-btn" onClick={handleReset}>
          초기화
        </button>
        <button
          type="button"
          className="prod-submit-btn"
          onClick={handleSubmitForm}
          disabled={isLoading}
        >
          {isLoading ? "등록 중... 파일 업로드 중입니다" : "상품 등록"}
        </button>
      </div>
    </div>
  );
};

export default ProductRegistrationForm;
