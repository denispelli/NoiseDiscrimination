for f=fieldnames(o)'
    x=o.(f{1});
    w=whos('x');
    fprintf('%6.0f, %s\n',w.bytes,f{1});
end