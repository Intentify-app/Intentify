async function main(url) {
  const response = await fetch(url);
  const result = await response.text();
  return result;
}
