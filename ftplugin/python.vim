" Vim folding file
" Language:     Python (docstring)
" Author:       Eric Chiang, Milly (module)
" Last Change:  20 Jan 2018
" Version:      1.1


if exists('g:loaded_python_docstring')
    finish
endif
let g:loaded_python_docstring = 1

if !has('pythonx')
    echomsg "Error: Docstring requires vim compiled with +python or +python3"
    finish
endif

function! PyDocHide()
    setlocal foldmethod=manual
pythonx << EOF
import vim
import ast
import re

try:
    lines = list(vim.current.buffer)
    root = ast.parse("\n".join(lines))
    for node in ast.walk(root):
        if not isinstance(node, (ast.Module, ast.FunctionDef, ast.ClassDef)):
            continue
        if ast.get_docstring(node) is None:
            continue
        first_child = node.body[0]
        if not isinstance(first_child, ast.Expr):
            continue
        end = first_child.lineno
        if '"""' in lines[end - 1]:
            bracket = '"""'
        elif "'''" in lines[end - 1]:
            bracket = "'''"
        else:
            continue
        if re.search(bracket + '.*' + bracket, lines[end - 1]):
            start = end
        else:
            start = node.lineno if hasattr(node, 'lineno') else 1
            for i, line in enumerate(lines[end-2 : start-1 : -1]):
                if bracket in line:
                    start = end - i - 1
                    break
            else:
                continue
        vim.command("%d,%dfold" % (start, end))
except Exception as e:
    print("Error: %s" % (e,))
EOF
endfunction

command! PyDocHide call PyDocHide()
