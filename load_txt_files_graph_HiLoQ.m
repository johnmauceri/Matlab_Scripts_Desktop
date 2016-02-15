Source = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_TXT\cancer-March1.txt';

SourceData = 'C:\Users\John Mauceri\Desktop\Curemetrix Data\uncompressed\';

FID = fopen(Source);

fgetl(FID);fgetl(FID);fgetl(FID);
C = textscan(FID, '%s %s %f %f %f %f %f %f %f %f');
fclose(FID);

filename = strcat(SourceData, C{1, 2}, '\', C{1, 1});
directory = C{1, 2};
M = C(3:end);
M = cell2mat(M);

cnt = 1;
old_kase = 999;
low = [];
high = [];
for loop = filename'
    file = num2str(cell2mat(loop));
    Q = M(cnt, 1);
    kase = directory(cnt);
    kase = kase{1};
    kase = str2num(kase(2:3));
    
    if (kase ~= old_kase)
        first = 1;   
        old_kase = kase;
    end
    
    if (first == 1)
        low(kase) = Q;
        high(kase) = Q;
    else
        if (Q < low(kase))
            low(kase) = Q;
        else (Q > high(kase))
            high(kase) = Q;
        end;
    end
    
    first = 0;
    cnt = cnt + 1;
end

low(low == 0) = [];
high(high == 0) = [];
figure;
hold on;

plot(low, '-o');
title('High Low Q');
xlabel('Case');
ylabel('Q');
plot(high, '-o');


 
 
