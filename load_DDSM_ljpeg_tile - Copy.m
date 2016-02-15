dirSource = 'C:\cygwin64\home\John Mauceri\DDSM'; 

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
    
    
    txt_file = strrep(file{1}, 'LJPEG.1', 'LJPEG.txt');
    overlay_file = strrep(file{1}, 'LJPEG.1', 'OVERLAY');
    
    fid = fopen(txt_file, 'r');
    tmp = textscan(fid, '%d %d');
    image_dims = [tmp{2} tmp{1}];
    %image_dims = [tmp{1} tmp{2}];
    fclose(fid);


    fid = fopen(file{1},'r','ieee-be');
    image = fread(fid, image_dims, 'short');
    image = image';
    image = uint16(image);
    figure;
    imagesc(image);
    colormap gray;
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
            %figure;
            try 
                a = groundtruth{i}.annotations.boundary(fliplr(image_dims));
            catch
                display('Bad OVERLAY:');
                display(overlay_file);
                continue;
            end
            %imagesc(groundtruth{i}.annotations.boundary(fliplr(image_dims)));
            %colormap gray;  
            for j = 1: num_cores
                if (j > 1) 
                    display('Multiple Cores'); 
                end;
                figure;
                imagesc(groundtruth{i}.annotations.cores{j}(fliplr(image_dims)));
                colormap gray;
            end
        end
    end

end
    
%	VOLUME	SCANNER	RESOLUTION
%	normal_01	DBA	42 microns
%	normal_02	DBA	42 microns
%	normal_03	DBA	42 microns
%	normal_04	DBA	42 microns
%	normal_05	DBA	42 microns
%	normal_06	DBA	42 microns
%	normal_07	HOWTEK	43.5 microns
%	normal_08	HOWTEK	43.5 microns
%	normal_09	LUMYSIS	50 microns
%	normal_10	LUMYSIS	50 microns
%	normal_11	HOWTEK	43.5 microns
%	normal_12	HOWTEK	43.5 microns
%	cancer_01	LUMISYS	50 microns
%	cancer_02	LUMISYS	50 microns
%	cancer_03	DBA	42 microns
%	cancer_04	DBA	42 microns
%	cancer_05	LUMISYS	50 microns
%	cancer_06	HOWTEK	43.5 microns
%	cancer_07	HOWTEK	43.5 microns
%	cancer_08	HOWTEK	43.5 microns
%	cancer_09	LUMISYS	50 microns
%	cancer_10	HOWTEK	43.5 microns
%	cancer_11	HOWTEK	43.5 microns
%	cancer_12	HOWTEK	43.5 microns
%	cancer_13	HOWTEK	43.5 microns
%	cancer_14	HOWTEK	43.5 microns
%	cancer_15	LUMISYS	50 microns
%	benign_01	LUMISYS	50 microns
%	benign_02	HOWTEK	43.5 microns
%	benign_03	HOWTEK	43.5 microns
%	benign_04	LUMISYS	50 microns
%	benign_05	HOWTEK	43.5 microns
%	benign_06	LUMISYS	50 microns
%	benign_07	HOWTEK	43.5 microns
%	benign_08	HOWTEK	43.5 microns
%	benign_09	HOWTEK	43.5 microns
%	benign_10	HOWTEK	43.5 microns
%	benign_11	HOWTEK	43.5 microns
%	benign_12	HOWTEK	43.5 microns
%	benign_13	LUMISYS	50 microns
%	benign_14	LUMISYS	50 microns
%	bwc_01	LUMISYS	50 microns
%	bwc_02	LUMISYS	50 microns


