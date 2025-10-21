// @ts-check
/// <reference path='../Intentify.d.ts' />

/**
 * @param {string} src
 */
async function load(src) {
  return new Promise(resolve => {
    if (document.querySelector(`script[src="${src}"]`)) {
      return resolve(undefined);
    }

    const script = document.createElement('script');
    script.src = src;
    script.async = true;
    script.onload = resolve;
    document.head.appendChild(script);
  });
}

/**
 * Render Mermaid diagrams as HTML.
 *
 * @image fish
 * @param {string} content
 */
async function main(content) {
  await load('https://cdn.jsdelivr.net/npm/mermaid@11.12.0/dist/mermaid.min.js');

  const isDark = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
  const theme = isDark ? 'dark' : 'default';

  // @ts-ignore
  const { initialize, render } = mermaid;
  initialize({ theme, startOnLoad: false });

  const { svg: html } = await render('graph', content);
  return await Intentify.renderUI(
    `
    <style>body { padding: 10px }</style>
    <button onclick='Intentify.returnValue(${JSON.stringify(html)})'>Copy HTML</button><br><br>
    ${html}
    `,
    { title: 'Mermaid Preview', width: 640, height: 640 },
  );
}
