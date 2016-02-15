clear;
%close all

dir1='H:\patient_out\';
dir2='H:\birad_muscle_mask\';

d1=dir(dir1);

num_found = 0;
num_found_orig = 0;
total = 0;
for i1=3:size(d1,1) %3:
%while (1 == 1)
%for i1=uint16((size(d1,1)-3).*rand(1,1) + 3); %(b-a).*rand(1000,1) + a
    d2 = dir(strcat(dir1,d1(i1).name));
    for i2=3:size(d2,1) %3:
        if (isempty(strfind(d2(i2).name, 'MLO'))) continue; end;
        if (~isempty(strfind(d2(i2).name, 'ID_'))) continue; end;
        if (isempty(strfind(d2(i2).name, '42501800'))) continue; end;
        I=dicomread(strcat(strcat(dir1,d1(i1).name),'\',d2(i2).name));
        INFO=dicominfo(strcat(strcat(dir1,d1(i1).name),'\',d2(i2).name));
        
        if (strfind(INFO.StudyDescription, 'DIAG')) continue; end
        if (strfind(INFO.StudyDescription, 'Diag')) continue; end
        if (INFO.EstimatedRadiographicMagnificationFactor > 1) continue; end
        
        if isfield(INFO.ViewCodeSequence.Item_1.ViewModifierCodeSequence, 'Item_1')
            if (strcmp(INFO.ViewCodeSequence.Item_1.ViewModifierCodeSequence.Item_1.CodeMeaning, 'Magnification')) continue; end
            if (strcmp(INFO.ViewCodeSequence.Item_1.ViewModifierCodeSequence.Item_1.CodeMeaning, 'Spot Compression')) continue; end
            if (strcmp(INFO.ViewCodeSequence.Item_1.ViewModifierCodeSequence.Item_1.CodeMeaning, 'Implant Displaced')) continue; end
        end
        if isfield(INFO.ViewCodeSequence.Item_1.ViewModifierCodeSequence, 'Item_2')
            if (strcmp(INFO.ViewCodeSequence.Item_1.ViewModifierCodeSequence.Item_2.CodeMeaning, 'Magnification')) continue; end
            if (strcmp(INFO.ViewCodeSequence.Item_1.ViewModifierCodeSequence.Item_2.CodeMeaning, 'Spot Compression')) continue; end
            if (strcmp(INFO.ViewCodeSequence.Item_1.ViewModifierCodeSequence.Item_2.CodeMeaning, 'Implant Displaced')) continue; end
        end
        
        I=I(:,:,1);
        J = histeq(I);
        I = mat2gray(J);
        if (INFO.PatientOrientation(1) == 'A')
            I = fliplr(I);
        end
        %figure(9); imagesc(I); colormap gray; 
        title(strrep(d2(i2).name(1:45), '_', ' '))
        
        total = total + 1;
        %{
        [xy_long max_angl min_angl] = muscle_finder_orig(I, d2(i2).name(1:45), 1);
        if (xy_long ~= 0)
            num_found_orig = num_found_orig + 1;
        end
        %}

        [xy_long max_angl min_angl] = muscle_finder(I, d2(i2).name(1:45), 2);
        if (xy_long ~= 0)
            num_found = num_found + 1;
        end

        %{
        mask = logical(zeros(size(I)));
        if (xy_long ~= 0)
            m = (xy_long(2,2) - xy_long(1,2)) / (xy_long(2,1) - xy_long(1,1));
            b = xy_long(2,2) - (m * xy_long(2,1));
            y = (m * size(mask,2)) + b;
            x = -1 * b / m;
            if (x > 0)
                for yy = 1:y
                    xx = int16((yy - b) / m);
                    mask(yy,xx:size(mask,2)) = true;
                end
            end
            figure; imagesc(mask); colormap gray
        end
        
        if (~exist(strcat(dir2, d1(i1).name), 'dir')) mkdir(strcat(dir2, d1(i1).name)); end
        imwrite(mask, strcat(dir2, d1(i1).name,'\', d2(i2).name,'.png'));
        %}
    end
end
total
num_found
num_found_orig
num_found/total * 100
num_found_orig/total * 100
%end