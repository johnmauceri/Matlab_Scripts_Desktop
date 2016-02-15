Source = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Location3\xyradius1_rmnonmatch.txt'; 

dirDest = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Mstudy_xycircle';

SourceData = 'C:\Users\John Mauceri\Desktop\Mstudy\';

SAMPLE_SQUARE = 100;
PERCENT_BLACK = 0.5;
REDUCE_RECT_PCT = 0.25;

for i = 1:1
    FID = fopen(Source);
    fgetl(FID);
    C = textscan(FID, '%s %f %f %f %f');
    fclose(FID);

    directory = num2str(cell2mat(C{1, 1}));
    directory = directory(:, 1:6);
    
    filename = strcat(SourceData, directory, '\', C{1, 1}, '*.dcm');
    M = C(2:end);
    M = cell2mat(M);

    cnt = 1;
    for loop = filename'
        file = dir(num2str(cell2mat(loop)));
        file = strcat(SourceData, file.name(1:6), '\', file.name);
        if ~exist(file)
            display('Error file not found.', file);
            cnt = cnt + 1;
            continue
        end

        I = dicomread(file);
        INFO = dicominfo(file);
        if (INFO.PatientOrientation(1) == 'A')
            I = fliplr(I);
        end
        IC = I;
        %imagesc(I);
        %colormap gray;
        
        try
            ps1 = num2str(INFO.PixelSpacing(1));         
        catch 
            ps1 = '0.0';
            ps2 = '0.0';
            display('Error: No Pixel Spacing in file:', file);
        end
        if (~strcmp(ps1,'0.0'))  ps2 = num2str(INFO.PixelSpacing(2)); end;
        
        height = INFO.Height;
        width = INFO.Width;
        Q = 0;
        type = 0;
        Y = M(cnt, 2);
        X = M(cnt, 1);
        R = M(cnt, 3);
        SAMPLE_SQUARE = uint16((2^0.5) * R);
        Xmax = 0;
        Xmin = 0;
        Ymax = 0;
        Ymin = 0;
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
        if (rect(1) < 1) rect(1) = 1; end;
        if (rect(2) < 1) rect(2) = 1; end;
            
        rect = int64(rect);
        I = imcrop(I, rect);
        %figure
        %imagesc(I);
        %colormap gray;
        A = I;
        tmp = strrep(directory(cnt, 1:6), '/', '_');
        tmp = strcat(tmp, file(strfind(file, '_t'):strfind(file, '_t')+2));
        desc = strrep(INFO.SeriesDescription, ' ', '');
        if (desc(1) == 'M')           
            desc = strcat(strrep(file(strfind(file, '_R_')+1:strfind(file, '_R_')+5), '_', ''),strrep(file(strfind(file, '_L_')+1:strfind(file, '_L_')+5), '_', ''));
        end
        xinc = 0;
        yinc = 0;
        for n = 1: 1
            B = A;
            %figure
            %imagesc(B);
            %colormap gray;
            fn = fullfile(dirDest, strcat('Can',  int2str(cnt), '_', int2str(n), '_', desc, '_', tmp, '_Q', num2str(Q), '_T', num2str(type), '_X', num2str(rect(1)+xinc), '_', 'Y', num2str(rect(2)+yinc), '_', num2str(SAMPLE_SQUARE), 'X', num2str(SAMPLE_SQUARE), '_', ps1, 'X', ps2, '.jpg'));
            fn_box = fullfile(dirDest, strcat('Can',  int2str(cnt), '_', int2str(n), '_', desc, '_', tmp, '_Q', num2str(Q), '_T', num2str(type), '_X', num2str(rect(1)+xinc), '_', 'Y', num2str(rect(2)+yinc), '_', num2str(SAMPLE_SQUARE), 'X', num2str(SAMPLE_SQUARE), '_', ps1, 'X', ps2, '_BOX.jpg'));
            fn_orig = fullfile(dirDest, strcat('Can',  int2str(cnt), '_', int2str(n), '_', desc, '_', tmp, '_Q', num2str(Q), '_T', num2str(type), '_X', num2str(rect(1)+xinc), '_', 'Y', num2str(rect(2)+yinc), '_', num2str(SAMPLE_SQUARE), 'X', num2str(SAMPLE_SQUARE), '_', ps1, 'X', ps2, '_ORIG.jpg'));

            if ((nnz(B)/prod(size(B)) > PERCENT_BLACK) | (n == 1))
                imwrite(mat2gray(B), fn, 'jpg');
                %imwrite(mat2gray(IC), fn_orig, 'jpg');
                %Next 3 lines insert bounding box to matrix and save file
                IC([rect(2) (rect(2)+1) (rect(2)+rect(4)-1) (rect(2)+rect(4))],rect(1):(rect(1)+rect(3))) = 0;
                IC((rect(2)+1):(rect(2)+rect(4)-1),[rect(1) (rect(1)+1) (rect(1)+rect(3)-1) (rect(1)+rect(3))]) = 0;
                imwrite(mat2gray(IC), fn_box, 'jpg');
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

  
 
