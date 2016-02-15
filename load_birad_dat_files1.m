Source = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_TXT\benign-Birad.dat'; 

dirDest = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\benign-Birad';
dirDestBox = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\benign-Birad\Box';
dirDestOrig = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\benign-Birad\Orig';

SourceData = 'G:\patient_out\';

INC_RECT_PCT = 0.01; %increase 10%

    FID = fopen(Source);
    C = textscan(FID, '%s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %s');
    fclose(FID);

    directory = char(C{1, 1});
    directory = directory(:,1:8);
    filename = strcat(SourceData, directory, '\', C{1, 1});
    M = C(2:7);
    M = cell2mat(M);

    cnt = 1;
    for loop = filename'
        file = num2str(cell2mat(loop));
        if ~exist(file)
            display('Error file not found.', file);
            cnt = cnt + 1;
            continue
        end
        I = dicomread(file);
        IC = I;
        %imagesc(I);
        %colormap gray;
        INFO = dicominfo(file);
        height = INFO.Height;
        width = INFO.Width;
        Q = M(cnt, 1);
        type = M(cnt, 2);
        if (INFO.PatientOrientation(1) == 'A')
            Xmax = width - M(cnt, 3);
            Xmin = width - M(cnt, 4);
            
            break;
            display(['FLIPPED']);
        else
            Xmin = M(cnt, 3);
            Xmax = M(cnt, 4);
        end
        Ymin = height - M(cnt, 5);
        Ymax = height - M(cnt, 6);
        rect = zeros(1, 4);
        
        rect(1) = Xmin - (INC_RECT_PCT * ((Xmax - Xmin)) / 2);
        rect(3) = (1+INC_RECT_PCT) * (Xmax - Xmin);
        rect(2) = Ymin - (INC_RECT_PCT * ((Ymax - Ymin)) / 2);
        rect(4) = (1+INC_RECT_PCT) * (Ymax - Ymin);

        if (rect(1) < 1) rect(1) = 1; end;
        if ((rect(1) + rect(3)) > width) rect(3) = width - rect(1); end
        if (rect(2) < 1) rect(2) = 1; end;
        if ((rect(2) + rect(4)) > height) rect(4) = height - rect(2); end
        
        
        
        Say x_st, x_end, y_st and y_end are obtained from Bill as the starting and ending x and y coordinates of the crop. Then we could do the following :
        
        x_ctr = (x_st + x_end)/2;
        y_ctr = (y_st + y_end)/2;
        h = y_end-y_st;
        w = x_end - x_st;
        if (w>h) h = w;
        else w = h;
        end
        y_st = max(1, round(y_ctr - 0.7*h));
        y_end = min(Isize(1), round(y_ctr + 0.7*h));
        x_st = max(1, round(x_ctr - 0.7*w));
        x_end = min(Isize(2), round(x_ctr + 0.7*w));
        Icrop = I(y_st:y_end, x_st:x_end, :);
        
        
        
        
        
        
        
        rect = int64(rect);
        I = imcrop(I, rect);
        %figure
        %imagesc(I);
        %colormap gray;
        
        tmp = directory(cnt,:);
        desc = strrep(INFO.SeriesDescription, ' ', '');
        
        fn = fullfile(dirDest, strcat('BR', file(strfind(file, 'birads_') + 7), '_', int2str(cnt), '_', desc, '_', tmp, '_Q', num2str(Q), '_T', num2str(type), '_X', num2str(rect(1)), '_', 'Y', num2str(rect(2)), '_', num2str(rect(3)), 'X', num2str(rect(4)), '_', num2str(INFO.PixelSpacing(1)), 'X', num2str(INFO.PixelSpacing(2)), '.jpg'));
        fn_box = fullfile(dirDestBox, strcat('BR', file(strfind(file, 'birads_') + 7), '_', int2str(cnt), '_', desc, '_', tmp, '_Q', num2str(Q), '_T', num2str(type), '_X', num2str(rect(1)), '_', 'Y', num2str(rect(2)), '_', num2str(rect(3)), 'X', num2str(rect(4)), '_', num2str(INFO.PixelSpacing(1)), 'X', num2str(INFO.PixelSpacing(2)), '_BOX.jpg'));
        fn_orig = fullfile(dirDestOrig, strcat('BR', file(strfind(file, 'birads_') + 7), '_', int2str(cnt), '_', desc, '_', tmp, '_Q', num2str(Q), '_T', num2str(type), '_X', num2str(rect(1)), '_', 'Y', num2str(rect(2)), '_', num2str(rect(3)), 'X', num2str(rect(4)), '_', num2str(INFO.PixelSpacing(1)), 'X', num2str(INFO.PixelSpacing(2)), '_ORIG.jpg'));
        
        imwrite(mat2gray(I), fn, 'jpg');
        imwrite(mat2gray(IC), fn_orig, 'jpg');
        %Next 3 lines insert bounding box to matrix and save file
        IC([rect(2) (rect(2)+1) (rect(2)+rect(4)-1) (rect(2)+rect(4))],rect(1):(rect(1)+rect(3))) = 0;
        IC((rect(2)+1):(rect(2)+rect(4)-1),[rect(1) (rect(1)+1) (rect(1)+rect(3)-1) (rect(1)+rect(3))]) = 0;
        imwrite(mat2gray(IC), fn_box, 'jpg');
             
        cnt = cnt + 1;

    
    
    
    
    
    end
 
