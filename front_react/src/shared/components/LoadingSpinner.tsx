import React from 'react';
import './LoadingSpinner.css';

interface LoadingSpinnerProps {
    /**
     * 스피너 크기
     * @default 'medium'
     */
    size?: 'small' | 'medium' | 'large';
    /**
     * 표시할 로딩 메시지
     * @default '로딩 중...'
     */
    message?: string;
    /**
     * 전체 화면 배경으로 표시 여부
     * @default false
     */
    fullscreen?: boolean;
}

/**
 * 애플리케이션 전체에서 사용할 공통 로딩 스피너 컴포넌트
 */
const LoadingSpinner: React.FC<LoadingSpinnerProps> = ({
    size = 'medium',
    message = '로딩 중...',
    fullscreen = false
}) => {
    const spinnerClassName = `spinner-container ${fullscreen ? 'fullscreen' : ''} ${size}`;

    return (
        <div className={spinnerClassName}>
            <div className={`spinner ${size}`}></div>
            {message && <p className={`spinner-text ${size}`}>{message}</p>}
        </div>
    );
};

export default LoadingSpinner; 