/// String Extensions
extension StringX on String {
  bool get isBlank => trim().isEmpty;
  bool get isNotBlank => !isBlank;

  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  String truncate(int maxLength, {String ellipsis = '...'}) =>
      length <= maxLength ? this : '${substring(0, maxLength)}$ellipsis';

  bool get isValidPhoneNumber =>
      RegExp(r'^01[0-9]{8,9}$').hasMatch(replaceAll('-', ''));

  bool get isValidVerificationCode => RegExp(r'^\d{6}$').hasMatch(this);

  String get maskedPhoneNumber {
    final cleaned = replaceAll('-', '');
    if (cleaned.length != 11) return this;
    return '${cleaned.substring(0, 3)}-****-${cleaned.substring(7)}';
  }
}

/// Nullable String Extensions
extension NullableStringX on String? {
  bool get isNullOrBlank => this?.trim().isEmpty ?? true;
  bool get isNotNullOrBlank => !isNullOrBlank;
}

/// DateTime Extensions
extension DateTimeX on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  String timeAgo({DateTime? reference}) {
    final now = reference ?? DateTime.now();
    final difference = now.difference(this);

    if (difference.inSeconds < 60) return '방금 전';
    if (difference.inMinutes < 60) return '${difference.inMinutes}분 전';
    if (difference.inHours < 24) return '${difference.inHours}시간 전';
    if (difference.inDays < 7) return '${difference.inDays}일 전';
    if (difference.inDays < 30) return '${(difference.inDays / 7).floor()}주 전';
    if (difference.inDays < 365) return '${(difference.inDays / 30).floor()}개월 전';
    return '${(difference.inDays / 365).floor()}년 전';
  }

  String formatTime() {
    final hour = this.hour.toString().padLeft(2, '0');
    final minute = this.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String formatDate() {
    return '$year.${month.toString().padLeft(2, '0')}.${day.toString().padLeft(2, '0')}';
  }

  String formatDateTime() => '${formatDate()} ${formatTime()}';
}

/// Duration Extensions
extension DurationX on Duration {
  String formatMMSS() {
    final minutes = inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String formatVoiceDuration() {
    if (inSeconds < 60) return '$inSeconds초';
    return '$inMinutes분 ${inSeconds.remainder(60)}초';
  }
}

/// List Extensions
extension ListX<T> on List<T> {
  List<T> removeDuplicates() => toSet().toList();

  List<T> distinctBy<K>(K Function(T) selector) {
    final seen = <K>{};
    return where((item) => seen.add(selector(item))).toList();
  }

  T? firstWhereOrNull(bool Function(T) predicate) {
    for (final item in this) {
      if (predicate(item)) return item;
    }
    return null;
  }

  T? get firstOrNull => isEmpty ? null : first;
  T? get lastOrNull => isEmpty ? null : last;
}

/// Map Extensions
extension MapX<K, V> on Map<K, V> {
  Map<K, V> removeNullValues() {
    return Map.fromEntries(
      entries.where((e) => e.value != null),
    );
  }
}

/// Int Extensions (for audio duration)
extension IntX on int {
  String formatAsVoiceDuration() {
    final duration = Duration(seconds: this);
    return duration.formatVoiceDuration();
  }
}
