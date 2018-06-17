function SizeOfFields(o)
% Print size (in bytes) of each field in the argument struct "o".
for f=fieldnames(o)'
    x=o.(f{1});
    w=whos('x');
    fprintf('%6.0f, %s\n',w.bytes,f{1});
end