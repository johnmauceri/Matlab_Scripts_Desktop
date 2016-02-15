dirSourceM2_gt = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Mstudy2_GT\gt';
dirSourceA12_gt = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Arjan_study1_2_GT\gt';
dirSourceB_gt = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Bstudy_GT\gt';

dirSourceM2 = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Mstudy2';
dirSourceA12 = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Arjan_study1_2';
dirSourceB = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Bstudy';

dirDestM2 = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Overlay\Mstudy2';
dirDestA12 = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Overlay\Arjan_study1_2';
dirDestB = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Overlay\Bstudy\';

for i = 1:3
    if i == 1
        dirSource_gt = dirSourceM2_gt;
        dirSource = dirSourceM2;
        dirDest = dirDestM2;
    end
    if i == 2
        dirSource_gt = dirSourceA12_gt;
        dirSource = dirSourceA12;
        dirDest = dirDestA12;
    end
    if i == 3
        dirSource_gt = dirSourceB_gt;
        dirSource = dirSourceB;
        dirDest = dirDestB;
    end
 
    files_gt = dir(fullfile(dirSource_gt,'*.jpg'));
    files = dir(fullfile(dirSource,'*.jpg'));
    fprintf('%d %d %d\n', i, length(files_gt), length(files));

       
    %scan for duplicates in Bill's files save only highest Q per image
    for j = 1:length(files_gt)
        name = files_gt(j).name;
        if (isempty(name)) continue; end
        cnt_ = strfind(name, '_'); 
        tmp = name(cnt_(2):cnt_(4));
        Q = str2num(name(cnt_(5)+2:cnt_(6)-1));
        for k = j+1: length(files_gt)
            name2 = files_gt(k).name;
            if (isempty(name2)) continue; end
            cnt_2 = strfind(name2, '_'); 
            tmp2 = name2(cnt_2(2):cnt_2(4));
            Q2 = str2num(name2(cnt_2(5)+2:cnt_2(6)-1));
            if (strcmp(tmp, tmp2))
                if (Q2 > Q) 
                    files_gt(j).name = files_gt(k).name;
                    Q = Q2;
                end
                files_gt(k).name = '';
            end
        end
    end
    
    %Overlay images if Clockface and Bill match. OR Just Bill
    for j = 1:length(files_gt)
        name = files_gt(j).name;
        if (isempty(name)) continue; end
        cnt_ = strfind(name, '_'); 
        tmp = name(cnt_(2):cnt_(4));
        found = 0;
        for k = 1: length(files)
            name2 = files(k).name;
            cnt_2 = strfind(name2, '_'); 
            tmp2 = strcat(name2(cnt_2(5):cnt_2(5)+1), name2(cnt_2(6)+1:cnt_2(7)), name2(1:7));
            if (strcmp(tmp, tmp2))
                I = imread(fullfile(dirSource_gt,name));
                %figure; imagesc(I); colormap gray;
                I2 = imread(fullfile(dirSource,name2));
                %figure; imagesc(I2); colormap gray;              
                I3 = imabsdiff(I, I2);
                %figure; imagesc(I3); colormap gray;
                I4 = imadd(I, I3);
                %figure; imagesc(I4); colormap gray;              
                fn_box = fullfile(dirDest, strcat(name2(1:end-4), '_', name));
                imwrite(I4, fn_box, 'jpg');
                found = 1;
                break;
            end
        end
        if (found == 0)
            I = imread(fullfile(dirSource_gt,name));
            fn_box = fullfile(dirDest, name);
            imwrite(mat2gray(I), fn_box, 'jpg');
        end
    end
    
    %If only Clockface
    for j = 1:length(files)
        name = files(j).name;
        cnt_ = strfind(name, '_'); 
        tmp = strcat(name(cnt_(5):cnt_(5)+1), name(cnt_(6)+1:cnt_(7)), name(1:7));
        found = 0;
        for k = 1: length(files_gt)
            name2 = files_gt(k).name;
            if (isempty(name2)) continue; end
            cnt_2 = strfind(name2, '_'); 
            tmp2 = name2(cnt_2(2):cnt_2(4));
            if (strcmp(tmp, tmp2))
                found = 1;
                break;
            end
        end
        if (found == 0)
            I = imread(fullfile(dirSource,name));
            fn_box = fullfile(dirDest, name);
            imwrite(mat2gray(I), fn_box, 'jpg');
        end
    end
    
    
end 
