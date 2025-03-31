import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/features/mypage/ui/view_model/profile_view_model.dart';
import 'package:go_router/go_router.dart';

class ProfileEditForm extends ConsumerStatefulWidget {
  const ProfileEditForm({super.key});

  @override
  ConsumerState<ProfileEditForm> createState() => _ProfileEditFormState();
}

class _ProfileEditFormState extends ConsumerState<ProfileEditForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider).maybeWhen(
          data: (p) => p,
          orElse: () => null,
        );
    if (profile != null) {
      _nicknameController.text = profile.nickname;
      _accountController.text = profile.account;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);

    return profileState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('오류 발생: $err')),
      data: (profile) => Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text("닉네임", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nicknameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '닉네임을 입력하세요',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '닉네임을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text("계좌", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _accountController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '계좌번호를 입력하세요',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '계좌번호를 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildReadOnlyField(label: "이메일", value: profile.email),
              _buildReadOnlyField(label: "이름", value: profile.name),
              _buildReadOnlyField(label: "성별", value: profile.gender),
              _buildReadOnlyField(label: "나이", value: profile.age.toString()),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final nickname = _nicknameController.text.trim();
                    final account = _accountController.text.trim();

                    await ref
                        .read(profileProvider.notifier)
                        .updateProfile(nickname: nickname, account: account);

                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('프로필이 저장되었습니다')),
                    );
                    context.go('/mypage'); // 마이페이지 경로로 이동
                  }
                },
                child: const Text("저장"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: value,
            readOnly: true,
            style: const TextStyle(color: Colors.grey),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
