SourceC = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_TXT\cancer.txt'; 
SourceB = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_TXT\benign.txt';

dirDest = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect';

SourceData = 'C:\Users\John Mauceri\Desktop\Curemetrix Data\uncompressed\';

SAMPLE_SQUARE = 100;
PERCENT_DATA = 0.5;

for i = 1:2
    if i == 1 FID = fopen(SourceC);
    else      FID = fopen(SourceB);
    end
    C = textscan(FID, '%s %s %f %f %f %f %f %f %f %f');
    fclose(FID);

    filename = strcat(SourceData, C{1, 2}, '\', C{1, 1});
    dir = C{1, 2};
    M = C(3:end);
    M = cell2mat(M);

    cnt = 1;
    for loop = filename'
        file = num2str(cell2mat(loop));
        I = dicomread(file);
        INFO = dicominfo(file);
        Q = M(cnt, 1);
        type = M(cnt, 2);
        X = M(cnt, 3);
        Y = M(cnt, 4);
        Xmin = M(cnt, 5);
        Xmax = M(cnt, 6);
        Ymin = M(cnt, 7);
        Ymax = M(cnt, 8);
        rect = zeros(1, 4);
    
        rect(1) = Xmin;
        rect(2) = Ymin;
        rect(3) = Xmax - Xmin;
        rect(4) = Ymax - Ymin; 
        I = imcrop(I, rect);
        %imagesc(I);
        %colormap gray;
        A = im2col(I, [SAMPLE_SQUARE SAMPLE_SQUARE], 'distinct');
        sz= size(A);
        tmp = strrep(dir(cnt), '/', '_');
        desc = strrep(INFO.SeriesDescription, ' ', '');
        for n = 1: sz(2)
            B = reshape(A(:,n), SAMPLE_SQUARE, SAMPLE_SQUARE);
            if i==1
                fn = fullfile(dirDest, strcat('C_', desc, '_', tmp{1}, int2str(cnt), '_', 'X', num2str(Xmin), '_', 'Y', num2str(Ymin), '_', int2str(n), '.jpg'));
            else
                fn = fullfile(dirDest, strcat('B_', desc, '_', tmp{1}, int2str(cnt), '_', int2str(n), '.jpg'));
            end
            if (nnz(B)/prod(size(B)) > PERCENT_DATA) 
                imwrite(mat2gray(B), fn, 'jpg');
            end
        end
        cnt = cnt + 1;
    end
end

  
 
