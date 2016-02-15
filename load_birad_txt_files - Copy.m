Source = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_TXT\benign-Birad.txt'; 

dirDest = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\benign-Birad';

SourceData = 'E:\patient_out\';

SAMPLE_SQUARE = 100;
PERCENT_BLACK = 0.5;
REDUCE_RECT_PCT = 0.25;

    FID = fopen(Source);
    C = textscan(FID, '%s %s %f %f %f %f %f %f %f %f');
    fclose(FID);

    filename = strcat(SourceData, C{1, 2}, '\', C{1, 1});
    directory = C{1, 2};
    M = C(3:end);
    M = cell2mat(M);

    cnt = 1;
    for loop = filename'
        file = num2str(cell2mat(loop));
        if ~exist(file)
            display('Error file not found.', file);
            continue
        end
        I = dicomread(file);
        %imagesc(I);
        %colormap gray;
        INFO = dicominfo(file);
        height = INFO.Height;
        width = INFO.Width;
        Q = M(cnt, 1);
        type = M(cnt, 2);
        Y = height - M(cnt, 4);
        if (file(62) == 'L')
            X = width - M(cnt, 3);
            Xmax = width - M(cnt, 5);
            Xmin = width - M(cnt, 6);
        else
            X = M(cnt, 3);
            Xmin = M(cnt, 5);
            Xmax = M(cnt, 6);
        end
        Ymax = height - M(cnt, 7);
        Ymin = height - M(cnt, 8);
        rect = zeros(1, 4);
    
        if ((Xmax - Xmin) < SAMPLE_SQUARE)
            rect(1) = X - (SAMPLE_SQUARE / 2);
            rect(3) = SAMPLE_SQUARE - 1;
        elseif ((REDUCE_RECT_PCT * (Xmax - Xmin)) < SAMPLE_SQUARE)
            rect(1) = X - (SAMPLE_SQUARE / 2);
            rect(3) = SAMPLE_SQUARE - 1;  
        else
            rect(1) = X - (REDUCE_RECT_PCT * ((Xmax - Xmin) / 2));
            rect(3) = REDUCE_RECT_PCT * (Xmax - Xmin);
        end
        
        if ((Ymax - Ymin) < SAMPLE_SQUARE)
            rect(2) = Y - (SAMPLE_SQUARE / 2);
            rect(4) = SAMPLE_SQUARE - 1;
        elseif ((REDUCE_RECT_PCT * (Ymax - Ymin)) < SAMPLE_SQUARE)
            rect(2) = Y - (SAMPLE_SQUARE / 2);
            rect(4) = SAMPLE_SQUARE - 1;   
        else
            rect(2) = Y - (REDUCE_RECT_PCT * ((Ymax - Ymin) / 2));
            rect(4) = REDUCE_RECT_PCT * (Ymax - Ymin);
        end
        
        rect = int64(rect);
        I = imcrop(I, rect);
        %figure
        %imagesc(I);
        %colormap gray;
        A = im2col(I, [SAMPLE_SQUARE SAMPLE_SQUARE], 'distinct');
        sz= size(A);
        tmp = strrep(directory(cnt), '/', '_');
        desc = strrep(INFO.SeriesDescription, ' ', '');
        xinc = 0;
        yinc = 0;
        for n = 1: sz(2)
            B = reshape(A(:,n), SAMPLE_SQUARE, SAMPLE_SQUARE);
            %figure
            %imagesc(B);
            %colormap gray;
            fn = fullfile(dirDest, strcat('BR',  int2str(cnt), '_', int2str(n), '_', desc, '_', tmp{1}, '_Q', num2str(Q), '_T', num2str(type), '_X', num2str(rect(1)+xinc), '_', 'Y', num2str(rect(2)+yinc), '_', num2str(SAMPLE_SQUARE), 'X', num2str(SAMPLE_SQUARE), '_', num2str(INFO.PixelSpacing(1)), 'X', num2str(INFO.PixelSpacing(2)), '.jpg'));
            if ((nnz(B)/prod(size(B)) > PERCENT_BLACK) | (n == 1))
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

  
 
