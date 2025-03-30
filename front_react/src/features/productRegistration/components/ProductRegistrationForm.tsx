import React, { useState, useRef, useEffect } from 'react';
import { SubmitHandler } from 'react-hook-form';
import { LoadingSpinner } from '../../../shared';
import { useProductForm, ProductFormData, categoryOptions } from '../hooks/useProductForm';
import { registerProduct } from '../services/productRegistrationApi';
import './ProductRegistrationForm.css';

const ProductRegistrationForm: React.FC = () => {
    const { register, handleSubmit, errors, reset, prepareFormData, setValue } = useProductForm();
    const [isLoading, setIsLoading] = useState(false);
    const [error, setError] = useState<string | null>(null);
    const [pdfFileName, setPdfFileName] = useState<string>('');
    const [imageFiles, setImageFiles] = useState<{ file: File, preview: string }[]>([]);
    const pdfInputRef = useRef<HTMLInputElement>(null);
    const imageInputRef = useRef<HTMLInputElement>(null);
    const imageDropAreaRef = useRef<HTMLDivElement>(null);
    const formRef = useRef<HTMLFormElement>(null);

    // 컴포넌트 언마운트 시 Object URL 메모리 해제
    useEffect(() => {
        return () => {
            imageFiles.forEach(item => URL.revokeObjectURL(item.preview));
        };
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
                dropArea.classList.add('dragover');
            }
        };

        const handleDragLeave = (e: DragEvent) => {
            preventDefault(e);
            if (dropArea.classList) {
                dropArea.classList.remove('dragover');
            }
        };

        const handleDrop = (e: DragEvent) => {
            preventDefault(e);
            if (dropArea.classList) {
                dropArea.classList.remove('dragover');
            }

            if (e.dataTransfer?.files) {
                handleImageFilesSelected(e.dataTransfer.files);
            }
        };

        dropArea.addEventListener('dragover', handleDragOver);
        dropArea.addEventListener('dragleave', handleDragLeave);
        dropArea.addEventListener('drop', handleDrop);

        return () => {
            dropArea.removeEventListener('dragover', handleDragOver);
            dropArea.removeEventListener('dragleave', handleDragLeave);
            dropArea.removeEventListener('drop', handleDrop);
        };
    }, []);

    const onSubmit: SubmitHandler<ProductFormData> = async (data: ProductFormData) => {
        setIsLoading(true);
        setError(null);

        const { dto, storyFile, imageFiles } = prepareFormData(data);

        try {
            const response = await registerProduct(dto, storyFile, imageFiles);

            if (response.status.code === 200) {
                alert('상품이 성공적으로 등록되었습니다!');
                reset(); // 폼 초기화
                setPdfFileName('');
                setImageFiles([]);
            } else {
                setError(response.status.message);
            }
        } catch (err) {
            setError('상품 등록 중 오류가 발생했습니다.');
            console.error('등록 오류:', err);
        } finally {
            setIsLoading(false);
        }
    };

    const handleReset = () => {
        reset();
        setPdfFileName('');
        setImageFiles([]);
    };

    const handlePdfChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        const file = e.target.files?.[0];
        if (file) {
            setPdfFileName(file.name);
            setValue('storyFile', e.target.files as FileList);
        }
    };

    const handleImageFilesSelected = (files: FileList) => {
        if (files && files.length > 0) {
            // 기존 이미지와 새 이미지 합쳐서 최대 5개까지만 허용
            const currentCount = imageFiles.length;
            const newFilesToAdd = Math.min(files.length, 5 - currentCount);

            if (newFilesToAdd <= 0) {
                alert('이미지는 최대 5개까지만 등록 가능합니다.');
                return;
            }

            const newFiles = [...imageFiles];

            for (let i = 0; i < newFilesToAdd; i++) {
                const file = files[i];
                const preview = URL.createObjectURL(file);
                newFiles.push({ file, preview });
            }

            setImageFiles(newFiles);

            // FileList 객체 생성 (이미지 삭제 등으로 변경된 경우에도 적용)
            const dataTransfer = new DataTransfer();
            newFiles.forEach(item => dataTransfer.items.add(item.file));
            setValue('imageFiles', dataTransfer.files);
        }
    };

    const handleImageChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        if (e.target.files) {
            handleImageFilesSelected(e.target.files);
        }
    };

    const handleImageDelete = (index: number) => {
        // 삭제할 이미지의 URL 해제
        URL.revokeObjectURL(imageFiles[index].preview);

        // 이미지 목록에서 해당 인덱스 제거
        const updatedFiles = imageFiles.filter((_, i) => i !== index);
        setImageFiles(updatedFiles);

        // 변경된 이미지 목록으로 새 FileList 생성
        const dataTransfer = new DataTransfer();
        updatedFiles.forEach(item => dataTransfer.items.add(item.file));
        setValue('imageFiles', dataTransfer.files);
    };

    const handlePdfButtonClick = () => {
        pdfInputRef.current?.click();
    };

    const handleImageButtonClick = () => {
        imageInputRef.current?.click();
    };

    const handleSubmitForm = () => {
        if (formRef.current) {
            formRef.current.dispatchEvent(new Event('submit', { cancelable: true, bubbles: true }));
        }
    };

    return (
        <div className="prod-form-wrapper">
            <form ref={formRef} onSubmit={handleSubmit(onSubmit)} className="prod-registration-form">
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
                                    {...register('title')}
                                />
                                {errors.title && <p className="prod-error-msg">{errors.title.message}</p>}
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
                                    style={{ width: '95%' }}
                                    placeholder="ex) 나무로 만든 친환경 칫솔."
                                    {...register('description')}
                                />
                                {errors.description && <p className="prod-error-msg">{errors.description.message}</p>}
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
                                        {...register('category')}
                                    >
                                        <option value="">카테고리 선택</option>
                                        {categoryOptions.map(option => (
                                            <option key={option.value} value={option.value}>
                                                {option.label}
                                            </option>
                                        ))}
                                    </select>
                                </div>
                                {errors.category && <p className="prod-error-msg">{errors.category.message}</p>}
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
                                        {...register('price')}
                                    />
                                    <span className="prod-unit-label">원</span>
                                </div>
                                {errors.price && <p className="prod-error-msg">{errors.price.message}</p>}
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
                                        {...register('targetAmount')}
                                    />
                                    <span className="prod-unit-label">원</span>
                                </div>
                                {errors.targetAmount && <p className="prod-error-msg">{errors.targetAmount.message}</p>}
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
                                        {...register('endDate')}
                                    />
                                </div>
                                {errors.endDate && <p className="prod-error-msg">{errors.endDate.message}</p>}
                            </div>
                        </div>
                    </div>

                    {/* 스토리 파일 (PDF) */}
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
                                        accept=".pdf"
                                        onChange={handlePdfChange}
                                    />
                                    {pdfFileName && <span className="prod-file-name">{pdfFileName}</span>}
                                    <span className="prod-pdf-info">허용 형식: PDF (최대 10MB)</span>
                                </div>
                                {errors.storyFile && <p className="prod-error-msg">{errors.storyFile.message}</p>}
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
                                        * 최대 5개 이미지 업로드 가능 (JPG, PNG)
                                    </div>
                                    {imageFiles.length > 0 && (
                                        <div className="prod-previews">
                                            {imageFiles.map((item, index) => (
                                                <div className="prod-preview-item" key={index}>
                                                    <img src={item.preview} alt={`preview-${index}`} className="prod-preview-img" />
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
                                    {errors.imageFiles && <p className="prod-error-msg">{errors.imageFiles.message}</p>}
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
                <button type="button" className="prod-submit-btn" onClick={handleSubmitForm} disabled={isLoading}>
                    {isLoading ? '등록 중...' : '상품 등록'}
                </button>
            </div>
        </div>
    );
};

export default ProductRegistrationForm; 