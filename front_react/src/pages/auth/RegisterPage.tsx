import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import Button from "../../components/common/Button";
import Input from "../../components/common/Input";
import useAuthStore from "../../stores/authStore";

const RegisterPage: React.FC = () => {
  const navigate = useNavigate();
  const { registerSeller, isLoading } = useAuthStore();
  const [formData, setFormData] = useState({
    nickname: "",
    businessNumber: "",
  });
  const [errors, setErrors] = useState<Record<string, string>>({});

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
    if (errors[name]) {
      setErrors((prev) => ({ ...prev, [name]: "" }));
    }
  };

  const validateForm = () => {
    const newErrors: Record<string, string> = {};

    if (!formData.nickname) {
      newErrors.nickname = "닉네임을 입력해주세요";
    }

    if (!formData.businessNumber) {
      newErrors.businessNumber = "사업자 번호를 입력해주세요";
    } else if (!/^\d{10}$/.test(formData.businessNumber)) {
      newErrors.businessNumber =
        "올바른 사업자 번호 형식이 아닙니다 (10자리 숫자)";
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!validateForm()) return;

    try {
      await registerSeller(formData.nickname, formData.businessNumber);
      alert("판매자 등록이 완료되었습니다. 다시 로그인해주세요.");
      navigate("/login");
    } catch (error) {
      setErrors({
        submit: "판매자 등록에 실패했습니다. 다시 시도해주세요.",
      });
    }
  };

  return (
    <div className="min-h-screen bg-[#F7FAFD] flex items-center justify-center px-4 py-8">
      <div className="max-w-md w-full bg-white rounded-2xl shadow-lg p-8">
        <h1 className="text-3xl font-bold text-center mb-8">판매자 등록</h1>

        <form onSubmit={handleSubmit} className="space-y-6">
          <Input
            label="닉네임"
            type="text"
            name="nickname"
            value={formData.nickname}
            onChange={handleChange}
            error={errors.nickname}
            fullWidth
            placeholder="닉네임을 입력해주세요"
          />

          <Input
            label="사업자 번호"
            type="text"
            name="businessNumber"
            value={formData.businessNumber}
            onChange={handleChange}
            error={errors.businessNumber}
            fullWidth
            placeholder="'-' 없이 10자리 숫자로 입력해주세요"
          />

          {errors.submit && (
            <p className="text-red-500 text-sm text-center">{errors.submit}</p>
          )}

          <Button type="submit" fullWidth disabled={isLoading}>
            {isLoading ? "등록 중..." : "판매자 등록"}
          </Button>

          <div className="text-center">
            <button
              type="button"
              onClick={() => navigate("/login")}
              className="text-[#1E3A8A] hover:underline"
            >
              이미 판매자 계정이 있으신가요? 로그인하기
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default RegisterPage;
