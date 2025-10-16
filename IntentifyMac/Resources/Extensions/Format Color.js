/**
 * Convert between RGB and HEX color formats.
 *
 * @image textformat
 */
function main(input) {
  const color = input.trim();
  const regexHex = /^#?([A-Fa-f0-9]{3}|[A-Fa-f0-9]{6})$/;
  const regexRGB = /^rgb\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*\)$/i;

  if (regexHex.test(color)) {
    let [_, hex] = color.match(regexHex) || [];
    if (hex.length === 3) hex = hex.split('').map(c => c + c).join('');
    const [r, g, b] = [0, 2, 4].map(i => parseInt(hex.slice(i, i + 2), 16));
    return `rgb(${r}, ${g}, ${b})`;
  }

  if (regexRGB.test(color)) {
    const clamp = (value) => Math.max(0, Math.min(255, Number(value) || 0));
    const parts = (color.match(regexRGB)?.slice(1, 4) || []).map(clamp);
    return `#${parts.map(n => n.toString(16).padStart(2, '0')).join('')}`;
  }

  return undefined;
}
