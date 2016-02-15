dirSource = '/home/curemetrix/Documents/MATLAB/DDSM/cases';

files = getAllFiles(dirSource, '*.LJPEG.1', 1);

for file = files'

    resolution = 43.5;
    k = strfind(file, 'benign_without_callback'); if (k{1} > 1); resolution = 50; end;
    k = strfind(file, 'normal_01'); if (k{1} > 1); resolution = 42; end;
    k = strfind(file, 'normal_02'); if (k{1} > 1); resolution = 42; end;
    k = strfind(file, 'normal_03'); if (k{1} > 1); resolution = 42; end;
    k = strfind(file, 'normal_04'); if (k{1} > 1); resolution = 42; end;
    k = strfind(file, 'normal_05'); if (k{1} > 1); resolution = 42; end;
    k = strfind(file, 'normal_06'); if (k{1} > 1); resolution = 42; end;
    k = strfind(file, 'cancer_03'); if (k{1} > 1); resolution = 42; end;
    k = strfind(file, 'cancer_04'); if (k{1} > 1); resolution = 42; end;
    k = strfind(file, 'normal_09'); if (k{1} > 1); resolution = 50; end;
    k = strfind(file, 'normal_10'); if (k{1} > 1); resolution = 50; end;
    k = strfind(file, 'cancer_01'); if (k{1} > 1); resolution = 50; end;
    k = strfind(file, 'cancer_02'); if (k{1} > 1); resolution = 50; end;
    k = strfind(file, 'cancer_05'); if (k{1} > 1); resolution = 50; end;
    k = strfind(file, 'cancer_09'); if (k{1} > 1); resolution = 50; end;
    k = strfind(file, 'cancer_15'); if (k{1} > 1); resolution = 50; end;
    k = strfind(file, 'benign_01'); if (k{1} > 1); resolution = 50; end;
    k = strfind(file, 'benign_04'); if (k{1} > 1); resolution = 50; end;
    k = strfind(file, 'benign_06'); if (k{1} > 1); resolution = 50; end;
    k = strfind(file, 'benign_13'); if (k{1} > 1); resolution = 50; end;
    k = strfind(file, 'benign_14'); if (k{1} > 1); resolution = 50; end;
    
    % replace all string instances in directory and write to file
    txt_file = strrep(file{1}, 'LJPEG.1', 'LJPEG.txt');
    
    % replace all string instances and write to file
    overlay_file = strrep(file{1}, 'LJPEG.1', 'OVERLAY');
    
    % open text file
    fid = fopen(txt_file, 'r');
    
    % grab dimensions of image
    tmp = textscan(fid, '%d %d');
    if (tmp{2} < tmp{1}) image_dims = [tmp{2} tmp{1}];
    else                 image_dims = [tmp{1} tmp{2}];
    end
    fclose(fid);

    % open 
    fid = fopen(file{1},'r','ieee-be');
    image = fread(fid, image_dims, 'short');
    image = image';
    image = uint16(image);
    %figure;
    %imagesc(image);
    %colormap gray;
    fclose(fid);

    if exist(overlay_file, 'file') == 2
        groundtruth = get_ddsm_groundtruth(overlay_file);
        lesion_type = groundtruth{1,1}.lesion_type;
        pathology = groundtruth{1,1}.pathology;

        num_abnormal = length(groundtruth);
        if num_abnormal ~= 1 
            display('Multi-abnormal:');
            display(overlay_file);
        end
        display(file);
        for i = 1:num_abnormal
            num_cores = length(groundtruth{i}.annotations.cores);
            try 
                a = groundtruth{i}.annotations.boundary(fliplr(image_dims));
            catch
                display('Bad OVERLAY:');
                display(overlay_file);
                continue;
            end
            %figure;
            %imagesc(groundtruth{i}.annotations.boundary(fliplr(image_dims)));
            %colormap gray;  
            for j = 1: num_cores
                if (j > 1) 
                    display('Multiple Cores'); 
                    display(overlay_file);
                end;
                %figure;
                %imagesc(groundtruth{i}.annotations.cores{j}(fliplr(image_dims)));
                %colormap gray;
            end
        end
    end

end
    

