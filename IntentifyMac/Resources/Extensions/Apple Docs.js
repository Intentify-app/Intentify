/**
 * Search Apple developer documentation.
 *
 * @image text.page
 */
function main(keyword) {
  if (keyword.length > 0) {
    open(`https://developer.apple.com/search/?q=${encodeURIComponent(keyword)}&type=documentation`);
  } else {
    open('https://developer.apple.com/documentation/');
  }

  return '';
}
