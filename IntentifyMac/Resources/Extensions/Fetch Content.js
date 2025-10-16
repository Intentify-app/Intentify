/**
 * Fetch content from a URL.
 *
 * @image arrow.down.circle
 */
async function main(url) {
  const response = await fetch(url);
  const result = await response.text();
  return result;
}
