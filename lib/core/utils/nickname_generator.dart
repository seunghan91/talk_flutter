import 'dart:math';

/// 형용사 + 동물 조합으로 랜덤 닉네임 생성
class NicknameGenerator {
  NicknameGenerator._();

  static final _random = Random();

  static const _adjectives = [
    '행복한', '즐거운', '멋진', '신나는', '귀여운',
    '활발한', '친절한', '사랑스러운', '따뜻한', '밝은',
    '지혜로운', '용감한', '재미있는', '흥미로운', '창의적인',
    '열정적인', '정직한', '쾌활한', '다정한', '씩씩한',
    '상냥한', '유쾌한', '느긋한', '섬세한', '엉뚱한',
  ];

  static const _animals = [
    '강아지', '고양이', '토끼', '사자', '호랑이',
    '코끼리', '판다', '곰', '여우', '늑대',
    '독수리', '참새', '햄스터', '다람쥐', '고래',
    '돌고래', '거북이', '원숭이', '얼룩말', '캥거루',
    '펭귄', '코알라', '수달', '미어캣', '라쿤',
  ];

  /// 형용사 + 동물 닉네임 생성 (예: 행복한고양이)
  static String generate() {
    final adjective = _adjectives[_random.nextInt(_adjectives.length)];
    final animal = _animals[_random.nextInt(_animals.length)];
    return '$adjective$animal';
  }
}
