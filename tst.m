dir1='H:\birad_fig\';

d1=dir(dir1);
cnt = 1;
for i1=3:size(d1,1) %3:
    if (~isempty(strfind(d1(i1).name, '_CR'))) 
        a = strfind(d1(i1).name, '_CR')
        b = strfind(d1(i1).name, '.');
        c(cnt) = str2num(d1(i1).name(a+3:b(1)-1));
        if (c(cnt) <= 1000) 
            I = imread(strcat(dir1, d1(i1).name));
            figure(20); imagesc(I); colormap gray
        end
        cnt = cnt + 1;
    end
end

bins = 20;
figure(21);
hist(c, bins);
title('contrast ratio < 1.5');