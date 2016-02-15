dirSource = 'C:\Users\John Mauceri\DICOM_TEST\Contours\Contours'; 
SourceData = 'C:\Users\John Mauceri\Desktop\Curemetrix Data\uncompressed\';

for i = 1:2
    if i == 1 files = dir(fullfile(dirSource, '*.cancer')); end;
    if i == 2 files = dir(fullfile(dirSource, '*.benign')); end;
    
    for file = files'
        
        dir1 = file.name(1:3);
        dir2 = file.name(5:6);
        name = file.name(8:end);
        filename = strcat(SourceData, dir1, '\', dir2, '\', name);
        filename = strrep(filename, 'cancer', 'dcm');
        filename = strrep(filename, 'benign', 'dcm');
        if ~exist(filename)
            display('Error file not found.', filename);
            continue
        end
        I = dicomread(filename);
        INFO = dicominfo(filename);
        height = double(INFO.Height);
        figure;
        imagesc(I);
        colormap gray;
        
        
        fid = fopen(fullfile(dirSource,file.name), 'r');
        A = fread(fid, [3, inf], 'real*4');
        fclose(fid);
        A = A';
        X = floor(A(:, 1));
        Y = floor(A(:, 2));
        Y = height - Y;
        V = floor(A(:, 3));
        %figure;
        hold on;
        plot(X, Y, '.', 'MarkerSize', 1);
    end
end




