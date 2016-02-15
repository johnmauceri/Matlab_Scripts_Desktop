CTData = 'C:\Users\John Mauceri\DICOM_TEST\CT\scans\';

files = dir(strcat(CTData,'slice*'));


for i = 1:length(files)
    
    I = imread(strcat(CTData, files(i).name));
    figure; imagesc(I);colormap gray;
end


 

