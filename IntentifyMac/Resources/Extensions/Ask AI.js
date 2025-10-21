// @ts-check
/// <reference path='../Intentify.d.ts' />

/**
 * Ask Apple Intelligence anything you need.
 *
 * @image apple.intelligence
 * @showsDialog true
 * @param {string} input
 */
async function main(input) {
  return await Intentify.askAI(input);
}
