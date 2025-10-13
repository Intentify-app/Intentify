function main(url) {
  if (url.length > 0) {
    open(url.startsWith('http') ? url : `https://${url}`);
  }

  return url;
}
