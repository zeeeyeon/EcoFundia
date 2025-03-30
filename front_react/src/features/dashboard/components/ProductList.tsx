import React from 'react';
// import { useNavigate } from 'react-router-dom'; // 제거
import { useProductModalStore } from '../../product';
// import useDashboardStore from '../stores/dashboardStore'; // 제거
import '../styles/dashboardComponents.css';

// Product 타입을 store.ts 와 일치하도록 수정
interface Product {
    id: string;
    rank: number; // 순위
    name: string;
    totalFundingAmount: number; // 가격 (총 모금액)
    fundingRate: number; // 총 펀딩률
}

interface ProductListProps {
    products: Product[];
}

// 통화 포맷 함수 (중복될 수 있으므로 shared/utils 등으로 이동 고려)
const formatCurrency = (amount: number): string => {
    return `${amount.toLocaleString()}원`;
};

const ProductList: React.FC<ProductListProps> = ({ products }) => {
    // const navigate = useNavigate();
    const { openModal } = useProductModalStore();
    // 상위 5개 데이터만 사용
    const top5Products = products.slice(0, 5);

    const handleRowClick = (productId: string) => {
        // 유효한 숫자 값으로 변환 시도
        const numericId = Number(productId);

        // 유효성 검사 추가
        if (isNaN(numericId)) {
            console.error('Invalid product ID:', productId);
            return;
        }

        // 유효한 ID로만 모달 열기
        console.log('Opening modal for product ID:', numericId);
        openModal(numericId);
    };

    // formatDate 함수 제거 (endDate 사용 안 함)

    return (
        <table className="product-table" style={{ height: '100%' }}>
            <thead>
                <tr>
                    <th>순위</th>
                    <th>상품명</th>
                    <th>가격(총 모금액)</th>
                    <th>총 펀딩률</th>
                </tr>
            </thead>
            <tbody>
                {top5Products.length > 0 ? (
                    top5Products.map((product) => (
                        <tr key={product.id} onClick={() => handleRowClick(product.id)} className="clickable-row">
                            <td>{product.rank}</td>
                            <td>{product.name}</td>
                            <td>{formatCurrency(product.totalFundingAmount)}</td>
                            <td className="funding-rate-cell">
                                <span className={`rate-value ${product.fundingRate >= 100 ? 'high-rate' : ''}`}>
                                    +{product.fundingRate}%
                                </span>
                            </td>
                        </tr>
                    ))
                ) : (
                    <tr>
                        <td colSpan={4} className="no-products">진행 중인 상품이 없습니다.</td>
                    </tr>
                )}
            </tbody>
        </table>
    );
};

export default ProductList; 