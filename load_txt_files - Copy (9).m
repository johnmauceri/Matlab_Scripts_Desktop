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
        if ~exist(strcat(file,'.dcm'))
            display('Error file not found.', file);
            continue
        end
        I = dicomread(file);
        imagesc(I);
        colormap gray;
        INFO = dicominfo(file);
        height = INFO.Height;
        Q = M(cnt, 1);
        type = M(cnt, 2);
        X = M(cnt, 3);
        Y = height - M(cnt, 4);
        Xmin = M(cnt, 5);
        Xmax = M(cnt, 6);
        Ymax = height - M(cnt, 7);
        Ymin = height - M(cnt, 8);
        rect = zeros(1, 4);
    
        rect(1) = Xmin;
        rect(2) = Ymin;
        rect(3) = Xmax - Xmin;
        rect(4) = Ymax - Ymin;
        I = imcrop(I, rect);
        figure
        imagesc(I);
        colormap gray;
        A = im2col(I, [SAMPLE_SQUARE SAMPLE_SQUARE], 'distinct');
        sz= size(A);
        tmp = strrep(dir(cnt), '/', '_');
        desc = strrep(INFO.SeriesDescription, ' ', '');
        xinc = 0;
        yinc = 0;
        for n = 1: sz(2)
            B = reshape(A(:,n), SAMPLE_SQUARE, SAMPLE_SQUARE);
            figure
            imagesc(B);
            colormap gray;
            if i==1
                fn = fullfile(dirDest, strcat('Can',  int2str(cnt), '_', int2str(n), '_', desc, '_', tmp{1}, '_', 'X', num2str(Xmin+xinc), '_', 'Y', num2str(Ymin+yinc), '_', num2str(SAMPLE_SQUARE), 'X', num2str(SAMPLE_SQUARE), '_', num2str(INFO.PixelSpacing(1)), 'X', num2str(INFO.PixelSpacing(2)), '.jpg'));
            else
                fn = fullfile(dirDest, strcat('Ben',  int2str(cnt), '_', int2str(n), '_', desc, '_', tmp{1}, '_', 'X', num2str(Xmin+xinc), '_', 'Y', num2str(Ymin+yinc), '_', num2str(SAMPLE_SQUARE), 'X', num2str(SAMPLE_SQUARE), '_', num2str(INFO.PixelSpacing(1)), 'X', num2str(INFO.PixelSpacing(2)), '.jpg'));
            end
            if (nnz(B)/prod(size(B)) > PERCENT_DATA) 
                imwrite(mat2gray(B), fn, 'jpg');
            end
            yinc = yinc + SAMPLE_SQUARE;
            if (rect(4) + 1) <= yinc
                yinc = 0;
                xinc = xinc + SAMPLE_SQUARE;
            end
        end
        
        
        
        
        
        cnt = cnt + 1;
    end
end

  
 
