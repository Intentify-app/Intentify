async function load(src) {
  return new Promise(resolve => {
    if (document.querySelector(`script[src="${src}"]`)) {
      return resolve();
    }

    const script = document.createElement('script');
    script.src = src;
    script.async = true;
    script.onload = resolve;
    document.head.appendChild(script);
  });
}

/**
 * Render Markdown content as HTML.
 *
 * @image eye
 */
async function main(content) {
  await load('https://cdn.jsdelivr.net/npm/marked@16.4.1/lib/marked.umd.js');
  const html = marked.parse(content);

  return await Intentify.renderUI(
    `
    <style>body { padding: 10px }</style>
    <button onclick='Intentify.returnValue(${JSON.stringify(html)})'>Copy HTML</button><br><br>
    ${html}
    `,
    { title: 'Markdown Preview', width: 640, height: 640 },
  );
}
