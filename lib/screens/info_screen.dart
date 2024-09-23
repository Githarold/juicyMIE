import 'package:flutter/material.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('정보'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              '휴대용 3D 프린터 앱',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              '이 앱은 3D 프린터를 제어하고 관리하기 위한 앱입니다. '
              'G-code 파일을 관리하고, 프린터의 상태를 모니터링하며, '
              '프린터 설정을 조정할 수 있습니다.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              '개발자: 이승헌',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              '버그 리포트: harold3312@naver.com',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              '앱 버전: 1.0.0',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              '라이선스 정보:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '이 앱은 오픈 소스 라이선스를 따릅니다. 자세한 내용은 앱 내 라이선스 정보를 참조하세요.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
