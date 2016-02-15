SourceC = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_TXT\cancer-Bstudy.dat'; 
SourceB = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_TXT\benign-Bstudy.dat';

dirDest = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Bstudy_GT';
dirDest_orig = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Bstudy_GT\orig';
dirDest_box = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Bstudy_GT\box'; 
dirDest_gt = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Bstudy_GT\gt';

SourceData = 'C:\Users\John Mauceri\Desktop\Bstudy\';

SAMPLE_SQUARE = 100;
PERCENT_BLACK = 0.5;
REDUCE_RECT_PCT = 0.25;

for i = 1:1
    if i == 1 FID = fopen(SourceC);
    else      FID = fopen(SourceB);
    end
    C = textscan(FID, '%s %s %f %f %f %f %f %f %f %f');
    fclose(FID);

    if i == 1 fn_can_store = C{1, 1}; end;
    filename = strcat(SourceData, C{1, 2}, '\', C{1, 1});
    directory = C{1, 2};
    M = C(3:end);
    M = cell2mat(M);

    cnt = 1;
    for loop = filename'
        cnt
        file = num2str(cell2mat(loop));
        if ~exist(file)
            display('Error file not found.', file);
            cnt = cnt + 1;
            continue
        end
        
        found = 0;
        type = file(strfind(file, '_t') + 2);   
        type = type(1);
        if ((i == 2) && ((type == '0') || (type == '1')))
            left = file(strfind(file, '_L_') + 1);
            name = file(strfind(file, '_t') - 14: strfind(file, '_t') - 1);
            for j = 1: size(fn_can_store)
                tmp = fn_can_store{j};
                type_c = tmp(strfind(tmp, '_t') + 2);
                left_c = tmp(strfind(tmp, '_L_') + 1);
                name_c = tmp(strfind(tmp, '_t') - 14: strfind(tmp, '_t') - 1);
                if (((type_c == '2') || (type_c == '3')) && (strcmp(name, name_c)) && (strcmp(left, left_c)))
                    found = 1;
                    display('Skip file:', file);
                    break;
                end
            end
        end
        if (found == 1) cnt = cnt + 1; continue; end;

        I = dicomread(file);
        I2 = I;
        IG = I;
        %imagesc(I);
        %colormap gray;
        INFO = dicominfo(file);
        height = INFO.Height;
        width = INFO.Width;
        Q = M(cnt, 1);
        type = M(cnt, 2);
        Y = height - M(cnt, 4);
        if (file(strfind(file, '_L_')+1) == 'L')
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
        if (rect(1) < 1) rect(1) = 1; end;
        if (rect(2) < 1) rect(2) = 1; end;
        
        rect = int64(rect);
        I = imcrop(I, rect);
        %figure
        %imagesc(I);
        %colormap gray;
        A = im2col(I, [SAMPLE_SQUARE SAMPLE_SQUARE], 'distinct');
        sz= size(A);
        tmp = strrep(directory(cnt), '/', '_');
        tmp = strcat(tmp, file(strfind(file, '_t'):strfind(file, '_t')+2));
        desc = strrep(INFO.SeriesDescription, ' ', '');
        xinc = 0;
        yinc = 0;
        for n = 1: sz(2)
            B = reshape(A(:,n), SAMPLE_SQUARE, SAMPLE_SQUARE);
            %figure
            %imagesc(B);
            %colormap gray;
            if i==1
                fn = fullfile(dirDest, strcat('Can',  int2str(cnt), '_', int2str(n), '_', desc, '_', tmp{1}, '_Q', num2str(Q), '_T', num2str(type), '_X', num2str(rect(1)+xinc), '_', 'Y', num2str(rect(2)+yinc), '_', num2str(SAMPLE_SQUARE), 'X', num2str(SAMPLE_SQUARE), '_', num2str(INFO.PixelSpacing(1)), 'X', num2str(INFO.PixelSpacing(2)), '.jpg'));
                fn_box = fullfile(dirDest_box, strcat('Can',  int2str(cnt), '_', int2str(n), '_', desc, '_', tmp{1}, '_Q', num2str(Q), '_T', num2str(type), '_X', num2str(rect(1)+xinc), '_', 'Y', num2str(rect(2)+yinc), '_', num2str(SAMPLE_SQUARE), 'X', num2str(SAMPLE_SQUARE), '_', num2str(INFO.PixelSpacing(1)), 'X', num2str(INFO.PixelSpacing(2)), '_BOX.jpg'));
                fn_orig = fullfile(dirDest_orig, strcat('Can',  int2str(cnt), '_', int2str(n), '_', desc, '_', tmp{1}, '_Q', num2str(Q), '_T', num2str(type), '_X', num2str(rect(1)+xinc), '_', 'Y', num2str(rect(2)+yinc), '_', num2str(SAMPLE_SQUARE), 'X', num2str(SAMPLE_SQUARE), '_', num2str(INFO.PixelSpacing(1)), 'X', num2str(INFO.PixelSpacing(2)), '_ORIG.jpg'));
                fn_gt = fullfile(dirDest_gt, strcat('Can',  int2str(cnt), '_', int2str(n), '_', desc, '_', tmp{1}, '_Q', num2str(Q), '_T', num2str(type), '_X', num2str(Xmin+xinc), '_', 'Y', num2str(Ymin+yinc), '_', num2str(Xmax-Xmin), 'X', num2str(Ymax-Ymin), '_', num2str(INFO.PixelSpacing(1)), 'X', num2str(INFO.PixelSpacing(2)), '_GT.jpg'));
            else         
                fn = fullfile(dirDest, strcat('Ben',  int2str(cnt), '_', int2str(n), '_', desc, '_', tmp{1}, '_Q', num2str(Q), '_T', num2str(type), '_X', num2str(rect(1)+xinc), '_', 'Y', num2str(rect(2)+yinc), '_', num2str(SAMPLE_SQUARE), 'X', num2str(SAMPLE_SQUARE), '_', num2str(INFO.PixelSpacing(1)), 'X', num2str(INFO.PixelSpacing(2)), '.jpg'));
                fn_box = fullfile(dirDest_box, strcat('Ben',  int2str(cnt), '_', int2str(n), '_', desc, '_', tmp{1}, '_Q', num2str(Q), '_T', num2str(type), '_X', num2str(rect(1)+xinc), '_', 'Y', num2str(rect(2)+yinc), '_', num2str(SAMPLE_SQUARE), 'X', num2str(SAMPLE_SQUARE), '_', num2str(INFO.PixelSpacing(1)), 'X', num2str(INFO.PixelSpacing(2)), '_BOX.jpg'));
                fn_orig = fullfile(dirDest_orig, strcat('Ben',  int2str(cnt), '_', int2str(n), '_', desc, '_', tmp{1}, '_Q', num2str(Q), '_T', num2str(type), '_X', num2str(rect(1)+xinc), '_', 'Y', num2str(rect(2)+yinc), '_', num2str(SAMPLE_SQUARE), 'X', num2str(SAMPLE_SQUARE), '_', num2str(INFO.PixelSpacing(1)), 'X', num2str(INFO.PixelSpacing(2)), '_ORIG.jpg'));
                fn_gt = fullfile(dirDest_orig, strcat('Ben',  int2str(cnt), '_', int2str(n), '_', desc, '_', tmp{1}, '_Q', num2str(Q), '_T', num2str(type), '_X', num2str(Xmin+xinc), '_', 'Y', num2str(Ymin+yinc), '_', num2str(Xmax-Xmin), 'X', num2str(Ymax-Ymin), '_', num2str(INFO.PixelSpacing(1)), 'X', num2str(INFO.PixelSpacing(2)), '_GT.jpg'));           
            end
            if ((nnz(B)/prod(size(B)) > PERCENT_BLACK) | (n == 1))
                %imwrite(mat2gray(B), fn, 'jpg');
                IC = I2;
                %if (n == 1) imwrite(mat2gray(IC), fn_orig, 'jpg'); end
                %Next 3 lines insert bounding box to matrix and save file
                IC([(rect(2)+yinc) (rect(2)+yinc+1) (rect(2)+SAMPLE_SQUARE+yinc-1) (rect(2)+SAMPLE_SQUARE+yinc)],(rect(1)+xinc):(rect(1)+SAMPLE_SQUARE+xinc)) = 4000;
                IC((rect(2)+yinc+1):(rect(2)+SAMPLE_SQUARE+yinc-1),[(rect(1)+xinc) (rect(1)+xinc+1) (rect(1)+SAMPLE_SQUARE+xinc-1) (rect(1)+SAMPLE_SQUARE+xinc)]) = 4000;
                %imwrite(mat2gray(IC), fn_box, 'jpg');
                
                if ((i == 1) && (n == 1))
                    IG=false(size(I2));
                    IG([Ymin (Ymin+1) (Ymax-1) Ymax],Xmin:Xmax) = true;
                    IG(Ymin:Ymax,[Xmin (Xmin+1) (Xmax-1) Xmax]) = true;
                    overlayImage = imoverlay(mat2gray(I2), IG(1:size(I2,1),1:size(I2,2)), [1,1,0]);
                    imwrite(overlayImage, fn_gt, 'jpg');
                end
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

  
 
