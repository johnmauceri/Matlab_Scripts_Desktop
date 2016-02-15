SourceC = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_TXT\cancer.txt'; 
SourceB = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_TXT\benign.txt';

dirDest = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_syn_bg';

SourceData = 'C:\Users\John Mauceri\Desktop\Curemetrix Data\uncompressed\';

SAMPLE_SQUARE = 100;
PERCENT_NOT_BLACK = 0.9;
REDUCE_RECT_PCT = 0.25;
MAX_INTEN_THD = 3000;
MIN_VAR = 1000;
MAX_BLK_VALUE = 50;

rng('default');

ct = 1;
for i = 1:2
    if i == 1 FID = fopen(SourceC);
    else      FID = fopen(SourceB);
    end
    fgetl(FID);
    C = textscan(FID, '%s %s %f %f %f %f %f %f %f %f');
    fclose(FID);

    filename = strcat(SourceData, C{1, 2}, '\', C{1, 1});
    directory = C{1, 2};
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
        %imagesc(I);
        %colormap gray;
        INFO = dicominfo(file);
        height = INFO.Height;
        width = INFO.Width;
        Q = -99;
        type = -9;
        rect = zeros(1, 4); 
     
        while(1==1)
            rect(1) = round(rand(1)*(width-SAMPLE_SQUARE));
            rect(2) = round(rand(1)*(height-SAMPLE_SQUARE));
            rect(3) = SAMPLE_SQUARE - 1;
            rect(4) = SAMPLE_SQUARE - 1;
            
            rect = int64(rect);
            A = imcrop(I, rect);
            B = A > MAX_BLK_VALUE; 
            if ( ( (nnz(B)/ numel(B) ) > PERCENT_NOT_BLACK) & (max(A(:)) < MAX_INTEN_THD) & (var(double(A(:))) > MIN_VAR))
                break;
            end;
        end
        
        tmp = strrep(directory(cnt), '/', '_');
        desc = strrep(INFO.SeriesDescription, ' ', '');
      
        fn = fullfile(dirDest, strcat('Syn',  int2str(ct), '_', int2str(1), '_', desc, '_', tmp{1}, '_Q', num2str(Q), '_T', num2str(type), '_X', num2str(rect(1)), '_', 'Y', num2str(rect(2)), '_', num2str(SAMPLE_SQUARE), 'X', num2str(SAMPLE_SQUARE), '_', num2str(INFO.PixelSpacing(1)), 'X', num2str(INFO.PixelSpacing(2)), '.jpg'));
        imwrite(mat2gray(A), fn, 'jpg');
  
        ct = ct + 1;
        cnt = cnt + 1;
    end
end

  
 
