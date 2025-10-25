/**
 * Search Apple developer documentation.
 *
 * @image text.page
 * @avoidCopy true
 */
function main(keyword) {
  const url = (() => {
    if (keyword.length > 0) {
      return `https://developer.apple.com/search/?q=${encodeURIComponent(keyword)}&type=documentation`;
    } else {
      return 'https://developer.apple.com/documentation/';
    }
  })();

  open(url);
  return url;
}
