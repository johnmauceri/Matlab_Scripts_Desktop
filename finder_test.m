clear;
%close all
%test
DEBUG = 0;

for db=5
    if (db == 1) dir1='E:\konica_dx_checker\'; end
    if (db == 2) dir1='C:\Users\John Mauceri\Desktop\Mstudy2\'; end
    if (db == 3) dir1='C:\Users\John Mauceri\Desktop\Mstudy\'; end
    if (db == 4) dir1='C:\Users\John Mauceri\Desktop\Arjan_study1_2\'; end
    if (db == 5) dir1='D:\valley_sunita\cancer\'; end
    
    
    d1=dir(dir1);
    
    %All
    store_i1 = ...
        [3     8     8     9     9    10    10    10    14    14    14    14    14    18    22    22    28    28    28    28    28    29    29    29    29    30    30    30 ...
        30    30    33    33    33    33    33    33    33    34    34    37    37    37    37    37    40    40    40    40    40    42    42    42    43    43    44    44 ...
        44    45    45    46    46    46    46    46    49    49    50    50    50    50    51    51    51    51    51    52    52    53    53    53    53    53    55    55 ...
        56    56    58    58    59    59    63    63    64    64    64    64    65    68    68    68    68    68    68    68    69    69    69    69    69    70    70    70 ...
        72    72    72    72    73    73    74    74    74    74    75    75    75    75    75    76    76    76    77    77    77    77    82    82    82    82    82    82 ...
        87    88    88    88    88    88    88    88    88    88    90    90    91    91    91    93    93    93    93    94    94    94    95    95    96    96    98    98 ...
        98    98   100   100   103   103   104   104   105   105   106   106   106   106   107   107   107   107];
    store_i2 = ...
        [5     9    10    14    15     8     9    10     8     9    11    12    13    17     7    12    10    11    12    13    14     8     9    10    11     7     9    10 ...
        12    13     9    10    11    12    13    14    15     9    10    11    12    13    14    15     6     7    14    15    19     8     9    10     8     9     9    10 ...
        11     9    10    13    14    15    16    17    14    15    10    11    15    16     7    12    20    21    22     9    10     7     8    13    14    17     6     7 ...
        10    11    15    16    13    14     8     9     8     9    10    11    13    11    12    13    14    15    16    17     7    12    17    18    19     8     9    10 ...
        10    11    12    13     9    10     8     9    10    11     9    10    13    14    15    10    11    12     9    10    11    12     4     5     6     7    12    13 ...
        9     8    10    11    17    18    19    20    21    22     9    10     9    10    11     7     8    15    17     8     9    10    14    15     8     9     9    10 ...
        11    12     7     8     8     9     7     8     9    10     7     8    10    11     7     8    13    14];
    
    
    %Pacemakers
    %{
    store_i1 = ...
        [206 220 220 220 225 236 236 247 247 258 272];
    store_i2 = ...
        [  6   8  11  14  12   5   7   9  13  11   9];
    %}
    
    %Implants
    %{
    store_i1 = ...
        [138 41 15 15 15 15 15 41 41 41 41 41 41 41 41 41 41 41 41 41 55 96 96 96 138 138 138 138 140 140 168 168 182 182 182 189 189 ...
        211 211 211 211 211 211 211 211 211 211 211 211 231 231 231 235 235 235 249 249 249 249 249 249 ...
        278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278];
    store_i2 = ...
        [  4 19  8  9 10 11 12  3  5  6  7  8 11 12 13 14 18 19 20 21  5  5  6  7   3   4   5   6  13  16   5   8   3   4   7   3   4 ...
        3   4   5   6   7  10  11  12  15  16  17  18   3   4   5   5   6  12   5   8 12  13  14   20 ...
        7   8   9  10  11  13  16  17  18  19  20  21  23  24  25  26  27];
    %}
    
    % Implant discrimination problems all
    %store_i1 = [22 39 162 181 208 41 41 41 140 168 211 211 235 249 249 278 278 278 278 278];
    %store_i2 = [10  5   7  6    6 13 14 19  13   8  10  11   5   5   8  11  13  20  21  23];
    
    % Implant discrimination problems FP
    %store_i1 = [22 39 162 181 208];
    %store_i2 = [10  5   7  6    6]; 
    
    % Implant discrimination problems missed
    %store_i1 = [41 140 168 249 249];
    %store_i2 = [19  13   8   5   8];
    
    % Implant discrimination problems missed
    %store_i1 = [41 41 41 211 235 249 278 278 278 278 278];
    %store_i2 = [13 14 21  11   5   5  11  13  20  21  23];
    
    %C top bottom linear clamp
    %{
    store_i1 = ...
        [22 22 30 33 33 33 33 33 33 37 37 37 51 51 51 52 53 53 56 56 59 59 63 63 64 64 68 68 68 68 69 69 70 70 70 75 75 77 88 88 91 91 91 93 ...
         98 98 98 98 100 100 106 106 107 107 107 107];
    store_i2 = ...
        [ 7 12  7  9 10 11 12 14 15 11 12 13  7 12 20 10  7  8 10 11 13 14  8  9 10 11 14 15 16 17  7 12  8  9 10 14 15  9  8 17  9 10 11 15 ...
          9 10 11 12   7   8   7  8    7   8  13  14];
    %}
    
    %C top bottom linear clamp PROBLEM CASES
    %{
    store_i1 = ...
        [53 69 91 98 100 106 107];
    store_i2 = ...
        [ 7  7  9 12   8   8  14];
    %}
    
    
    %C clamps
    %{
    store_i1 = ...
    [43   45   37    3     8     8     9     9    10    10    10    14    14    14    14    14    18    28    28    28    28    28    29    29    29    29    30    30 ...
    30    30    33    34    34    37    37    40    40    40    40    40    42    42    42    43    43    44    44 ...
    44    45    45    46    46    46    46    46    49    49    50    50    50    50    51    51    52    53    53    53    55    55 ...
    58    58    64    64    65    68    68    68    69    69    69    ...
    72    72    72    72    73    73    74    74    74    74    75    75    75    76    76    76    77    77    77    82    82    82    82    82    82 ...
    87    88    88    88    88    88    88    88    90    90    93    93    93    94    94    94    95    95    96    96 ...
    103   103   104   104   105   105   106   106];
    store_i2 = ...
    [8     9   15    5     9    10    14    15     8     9    10     8     9    11    12    13    17    10    11    12    13    14     8     9    10    11    9    10 ...
    12    13    13     9    10    14    15     6     7    14    15    19     8     9    10     8     9     9    10 ...
    11     9    10    13    14    15    16    17    14    15    10    11    15    16    21    22     9    13    14    17     6     7 ...
    15    16     8     9    13    11    12    13    17    18    19    ...
    10    11    12    13     9    10     8     9    10    11     9    10    13    10    11    12    10    11    12     4     5     6     7    12    13 ...
     9    10    11    18    19    20    21    22     9    10     7     8    17     8     9    10    14    15     8     9 ...
     8     9     7     8     9    10    10    11];
    %}
    
    %C-clamp discrimination problems
    %{
    store_i1 = ...
        [257 259 259 265 194 225];
    store_i2 = ...
        [  7   6  11  10   7   7];
    %}
      
    %Linear clamp with measuring device Valley DB   
    %store_i1 = [21 10];
    %store_i2 = [12  6];
    
    
    %Linear clamp with measuring device Arjan1_2 DB   
    %store_i1 = [119 119];
    %store_i2 = [ 14  15];
    
    %Triangle Metal Valley DB   
    store_i1 = [48 48 48 55 63 64 65 76 79 91 94];
    store_i2 = [ 4  5  6  5  3  7  4  4  5  4  5];
    
    %Triangle Plastic Valley DB   
    store_i1 = [103 97 97 98 102];
    store_i2 = [  4  4  6  5  10];
    
    %Circle Plastic Valley DB   
    %store_i1 = [95 97 103];
    %store_i2 = [ 8  6   4];
    
    %Circle Plastic Arjan1_2 DB   (some big circles)
    %store_i1 = [52 110 129 129 172 172 172];
    %store_i2 = [20  10  12  13  12  13  14];
   
    for matcnt =1:186
        a = store_i1(matcnt);
        b = store_i2(matcnt);
        for i1=a
        %for i1=151:225%size(d1,1) %3:
            d2 = dir(strcat(dir1,d1(i1).name));
            for i2=b
            %for i2=3:size(d2,1) %3:
                if (db == 1)
                    [I,INFO] = dicom_Konica(strcat(strcat(dir1,d1(i1).name),'\',d2(i2).name));
                end
                if (db >= 2)
                    I=dicomread(strcat(strcat(dir1,d1(i1).name),'\',d2(i2).name));
                    if ((size(I,1) == 0) || (size(I,2) == 0)) continue; end
                    INFO=dicominfo(strcat(strcat(dir1,d1(i1).name),'\',d2(i2).name));
                end
                I=I(:,:,1);
                if (INFO.PatientOrientation(1) == 'A')
                    I = fliplr(I);
                end
                %figure; imagesc(I); colormap gray
                %title(strrep(d2(i2).name(1:min([size(d2(i2).name,2) 40])),'_',' '));
                
                found = 0;
                if (strfind(INFO.StudyDescription, 'DIAG')) found = 1; end
                if (strfind(INFO.StudyDescription, 'Diag')) found = 1; end
                if isfield(INFO, 'EstimatedRadiographicMagnificationFactor')
                    if (INFO.EstimatedRadiographicMagnificationFactor > 1) found = found + 2; end
                end
                
                if isfield(INFO.ViewCodeSequence.Item_1.ViewModifierCodeSequence, 'Item_1')
                    if (strcmp(INFO.ViewCodeSequence.Item_1.ViewModifierCodeSequence.Item_1.CodeMeaning, 'Magnification'))
                        found = found + 4;
                    end
                end
                if isfield(INFO.ViewCodeSequence.Item_1.ViewModifierCodeSequence, 'Item_1')
                    if (strcmp(INFO.ViewCodeSequence.Item_1.ViewModifierCodeSequence.Item_1.CodeMeaning, 'Spot Compression'))
                        found = found + 8;
                    end
                end
                if isfield(INFO.ViewCodeSequence.Item_1.ViewModifierCodeSequence, 'Item_1')
                    if (strcmp(INFO.ViewCodeSequence.Item_1.ViewModifierCodeSequence.Item_1.CodeMeaning, 'Implant Displaced'))
                        found = found + 16;
                    end
                end
                if isfield(INFO.ViewCodeSequence.Item_1.ViewModifierCodeSequence, 'Item_2')
                    if (strcmp(INFO.ViewCodeSequence.Item_1.ViewModifierCodeSequence.Item_2.CodeMeaning, 'Magnification'))
                        found = found + 4;
                    end
                end
                if isfield(INFO.ViewCodeSequence.Item_1.ViewModifierCodeSequence, 'Item_2')
                    if (strcmp(INFO.ViewCodeSequence.Item_1.ViewModifierCodeSequence.Item_2.CodeMeaning, 'Spot Compression'))
                        found = found + 8;
                    end
                end
                if isfield(INFO.ViewCodeSequence.Item_1.ViewModifierCodeSequence, 'Item_2')
                    if (strcmp(INFO.ViewCodeSequence.Item_1.ViewModifierCodeSequence.Item_2.CodeMeaning, 'Implant Displaced'))
                        found = found + 16;
                    end
                end
                
                if (found >= 4)
                    if (DEBUG >= 1) figure(1); imagesc(I); colormap gray;
                        title(strrep(d2(i2).name(1:min([size(d2(i2).name,2) 40])),'_',' '));
                    end
                    
                    if isfield(INFO.ViewCodeSequence.Item_1.ViewModifierCodeSequence, 'Item_1')
                        display([int2str(found), ' ', INFO.ViewCodeSequence.Item_1.ViewModifierCodeSequence.Item_1.CodeMeaning,...
                            ' ', num2str(INFO.EstimatedRadiographicMagnificationFactor),...
                            ' ', INFO.StudyDescription]);
                    else
                        display([int2str(found),...
                            ' ', num2str(INFO.EstimatedRadiographicMagnificationFactor),...
                            ' ', INFO.StudyDescription]);
                    end
                end
                
                %type = device_type(I, 1);

                figure(1); imagesc(I); colormap gray;
                if (~(bitand(found, 2) || bitand(found, 4) || (bitand(found, 8))))
                    %[Iremove Imask] = implant_finder(I, DEBUG);
                    if (nnz(Imask) ~= prod(size(I)))
                        %h = figure(21); subplot(1,2,1); imagesc(I); colormap gray;  axis equal tight; subplot(1,2,2); imagesc(Iremove); colormap gray; axis equal tight;
                        %saveas(h, strcat('E:\device_finder\num', int2str(i1), '_', int2str(i2),'.png'), 'png');
                    end
                else
                    Imask = ones(size(I));
                    Iremove = I;
                end
                
                if (bitand(found, 4) || (bitand(found, 8)))
                    [Iremove Imask] = c_clamp_finder(I, 0);
                    if (nnz(Imask) ~= prod(size(I)))
                        %h = figure(22); subplot(1,2,1); imagesc(I); colormap gray;  axis equal tight; subplot(1,2,2); imagesc(Iremove); colormap gray; axis equal tight;
                        %saveas(h, strcat('E:\device_finder\num', int2str(i1), '_', int2str(i2),'.png'), 'png');
                    else
                        [Iremove Imask] = linear_clamp_finder(I, 0);
                        if (nnz(Imask) ~= prod(size(I)))
                            %h = figure(23); subplot(1,2,1); imagesc(I); colormap gray;  axis equal tight; subplot(1,2,2); imagesc(Iremove); colormap gray; axis equal tight;
                            %saveas(h, strcat('E:\device_finder\num', int2str(i1), '_', int2str(i2),'.png'), 'png');
                        end
                    end
                else
                    Imask = ones(size(I));
                    Iremove = I;
                end
                
                %[Iremove Imask] = metal_triangle_skinmarker_finder(Iremove, 0);
                if (nnz(Imask) ~= prod(size(I)))
                    %h = figure(24); subplot(1,2,1); imagesc(I); colormap gray;  axis equal tight; subplot(1,2,2); imagesc(Iremove); colormap gray; axis equal tight;
                    %saveas(h, strcat('E:\device_finder\num', int2str(i1), '_', int2str(i2),'.png'), 'png');
                end
                
                [Iremove Imask] = plastic_triangle_skinmarker_finder(Iremove, 1);
                if (nnz(Imask) ~= prod(size(I)))
                    h = figure(25); subplot(1,2,1); imagesc(I); colormap gray;  axis equal tight; subplot(1,2,2); imagesc(Iremove); colormap gray; axis equal tight;
                    saveas(h, strcat('E:\device_finder\num', int2str(i1), '_', int2str(i2),'.png'), 'png');
                end
            end
        end
    end
end
