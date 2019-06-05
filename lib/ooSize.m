fields=fieldnames(oo);
bytes=zeros([length(fields) 1]);
for i=1:length(fields)
    f=fields{i};
    for j=1:length(oo)
        x=getfield(oo(j),f);
        s=whos('x');
        bytes(i)=bytes(i)+s.bytes;
    end
end
[bytes,ii]=sort(bytes,'descend');
field=fields(ii);
fraction=bytes/sum(bytes);
t=table(field,bytes,fraction);
t(1:3,:)