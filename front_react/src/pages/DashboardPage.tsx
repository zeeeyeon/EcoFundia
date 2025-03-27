import React from 'react';

const DashboardPage: React.FC = () => {
    return (
        <div className="min-h-screen bg-gradient-to-br from-green-50 via-gray-50 to-blue-50 dark:from-gray-900 dark:via-gray-800 dark:to-gray-900 flex items-center justify-center p-4">
            <div className="max-w-md w-full bg-white/80 dark:bg-gray-800/80 backdrop-blur-sm rounded-2xl shadow-xl p-8">
                <h1 className="text-3xl font-bold text-gray-900 dark:text-white mb-6">대시보드</h1>
                <p className="text-gray-600 dark:text-gray-300 mb-8">
                    대시보드 페이지는 현재 개발 중입니다.
                </p>
            </div>
        </div>
    );
};

export default DashboardPage; 