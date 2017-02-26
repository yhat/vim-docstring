if !has('python')
    echo "Error: Docstring requires vim compiled with +python"
    finish
endif

function! PyDocHide()
python << EOF
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
        # if has decorators
        if node.decorator_list:
            start += len(node.decorator_list)
        end = children[0].lineno
        vim.command("%d,%dfold" % (start, end))
except Exception, e:
    print "Error: %s", (e,)
EOF
endfunction

command PyDocHide call PyDocHide()
