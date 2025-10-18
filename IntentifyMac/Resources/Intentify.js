async function __invokeIntentify(message) {
  return await window.webkit.messageHandlers.bridge.postMessage(message);
}

async function askAI(prompt) {
  return await __invokeIntentify({
    command: 'askAI',
    parameters: { prompt },
  });
}

window.Intentify = { askAI };
