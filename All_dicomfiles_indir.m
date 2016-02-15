dirSource = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_files'; 
dirDest = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect'; 
files = dir(fullfile(dirSource,'*.dcm'));
for file = files'
    X = dicomread(fullfile(dirSource,file.name));
    imagesc(X);
    colormap gray;
    rect = getrect();
    rect = round(rect);
    %figure; 
    rect(3) = 100;
    rect(4) = 100;
    I = imcrop(X, rect);
    %imagesc(I);  
    %colormap gray;
    dlmwrite(fullfile(dirDest,file.name), I);
end