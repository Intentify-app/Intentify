declare global {
  /**
   * The object to use Intentify built-in APIs.
   */
  const Intentify: Intentify;
}

export const Intentify: Readonly<Intentify>;

export interface Intentify {
  /**
   * Used to communicate with [Foundation Models](https://developer.apple.com/documentation/FoundationModels).
   */
  askAI(prompt: string): Promise<string | undefined>;

  /**
   * Used to present a polished interface or prompt the user for input.
   */
  renderUI(html: string, options?: { title?: string; width?: number; height?: number }): Promise<ReturnValue>;

  /**
   * Used to continue execution with the specified Result.
   */
  returnValue(value?: ReturnValue): Promise<ReturnValue>;

  /**
   * Used to list all available extensions.
   */
  listExtensions(): Promise<string[]>;

  /**
   * Used to run another extension with name and input.
   */
  runExtension(name: string, input?: string): Promise<ReturnValue>;

  /**
   * Used to run a [system service](https://support.apple.com/guide/mac-help/mchlp1012/mac) with input.
   */
  runService(name: string, input?: string): Promise<boolean>;
}

type Result = string | { title: string; subtitle?: string; image?: string; };
type ReturnValue = Result | Result[] | undefined;
