(() => {
  const style = document.createElement('style');
  style.textContent = `
    :root {
      color-scheme: light dark;
    }
    body {
      font-family: system-ui;
    }
  `;

  document.head.appendChild(style);
})();

async function __invokeIntentify(message) {
  return await window.webkit.messageHandlers.bridge.postMessage(message);
}

async function askAI(prompt) {
  return await __invokeIntentify({
    command: 'askAI',
    parameters: { prompt },
  });
}

async function renderUI(html, options) {
  return await __invokeIntentify({
    command: 'renderUI',
    parameters: { html, options },
  });
}

async function returnValue(value) {
  return await __invokeIntentify({
    command: 'returnValue',
    parameters: { value },
  });
}

async function runService(name, input) {
  return await __invokeIntentify({
    command: 'runService',
    parameters: { name, input },
  });
}

window.Intentify = { askAI, renderUI, returnValue, runService };
