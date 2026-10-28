// Gramaticas propias para CDS y BDEF (Prism no las trae) y arranque del resaltado.
(function () {
  var P = window.Prism;
  if (!P || !P.languages) { return; }

  function palabras(lista) {
    return new RegExp('\\b(?:' + lista.join('|') + ')\\b', 'i');
  }

  // CDS: vistas, tablas, proyecciones, metadata extensions y service definitions
  P.languages.cds = {
    'comment': [/\/\/.*/, /\/\*[\s\S]*?\*\//],
    'annotation': { pattern: /@[\w.]+/, alias: 'atrule' },
    'string': /'(?:[^'\\]|\\.)*'/,
    'variable': /\$(?:projection|session|parameters)(?:\.\w+)?/,
    'type': { pattern: /\babap\.\w+(?:\(\s*\d+(?:\s*,\s*\d+)?\s*\))?/i, alias: 'class-name' },
    'association': { pattern: /\b_\w+/, alias: 'property' },
    'function': palabras(['cast', 'coalesce', 'concat', 'concat_with_space', 'substring', 'division',
      'round', 'sum', 'count', 'max', 'min', 'avg', 'dats_days_between', 'dats_add_days',
      'tstmp_current_utctimestamp', 'currency_conversion', 'upper', 'lower', 'length']),
    'keyword': palabras(['define', 'root', 'view', 'entity', 'as', 'select', 'from', 'distinct',
      'association', 'composition', 'to', 'parent', 'of', 'on', 'key', 'where', 'group', 'by',
      'having', 'case', 'when', 'then', 'else', 'end', 'inner', 'left', 'outer', 'join', 'and',
      'or', 'not', 'is', 'null', 'like', 'between', 'in', 'table', 'extend', 'with', 'parameters',
      'projection', 'provider', 'contract', 'redirected', 'transactional_query',
      'transactional_interface', 'analytical_query', 'metadata', 'annotate', 'service', 'expose',
      'union', 'all', 'include', 'default', 'abstract', 'custom', 'implemented', 'method',
      'virtual', 'localized', 'event']),
    'number': /\b\d+(?:\.\d+)?\b/,
    'operator': /[=<>!]=?|[-+*\/]|\|\|/,
    'punctuation': /[{}()\[\];:,.]/
  };

  // BDEF: definiciones de comportamiento (interface y proyeccion)
  P.languages.bdef = {
    'comment': [/\/\/.*/, /\/\*[\s\S]*?\*\//],
    'string': /'(?:[^'\\]|\\.)*'/,
    'association': { pattern: /\b_\w+/, alias: 'property' },
    'keyword': palabras(['managed', 'unmanaged', 'implementation', 'in', 'class', 'unique',
      'strict', 'with', 'draft', 'define', 'behavior', 'for', 'alias', 'persistent', 'table',
      'lock', 'master', 'dependent', 'by', 'authorization', 'etag', 'total', 'create', 'update',
      'delete', 'field', 'readonly', 'mandatory', 'numbering', 'determination', 'validation',
      'action', 'result', 'on', 'save', 'modify', 'determine', 'side', 'effects', 'affects',
      'association', 'mapping', 'corresponding', 'use', 'projection', 'internal', 'features',
      'instance', 'global', 'factory', 'static', 'event', 'parameter', 'precheck', 'late',
      'early', 'abbreviation', 'additional', 'query', 'interface', 'entity', 'self', 'none',
      'require', 'transactional', 'and', 'or', 'not', 'raised', 'own', 'messages', 'reported',
      'failed', 'Edit', 'Activate', 'Discard', 'Resume', 'Prepare', 'optimized']),
    'number': /\b\d+\b/,
    'operator': /[=<>]|~/,
    'punctuation': /[{}()\[\];:,.*]/
  };

  // Con kramdown, el lenguaje puede venir en el <code> o en un <div> que lo envuelve (Rouge)
  function lenguajeDe(code) {
    var nodo = code;
    while (nodo && nodo !== document.body) {
      var m = /\blanguage-(\w+)/.exec(nodo.className || '');
      if (m) { return m[1].toLowerCase(); }
      nodo = nodo.parentNode;
    }
    return null;
  }

  function resaltar() {
    var bloques = document.querySelectorAll('pre code');
    for (var i = 0; i < bloques.length; i++) {
      var code = bloques[i];
      var lenguaje = lenguajeDe(code);
      if (lenguaje === 'sql') { lenguaje = 'cds'; }
      if (!lenguaje || !P.languages[lenguaje]) { continue; }
      code.textContent = code.textContent;          // quita el marcado de Rouge, si lo hay
      code.className = 'language-' + lenguaje;
      code.parentNode.classList.add('language-' + lenguaje);
      P.highlightElement(code);
    }
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', resaltar);
  } else {
    resaltar();
  }
})();
