import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import Leaf from '../assets/Leaf.svg';
import './sellerRegistration.css';

const SellerRegistration: React.FC = () => {
    const navigate = useNavigate();
    const [formData, setFormData] = useState({
        businessName: '',
        businessNumber: '',
    });
    const [isLoading, setIsLoading] = useState(false);
    const [error, setError] = useState<string | null>(null);
    const [agreed, setAgreed] = useState(false);

    const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        const { name, value } = e.target;
        setFormData(prev => ({
            ...prev,
            [name]: value
        }));
    };

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        if (!agreed) {
            setError('판매자 이용약관에 동의해주세요.');
            return;
        }
        setIsLoading(true);
        setError(null);

        try {
            // API 호출 로직 구현 예정
            await new Promise(resolve => setTimeout(resolve, 1000)); // 임시 딜레이
            navigate('/dashboard');
        } catch (err) {
            setError('등록 중 오류가 발생했습니다. 다시 시도해주세요.');
        } finally {
            setIsLoading(false);
        }
    };

    return (
        <div className="registration-page">
            <div className="registration-card">
                <div className="leaf-icon">
                    <img src={Leaf} alt="Eco Leaf" className="leaf-image" />
                </div>

                <h1 className="title">판매자 등록</h1>
                <p className="description">
                    에코펀딩에서 판매자가 되어 친환경 제품을 소개해보세요
                </p>

                <form onSubmit={handleSubmit} className="registration-form">
                    <div className="form-group">
                        <label htmlFor="businessName">상호명</label>
                        <input
                            type="text"
                            id="businessName"
                            name="businessName"
                            value={formData.businessName}
                            onChange={handleChange}
                            placeholder="사업자등록증의 상호명을 입력하세요"
                            required
                        />
                    </div>

                    <div className="form-group">
                        <label htmlFor="businessNumber">사업자 등록번호</label>
                        <input
                            type="text"
                            id="businessNumber"
                            name="businessNumber"
                            value={formData.businessNumber}
                            onChange={handleChange}
                            placeholder="000-00-00000"
                            required
                        />
                    </div>

                    <div className="warning-box">
                        <h3>판매자 주의사항</h3>
                        <ul>
                            <li>허위 상품 등록 시 즉시 판매자 자격이 박탈됩니다.</li>
                            <li>등록된 정보가 사실과 다를 경우 법적 책임이 따를 수 있습니다.</li>
                            <li>친환경 제품 인증서를 반드시 첨부해야 합니다.</li>
                        </ul>
                    </div>

                    <div className="agreement-box">
                        <label className="checkbox-label">
                            <input
                                type="checkbox"
                                checked={agreed}
                                onChange={(e) => setAgreed(e.target.checked)}
                            />
                            <span>위 주의사항을 모두 확인했으며, 이에 동의합니다.</span>
                        </label>
                    </div>

                    {error && <div className="error-message">{error}</div>}

                    <button
                        type="submit"
                        className="submit-button"
                        disabled={isLoading || !agreed}
                    >
                        {isLoading ? (
                            <span className="button-loading"></span>
                        ) : '등록하기'}
                    </button>
                </form>
            </div>
        </div>
    );
};

export default SellerRegistration; 