import React, { useState, useRef, useEffect } from "react";
import { SubmitHandler } from "react-hook-form";
import { LoadingSpinner } from "../../../shared";
import { useProductForm, ProductFormData } from "../hooks/useProductForm";
import { registerProduct } from "../services/productRegistrationApi";
import "../../../shared/styles/common.css";
import "../styles/ProductRegistrationForm.css";

// 분리된 컴포넌트들 임포트
import BasicInfoForm from "./form/BasicInfoForm";
import StoryFileUploader from "./form/StoryFileUploader";
import ImageUploader from "./form/ImageUploader";
import ErrorOverlay from "./form/ErrorOverlay";
import FormButtons from "./form/FormButtons";
import { compressImage, compressStoryFile } from "../utils/FileCompression";

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

  const formRef = useRef<HTMLFormElement>(null);
  const tomorrowDate = getTomorrowDate();

  // 이미지 미리보기를 위한 클린업
  useEffect(() => {
    // data URL은 가비지 컬렉션에 의해 자동으로 정리되므로
    // 별도의 메모리 해제 작업이 필요하지 않습니다
    return () => {};
  }, [imageFiles]);

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

  const handleSubmitForm = () => {
    if (formRef.current) {
      formRef.current.dispatchEvent(
        new Event("submit", { cancelable: true, bubbles: true })
      );
    }
  };

  // 에러 초기화 함수
  const resetError = () => {
    setError(null);
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
          {/* 기본 정보 컴포넌트 */}
          <BasicInfoForm
            register={register}
            errors={errors}
            tomorrowDate={tomorrowDate}
          />

          {/* 스토리 파일 업로드 컴포넌트 */}
          <StoryFileUploader
            errors={errors}
            setValue={setValue}
            pdfFileName={pdfFileName}
            setPdfFileName={setPdfFileName}
            compressStoryFile={compressStoryFile}
          />

          {/* 이미지 업로드 컴포넌트 */}
          <ImageUploader
            errors={errors}
            setValue={setValue}
            imageFiles={imageFiles}
            setImageFiles={setImageFiles}
            compressImage={compressImage}
            setIsLoading={setIsLoading}
          />
        </div>
        {isLoading && <LoadingSpinner />}
      </form>

      {/* 버튼 영역 컴포넌트 */}
      <FormButtons
        isLoading={isLoading}
        handleReset={handleReset}
        handleSubmitForm={handleSubmitForm}
      />

      {/* 에러 오버레이 컴포넌트 */}
      <ErrorOverlay error={error} resetError={resetError} />
    </div>
  );
};

export default ProductRegistrationForm;
