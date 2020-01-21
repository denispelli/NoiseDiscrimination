function PrintBytesInStruct(o)
% PrintBytesInStruct(o)
% Denis Pelli, 2019
% I think I copied this from somewhere, but I don't remember where.
ff=fieldnames(o);
for i=1:length(ff)
    a=o.(ff{i});
    m=whos('a');
    v(i).bytes=m.bytes;
    v(i).name=['o.' ff{i}];
end
t=struct2table(v);
t=sortrows(t,'bytes');
t.total=cumsum(t.bytes);
s=table2struct(t);
fraction=[s.total]/s(end).total;
for i=1:length(s)
    s(i).fraction=fraction(i);
end
t=struct2table(s);
t