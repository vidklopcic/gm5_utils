extension StringExtension on String {
  String abbr(int? maxLetters) {
    if (maxLetters == null) return this;
    return this
        .split(' ')
        .map((w) => w.length > maxLetters ? w.substring(0, maxLetters) + '.' : w)
        .join(' ');
  }

  String ellipsis(int? maxLen, {String? ellipsis = '...'}) {
    if (maxLen == null || ellipsis == null) return this;
    if (this.length <= maxLen - ellipsis.length) return this;
    return this.substring(0, maxLen - ellipsis.length) + ellipsis;
  }
}
