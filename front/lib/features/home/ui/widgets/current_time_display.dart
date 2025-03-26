import 'dart:async';
import 'package:flutter/material.dart';
import 'package:front/core/constants/app_sizes.dart';
import 'package:front/core/themes/app_colors.dart';
import 'package:front/core/themes/app_text_styles.dart';
import 'package:intl/intl.dart';

/// 현재 시간을 표시하는 위젯
class CurrentTimeDisplay extends StatefulWidget {
  const CurrentTimeDisplay({Key? key}) : super(key: key);

  @override
  State<CurrentTimeDisplay> createState() => _CurrentTimeDisplayState();
}

class _CurrentTimeDisplayState extends State<CurrentTimeDisplay> {
  late Timer _timer;
  late String _currentTime;
  final DateFormat _timeFormat = DateFormat('HH:mm:ss');

  @override
  void initState() {
    super.initState();
    _updateTime();

    // 1초마다 시간 업데이트
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTime();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  /// 현재 시간 업데이트
  void _updateTime() {
    if (!mounted) return;

    setState(() {
      _currentTime = _timeFormat.format(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingXS),
      child: Text(
        _currentTime,
        style: AppTextStyles.body1.copyWith(
          color: AppColors.grey,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
