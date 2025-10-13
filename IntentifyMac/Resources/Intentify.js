const bridge = window.webkit.messageHandlers.bridge;

async function askAI(prompt) {
  return await bridge.postMessage({
    command: 'askAI',
    parameters: { prompt },
  });
}

window.Intentify = { askAI };
