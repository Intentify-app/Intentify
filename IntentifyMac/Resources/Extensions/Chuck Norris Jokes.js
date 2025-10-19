/**
 * Show you a random Chuck Norris joke.
 *
 * @image mustache
 * @showsDialog true
 */
async function main() {
  const response = await fetch('https://api.chucknorris.io/jokes/random');
  const result = await response.json();
  return result.value;
}
