% TODO: crop ROI into a .png file
% TODO: add description to .png from overlay file

% source directory where all files are located
dirSource = '/home/curemetrix/Documents/MATLAB/DDSM/cases';
dirSource = 'D:\DDSM\cases';

% get all files with full pathname
files = getAllFiles(dirSource, '*.LJPEG.1', 1);

cnt = 0;
for file=files'
    cnt = cnt + 1;
    
    % save full pathname of file, to put into .png image
    % must modify to remove full pathname
    fileName = strrep(file{1}(1:end-8), '_', '-');
    
    % open particular file
    fid = fopen(file{1}, 'r', 'ieee-be');
    
    % read image, to grab its dimensions below
    I = imread(file{1}(1:end-2));
    
    % grab dimensions of the particular image
    tmp(1) = size(I,1);
    tmp(2) = size(I,2);
    if (tmp(2) < tmp(1)) image_dims = [tmp(2), tmp(1)];
    else                 image_dims = [tmp(1), tmp(2)];
    end
    
    % convert image into displayable format
    image = fread(fid, image_dims, 'short');
    fclose(fid);
    image = image';
    image = mat2gray(image);
    % uncomment below if you want to see what the mammogram looks like
    % imagesc(image);
    % colormap gray;
    
    %% 
    % check if overlay file exists, and then mark region of interest on
    % the particular mammogram image
    overlay_file = strrep(file{1}, 'LJPEG.1', 'OVERLAY');
    if exist(overlay_file, 'file') == 2
        groundtruth = get_ddsm_groundtruth_modified(overlay_file, image);
        lesion_type = groundtruth{1,1}.lesion_type;
        pathology = groundtruth{1,1}.pathology;
        assessment = int2str(groundtruth{1,1}.assessment);
        subtlety = int2str(groundtruth{1,1}.subtlety);
        
        lesion_type = cell2mat(strrep(lesion_type, 'TYPE ', ''));
        lesion_type = strrep(lesion_type, 'SHAPE ', '');
        lesion_type = strrep(lesion_type, 'MARGINS ', '');
        lesion_type = strrep(lesion_type, '/', '');
        
        imwrite(image, strcat('D:\DDSM\ORIGINAL\',strrep(fileName(42:end),'.','-'),'-',strrep(lesion_type,' ','-'),'-',assessment,'-',subtlety,'-',pathology,'.png'));        
       
        num_abnormal = length(groundtruth);
        %if num_abnormal ~= 1
            %display('Multi-abnormal:');
            %display(overlay_file);
        %end
        %display(file);
        for i = 1:num_abnormal
            num_cores = length(groundtruth{i}.annotations.cores);
            try
                % this value contains descriptions -> groundtruth{i}.lesion_type{1}
                % variable below contains mammogram with ROI circled
                a = groundtruth{i}.annotations.boundary(fliplr(image_dims));
                movefile('D:\DDSM\CROP\test.png', strcat('D:\DDSM\CROP\',strrep(fileName(42:end),'.','-'),'-',strrep(lesion_type,' ','-'),'-',assessment,'-',subtlety,'-',pathology,'-',int2str(i),'.png'));
                movefile('D:\DDSM\GT\test.txt', strcat('D:\DDSM\GT\',strrep(fileName(42:end),'.','-'),'-',strrep(lesion_type,' ','-'),'-',assessment,'-',subtlety,'-',pathology,'-',int2str(i),'.txt'));
                % uncomment below to view image with region of interest
                imwrite(a, strcat('D:\DDSM\OUTLINE\',strrep(fileName(42:end),'.','-'),'-',strrep(lesion_type,' ','-'),'-',assessment,'-',subtlety,'-',pathology,'-',int2str(i),'.png'));
                %figure;imagesc(a);title(fileName);colormap gray;
            catch
                display('Bad OVERLAY:');
                display(overlay_file);
                continue;
            end
            %figure;imagesc(groundtruth{i}.annotations.boundary(fliplr(image_dims)));colormap gray;
            for j = 1: num_cores
                if (j > 1)
                    display('Multiple Cores');
                    display(overlay_file);
                end;
                %figure;imagesc(groundtruth{i}.annotations.cores{j}(fliplr(image_dims)));colormap gray;
            end
        end
    else
        imwrite(image, strcat('D:\DDSM\ORIG_NO_OVERLAY\',strrep(fileName(42:end),'.','-'),'.png'));
    end
    
end