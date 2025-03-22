import 'package:flutter/material.dart';

/// 별점을 표시하는 위젯
///
/// 별점 (1-5)를 표시하고, 선택적으로 사용자 상호작용을 지원합니다.
class StarRating extends StatelessWidget {
  final double rating; // 별점 (1-5)
  final double size; // 별 크기
  final Color? activeColor; // 활성화된 별 색상
  final Color? inactiveColor; // 비활성화된 별 색상
  final MainAxisAlignment alignment; // 정렬 방향
  final double spacing; // 별 사이 간격
  final ValueChanged<double>? onRatingChanged; // 별점 변경 콜백

  const StarRating({
    Key? key,
    required this.rating,
    this.size = 20.0,
    this.activeColor,
    this.inactiveColor,
    this.alignment = MainAxisAlignment.start,
    this.spacing = 2.0,
    this.onRatingChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: alignment,
      children: List.generate(5, (index) {
        // 별의 채워진 정도를 계산 (0.0 ~ 1.0)
        final isFilled = index < rating.floor();
        final isHalfFilled = !isFilled && (index == rating.floor());

        return GestureDetector(
          onTap: onRatingChanged != null
              ? () => onRatingChanged?.call((index + 1).toDouble())
              : null,
          child: Padding(
            padding: EdgeInsets.only(right: index < 4 ? spacing : 0),
            child: Icon(
              isFilled
                  ? Icons.star
                  : isHalfFilled
                      ? Icons.star_half
                      : Icons.star_border,
              size: size,
              color: isFilled || isHalfFilled
                  ? (activeColor ?? Colors.amber)
                  : (inactiveColor ?? Colors.grey.shade300),
            ),
          ),
        );
      }),
    );
  }
}
