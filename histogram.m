SourceC = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_TXT\cancer.txt'; 
SourceB = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_TXT\benign.txt';

for i = 1:2
    if i == 1 FID = fopen(SourceC);
    else      FID = fopen(SourceB);
    end
    
    
    
    

    M = C(3:end);
    M = cell2mat(M);
 
    X =  M(:, 6) - M(:, 5);
    Y =  M(:, 8) - M(:, 7);
    
    figure
    
    if i == 1 bins = 10;
    else      bins = 100;
    end
    
    hist(X, bins);
    if i == 1 title('Cancer-X');
    else      title('Benign-X');
    end
    figure
    hist(Y, bins);
    if i == 1 title('Cancer-Y');
    else      title('Benign-Y');
    end
end
  
 
