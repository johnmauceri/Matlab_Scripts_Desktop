Source = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_TXT\benign-Birad.dat'; 

dirDest = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\benign-Birad';
dirDestBox = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\benign-Birad\Box';
dirDestOrig = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\benign-Birad\Orig';

SourceData = 'H:\patient_out\';

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
        if (cnt < 68594) cnt = cnt + 1; continue; end         
        file = num2str(cell2mat(loop));
        if ~exist(file)
            display('Error file not found.', file);
            cnt = cnt + 1;
            continue
        end
        I = dicomread(file);
        %figure; imagesc(I); colormap gray;
        INFO = dicominfo(file);
        height = INFO.Height;
        width = INFO.Width;
        Q = M(cnt, 1);
        type = M(cnt, 2);
        if (INFO.PatientOrientation(1) == 'A')
            I = fliplr(I);
            break;
            display(['FLIPPED']);
        end
        IC = I;
        Xmin = M(cnt, 3);
        Xmax = M(cnt, 4);
        Ymin = M(cnt, 6);
        Ymax = M(cnt, 5);
      
        x_ctr = round((Xmin + Xmax)/2);
        y_ctr = round((Ymin + Ymax)/2);
        h = Ymax - Ymin;
        w = Xmax - Xmin;
        if (w>h) h = w;
        else w = h;
        end
        closest_edge = min([(height - y_ctr) (y_ctr - 1) (width - x_ctr) (x_ctr - 1)]);
        expand = min(round(0.7*h), closest_edge);  %0.7+0.7=1.4 ->  100(1-1.4)/2 = 20 percent bigger on each side in height and width (.55-> 5 percent)
        Ymin = (y_ctr - expand);
        Ymax = (y_ctr + expand); 
        Xmin = (x_ctr - expand);
        Xmax = (x_ctr + expand);
        Icrop = I(Ymin:Ymax, Xmin:Xmax);

        %figure; imagesc(Icrop); colormap gray;
        
        tmp = directory(cnt,:);
        desc = strrep(INFO.SeriesDescription, ' ', '');
        
        fn = fullfile(dirDest,          strcat('BR', file(strfind(file, 'birads_') + 7), '_', int2str(cnt), '_', desc, '_', tmp, '_Q', num2str(Q), '_T', num2str(type), '_X', num2str(Xmin), '_', 'Y', num2str(Ymin), '_', num2str(Xmax-Xmin+1), 'X', num2str(Ymax-Ymin+1), '_', num2str(INFO.PixelSpacing(1)), 'X', num2str(INFO.PixelSpacing(2)), '.jpg'));
        imwrite(mat2gray(Icrop), fn, 'jpg');
        
        %fn_box = fullfile(dirDestBox,   strcat('BR', file(strfind(file, 'birads_') + 7), '_', int2str(cnt), '_', desc, '_', tmp, '_Q', num2str(Q), '_T', num2str(type), '_X', num2str(Xmin), '_', 'Y', num2str(Ymin), '_', num2str(Xmax-Xmin+1), 'X', num2str(Ymax-Ymin+1), '_', num2str(INFO.PixelSpacing(1)), 'X', num2str(INFO.PixelSpacing(2)), '_BOX.jpg'));
        %fn_orig = fullfile(dirDestOrig, strcat('BR', file(strfind(file, 'birads_') + 7), '_', int2str(cnt), '_', desc, '_', tmp, '_Q', num2str(Q), '_T', num2str(type), '_X', num2str(Xmin), '_', 'Y', num2str(Ymin), '_', num2str(Xmax-Xmin+1), 'X', num2str(Ymax-Ymin+1), '_', num2str(INFO.PixelSpacing(1)), 'X', num2str(INFO.PixelSpacing(2)), '_ORIG.jpg'));
        %imwrite(mat2gray(IC), fn_orig, 'jpg');
        %Next 3 lines insert bounding box to matrix and save file
        %IC([Ymin (Ymin+1) (Ymax-1) Ymax],Xmin:Xmax) = 4000;
        %IC(Ymin:Ymax,[Xmin (Xmin+1) (Xmax-1) Xmax]) = 4000;
        %imwrite(mat2gray(IC), fn_box, 'jpg');
             
        cnt = cnt + 1;
    end
 
