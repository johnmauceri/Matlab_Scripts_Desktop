Source = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_EXCEL\test.xls'; 

[num, text]  = xlsread(Source);

filename = strcat(text(:,2), '\', text(:,1));

for loop = filename'
    file = num2str(cell2mat(loop));
    I = dicomread(file);
end
