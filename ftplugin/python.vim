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
try:
    root = ast.parse("\n".join(vim.current.buffer))
    for node in ast.walk(root):
        if not isinstance(node, ast.FunctionDef) and not isinstance(node, ast.ClassDef):
            continue
        if ast.get_docstring(node) is None:
            continue
        children = node.body
        start = node.lineno + 1
        end = children[0].lineno
        vim.command("%d,%dfold" % (start, end))
except Exception, e:
    print "Error: %s", (e,)
EOF
endfunction

command PyDocHide call PyDocHide()
