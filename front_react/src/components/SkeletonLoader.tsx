import React from 'react';

const SkeletonLoader: React.FC = () => {
    return (
        <div className="animate-pulse space-y-12 py-12 px-8">
            <div className="space-y-6">
                {/* 로고 스켈레톤 */}
                <div className="h-20 w-48 bg-gray-200 dark:bg-gray-700 rounded-lg mx-auto" />
                {/* 텍스트 스켈레톤 */}
                <div className="space-y-2">
                    <div className="h-4 w-3/4 bg-gray-200 dark:bg-gray-700 rounded mx-auto" />
                    <div className="h-4 w-1/2 bg-gray-200 dark:bg-gray-700 rounded mx-auto" />
                </div>
            </div>
            {/* 버튼 스켈레톤 */}
            <div className="h-12 w-full bg-gray-200 dark:bg-gray-700 rounded-xl" />
        </div>
    );
};

export default SkeletonLoader; 