import { parse as parseJsdoc } from 'comment-parser';
import { parse as parseAst } from 'acorn';

window.parseComments = (code, target) => {
  const comments = [];
  const ast = parseAst(code, {
    ecmaVersion: 'latest',
    ranges: true,
    onComment: comments,
  });

  function findJsdocBefore(position) {
    for (let i = comments.length - 1; i >= 0; i--) {
      const comment = comments[i];
      if (comment.end >= position) {
        continue;
      }

      if (comment.type !== 'Block' || !comment.value.startsWith('*')) {
        continue;
      }

      const between = code.slice(comment.end, position);
      if (!/\S/.test(between)) {
        return comment;
      } else {
        break;
      }
    }

    return null;
  }

  function matchTargetFunction(node) {
    if (node.type === 'FunctionDeclaration' && node.id?.name === target) {
      return findJsdocBefore(node.start);
    }

    if (node.type === 'VariableDeclaration') {
      for (const decl of node.declarations) {
        const init = decl.init;
        if (decl.id?.name === target && init && ['FunctionExpression', 'ArrowFunctionExpression'].includes(init.type)) {
          return findJsdocBefore(node.start);
        }
      }
    }

    return null;
  }

  function traverse(node) {
    if (!node || typeof node !== 'object') {
      return null;
    }

    const matched = matchTargetFunction(node);
    if (matched) {
      return matched;
    }

    for (const key of Object.keys(node)) {
      const value = node[key];
      if (Array.isArray(value)) {
        for (const child of value) {
          const result = traverse(child);
          if (result) {
            return result;
          }
        }
      } else if (value && typeof value === 'object') {
        const result = traverse(value);
        if (result) {
          return result;
        }
      }
    }

    return null;
  }

  const matchedComment = traverse(ast);
  if (!matchedComment) {
    return [];
  }

  const parsed = parseJsdoc(`/*${matchedComment.value}*/`);
  return parsed.map(block => ({
    description: block.description.trim(),
    tags: block.tags.map(tag => ({
      name: tag.tag,
      value: tag.name,
    })),
  }));
};
