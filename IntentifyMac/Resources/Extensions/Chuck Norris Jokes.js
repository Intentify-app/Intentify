async function main() {
  const response = await fetch('https://api.chucknorris.io/jokes/random');
  const result = await response.json();
  return { title: result.value };
}
