Source = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_TXT\benign-Birad.txt'; 


FID = fopen(Source);
C = textscan(FID, '%s %s %f %f %f %f %f %f %f %f');
fclose(FID)
 
FN = C(1:1);
M = C(3:end);
M = cell2mat(M);
 
Q = M(:, 1);
%Q = sort(Q);
Q(Q > 100) = 100;
Type = M(:, 2);
Birad1 = strfind(FN{1}, 'birads_1');
BR = cellfun(@isempty,Birad1);
    
bins = 100;
figure;
hist(Q, bins);
title('Q');

bins = 3;
figure;
hist(Type, bins);
title('Type');

bins = 2;
figure;
hist(BR, bins);
title('Birad 1 or 2');



  
 
