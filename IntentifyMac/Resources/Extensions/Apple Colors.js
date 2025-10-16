/**
 * Search Apple system colors.
 *
 * @image paintpalette
 */
function main(query) {
  const colors = [
    ['Red (Light)', '#FF383C'],
    ['Red (Dark)', '#FF4245'],
    ['Orange (Light)', '#FF8D28'],
    ['Orange (Dark)', '#FF9230'],
    ['Yellow (Light)', '#FFCC00'],
    ['Yellow (Dark)', '#FFD600'],
    ['Green (Light)', '#34C759'],
    ['Green (Dark)', '#30D158'],
    ['Mint (Light)', '#00C8B3'],
    ['Mint (Dark)', '#00DAC3'],
    ['Teal (Light)', '#00C3D0'],
    ['Teal (Dark)', '#00D2E0'],
    ['Cyan (Light)', '#00C0E8'],
    ['Cyan (Dark)', '#3CD3FE'],
    ['Blue (Light)', '#0088FF'],
    ['Blue (Dark)', '#0091FF'],
    ['Indigo (Light)', '#6155F5'],
    ['Indigo (Dark)', '#6B5DFF'],
    ['Purple (Light)', '#CB30E0'],
    ['Purple (Dark)', '#DB34F2'],
    ['Pink (Light)', '#FF2D55'],
    ['Pink (Dark)', '#FF375F'],
    ['Brown (Light)', '#AC7F5E'],
    ['Brown (Dark)', '#B78A66'],
  ].filter(color => {
    if (query.length === 0) {
      return true;
    }

    return color.some(text => text.toLowerCase().includes(query.toLowerCase()));
  });

  return colors.map(item => {
    return {
      title: item[1],
      subtitle: item[0],
      image: createImage(item[1]),
    };
  });
}

const canvas = document.createElement('canvas');
canvas.width = 40;
canvas.height = 40;

function createImage(color) {
  const ctx = canvas.getContext('2d');
  ctx.fillStyle = color;
  ctx.fillRect(0, 0, canvas.width, canvas.height);
  return canvas.toDataURL('image/png').replace(/^data:image\/png;base64,/, '');
}
