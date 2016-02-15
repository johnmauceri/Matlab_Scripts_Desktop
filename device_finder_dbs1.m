clear;
%close all

DEBUG = 1;

filt1 = [ones(5,25);-1*ones(5,25)];
MUSCLE_START_THRESHOLD = 0.40;
PERCENT_WHITE = 0.40;
PERCENT_WHITE2 = 0.05;
MIN_MUSCLE_ANGLE = -4;
MAX_MUSCLE_ANGLE = 4;

for db=2
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

          
    %Implants
    store_i1 = ...
        [138 41 15 15 15 15 15 41 41 41 41 41 41 41 41 41 41 41 41 41 55 96 96 96 138 138 138 138 140 140 168 168 182 182 182 189 189 ...
        211 211 211 211 211 211 211 211 211 211 211 211 231 231 231 235 235 235 249 249 249 249 249 249 ...
        278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278];
    store_i2 = ...
        [  4 19  8  9 10 11 12  3  5  6  7  8 11 12 13 14 18 19 20 21  5  5  6  7   3   4   5   6  13  16   5   8   3   4   7   3   4 ...
          3   4   5   6   7  10  11  12  15  16  17  18   3   4   5   5   6  12   5   8 12  13  14   20 ...
          7   8   9  10  11  13  16  17  18  19  20  21  23  24  25  26  27];

    
    
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
        
        for matcnt =1:186
            a = store_i1(matcnt);
            b = store_i2(matcnt);
            for i1=a
            %for i1=3:size(d1,1) %3:
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
                    if (INFO.EstimatedRadiographicMagnificationFactor > 1) found = found + 2; end
                    
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
   found = 99;                
                    if (found >= 4)
                        %store_i1(matcnt) = i1;
                        %store_i2(matcnt) = i2;
                        %store_i1
                        %store_i2
                        %matcnt = matcnt + 1;
                        %continue;
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
                   
                        %{
                         BW = edge(I,'canny', .2);
                         figure; imagesc(BW); colormap gray;
    
                         contourf(flipud(I),1);
                        
                        figure; imcontour(I,[3000 4100]);
                        
                        
                         [C,h] = contour(I,[3000 4100]);
                         clabel(C,h);
                
                         Cout = contourcs(double(flipud(I)),[3000 4100]);
                        maxlen = 0;
                         idx = 0;
                         for i = 1:size(Cout,1)
                         if (Cout(i).Length > maxlen) maxlen = Cout(i).Length; idx = i; end
                          end
                       
                        %}

                                              
                        
                  
                        
                        %START IMPLANT  ***********************
                        
                        
                        %figure(5); [C,h] = contourf(flipud(I),3);
                        
                        %figure(6); imcontour(I,[3000 4100]);
                        
                        
                        %figure(7); [C,h] = contour(flipud(I),[3000 4100]);
                        %clabel(C,h);
                
                        %Cout = contourcs(double(flipud(I)),[3000 4100]);                  
                        Cout = contourcs(double(I),[3300 4100]);
                        
                        se = strel('disk',30,8);
                        maxlen = 0;
                        idx = 0;
                        for i = 1:size(Cout,1)
                            if (Cout(i).Length > maxlen) maxlen = Cout(i).Length; idx = i; end
                        end
                        maxlen1 = 0;
                        idx1 = 0;
                        for i = 1:size(Cout,1)
                            if (i ~= idx)
                                if (Cout(i).Length > maxlen1) maxlen1 = Cout(i).Length; idx1 = i; end
                            end
                        end
                        maxlen2 = 0;
                        idx2 = 0;
                        for i = 1:size(Cout,1)
                            if ((i ~= idx) && (i ~= idx1))
                                if (Cout(i).Length > maxlen2) maxlen2 = Cout(i).Length; idx2 = i; end
                            end
                        end      
                        maxlen3 = 0;
                        idx3 = 0;
                        for i = 1:size(Cout,1)
                            if ((i ~= idx) && (i ~= idx1) && (i ~= idx2))
                                if (Cout(i).Length > maxlen3) maxlen3 = Cout(i).Length; idx3 = i; end
                            end
                        end   
                        maxlen4 = 0;
                        idx4 = 0;
                        for i = 1:size(Cout,1)
                            if ((i ~= idx) && (i ~= idx1) && (i ~= idx2) && (i ~= idx3))
                                if (Cout(i).Length > maxlen4) maxlen4 = Cout(i).Length; idx4 = i; end
                            end
                        end   
                        
                        BW = logical(zeros(size(I)));
                        for i = 1:maxlen
                            BW(uint16(Cout(idx).Y(i)), uint16(Cout(idx).X(i))) = true;
                        end
                        if (DEBUG >= 1) figure(2); imagesc(BW); colormap gray; end
                        
                        BW1 = logical(zeros(size(I)));
                        for i = 1:maxlen1
                            BW1(uint16(Cout(idx1).Y(i)), uint16(Cout(idx1).X(i))) = true;
                        end
                        if (DEBUG >= 1) figure(3); imagesc(BW1); colormap gray; end
                                                     
                        BW2 = logical(zeros(size(I)));
                        for i = 1:maxlen2
                            BW2(uint16(Cout(idx2).Y(i)), uint16(Cout(idx2).X(i))) = true;
                        end
                        if (DEBUG >= 1) figure(4); imagesc(BW2); colormap gray; end
                                                                             
                        BW3 = logical(zeros(size(I)));
                        for i = 1:maxlen3
                            BW3(uint16(Cout(idx3).Y(i)), uint16(Cout(idx3).X(i))) = true;
                        end
                        if (DEBUG >= 1) figure(5); imagesc(BW3); colormap gray; end
                        
                                                                             
                        BW4 = logical(zeros(size(I)));
                        for i = 1:maxlen4
                            BW4(uint16(Cout(idx4).Y(i)), uint16(Cout(idx4).X(i))) = true;
                        end
                        if (DEBUG >= 1) figure(6); imagesc(BW4); colormap gray; end
                        
                        width=size(I,2);
                        height=size(I,1);
C_BW = BW;            
                        BW(:, width) = 1;
                        BW(1, :) = 1;
                        BW(height, :) = 1;
                        BW = imfill(BW, 'holes');
BW(:, width) = C_BW(:, width);
BW(1, :) = C_BW(1, :);
BW(height, :) = C_BW(height, :); 
                        
C_BW = BW1;
                        BW1(:, width) = 1;
                        BW1(1, :) = 1;
                        BW1(height, :) = 1;
                        BW1 = imfill(BW1, 'holes');
BW1(:, width) = C_BW(:, width);
BW1(1, :) = C_BW(1, :);
BW1(height, :) = C_BW(height, :); 
                        
C_BW = BW2;
                        BW2(:, width) = 1;
                        BW2(1, :) = 1;
                        BW2(height, :) = 1;
                        BW2 = imfill(BW2, 'holes');
BW2(:, width) = C_BW(:, width);
BW2(1, :) = C_BW(1, :);
BW2(height, :) = C_BW(height, :); 
                                                
C_BW = BW3;                        
                        BW3(:, width) = 1;
                        BW3(1, :) = 1;
                        BW3(height, :) = 1;
                        BW3 = imfill(BW3, 'holes');
BW3(:, width) = C_BW(:, width);
BW3(1, :) = C_BW(1, :);
BW3(height, :) = C_BW(height, :); 
                         
C_BW = BW4;
                        BW4(:, width) = 1;
                        BW4(1, :) = 1;
                        BW4(height, :) = 1;
                        BW4 = imfill(BW4, 'holes');
BW4(:, width) = C_BW(:, width);
BW4(1, :) = C_BW(1, :);
BW4(height, :) = C_BW(height, :);                

                       
BW = imdilate(BW,se);
                        if (DEBUG >= 1) figure(7); imagesc(BW); colormap gray; end
BW1 = imdilate(BW1,se);                    
                        if (DEBUG >= 1) figure(8); imagesc(BW1); colormap gray; end
BW2 = imdilate(BW2,se);                        
                        if (DEBUG >= 1) figure(9); imagesc(BW2); colormap gray; end
BW3 = imdilate(BW3,se);
                        if (DEBUG >= 1) figure(10); imagesc(BW3); colormap gray; end
BW4 = imdilate(BW4,se);
                        if (DEBUG >= 1) figure(11); imagesc(BW4); colormap gray; end
                        
                        
                        
                        
                        if ((nnz(BW) > nnz(BW1)) && (nnz(BW) > nnz(BW2)) && (nnz(BW) > nnz(BW3)) && (nnz(BW) > nnz(BW4)))
BW = imfill(BW, 'holes');
                            BW = I .* uint16(~BW);
                            if (DEBUG >= 1) figure(12); imagesc(BW);colormap gray; end
                        elseif ((nnz(BW1) > nnz(BW)) && (nnz(BW1) > nnz(BW2)) && (nnz(BW1) > nnz(BW3)) && (nnz(BW1) > nnz(BW4)))
BW1 = imfill(BW1, 'holes');
                            BW1 = I .* uint16(~BW1);
                            if (DEBUG >= 1) figure(12); imagesc(BW1);colormap gray; end
                        elseif ((nnz(BW2) > nnz(BW)) && (nnz(BW2) > nnz(BW1)) && (nnz(BW2) > nnz(BW3)) && (nnz(BW2) > nnz(BW4)))
BW2 = imfill(BW2, 'holes');
                            BW2 = I .* uint16(~BW2);
                            if (DEBUG >= 1) figure(12); imagesc(BW2);colormap gray; end
                        elseif ((nnz(BW3) > nnz(BW)) && (nnz(BW3) > nnz(BW1)) && (nnz(BW3) > nnz(BW2)) && (nnz(BW3) > nnz(BW4)))
BW3 = imfill(BW3, 'holes');
                            BW3 = I .* uint16(~BW3);
                            if (DEBUG >= 1) figure(12); imagesc(BW3);colormap gray; end
                        else
BW4 = imfill(BW4, 'holes');
                            BW4 = I .* uint16(~BW4);
                            if (DEBUG >= 1) figure(12); imagesc(BW4);colormap gray; end
                        end
                        
continue;                        

                        %remove breast boarder
                        Iboundary=(imdilate(double(I==0),ones(15)));
                        if (DEBUG >= 1) figure(2); imagesc(Iboundary); colormap gray; end
                        BW2=(imdilate(double(Iboundary),ones(10)));
                        if (DEBUG >= 1) figure(3); imagesc(BW2); colormap gray; end
                        
                        width=size(I,2);                  
                        Iboundary=imdilate(double(I),ones(15));
                        if (DEBUG >= 1) figure(4); imagesc(Iboundary); colormap gray; end
                        %BW = edge(Iboundary);
                        %if (DEBUG >= 1) figure; imagesc(BW); colormap gray; end
                        BW = edge(Iboundary,'Canny', 0.1);
                        if (DEBUG >= 1) figure(5); imagesc(BW); colormap gray; end
                        %BW = edge(Iboundary,'Sobel');
                        %if (DEBUG >= 1) figure; imagesc(BW); colormap gray; end
                        %BW = bwmorph(BW,'bridge');
                        %if (DEBUG >= 1) figure(11); imagesc(BW); colormap gray; end
                        BW = (imdilate(BW,ones(5)));
                        if (DEBUG >= 1) figure(6); imagesc(BW); colormap gray; end
                        
                        BW = BW & ~BW2;
                        if (DEBUG >= 1) figure(7); imagesc(BW); colormap gray; end
                        
                        BW = bwlabel(BW);
                        r = regionprops(BW, 'All');
                        max1 = r(1).ConvexArea; %size(r(1).PixelList, 1);
                        idx = 1;
                        for k=2:size(r, 1)
                            if (r(k).ConvexArea > max1) %(size(r(k).PixelList,1) > max1)
                                max1 = r(k).ConvexArea; %max1 = size(r(k).PixelList,1);
                                idx = k;
                            end
                        end
                    
                        BW1 = (BW==idx);           
                        if (DEBUG >= 1) figure(8); imagesc(BW1);colormap gray; end
                        
                        BW1(uint16(r(idx).Extrema(5,2))-1, uint16(r(idx).Extrema(2,1)):width) = 1;
                        BW1(uint16(r(idx).Extrema(5,2))-1, uint16(r(idx).Extrema(5,1)):width) = 1;
                        if (DEBUG >= 1) figure(12); imagesc(BW1);colormap gray; end
                        
                        BW1(:, width-10:width) = 1;
                        BW1 = imfill(BW1, 'holes');
                        if (DEBUG >= 1) figure(9); imagesc(BW1);colormap gray; end
                        
                        BW2 = I .* uint16(~BW1);
                        if (DEBUG >= 1) figure(10); imagesc(BW2);colormap gray; end
continue;                        
                        
                        
                        for threshold = 4000:-100:3000
                            threshold
                            Iboundary=imdilate(double(I>threshold),ones(60)); %15
                            if (DEBUG >= 1) figure; imagesc(Iboundary); colormap gray; end
                            
                            BW = Iboundary;
                            
                            BW = bwlabel(BW);
                            r = regionprops(BW, 'All');
                            max1 = size(r(1).PixelList, 1);
                            idx = 1;
                            for k=2:size(r, 1)
                                if (size(r(k).PixelList,1) > max1)
                                    max1 = size(r(k).PixelList,1);
                                    idx = k;
                                end
                            end
                            if (max1 > 100000) break; end
                        end
                        
                        BW1 = (BW==idx);
                        BW1 = imfill(BW1, 'holes');
                                  
                        if (DEBUG >= 1)
                            figure; imagesc(BW1);colormap gray;
                            title(strrep(d2(i2).name(1:min([size(d2(i2).name,2) 40])),'_',' '));
                        end                    
                        
                        BW6 = I .* uint16(~BW1);
                        if (DEBUG >= 2) figure; imagesc(BW6);colormap gray; end
                        %END IMPLANT  ***********************
    continue;
                        
                        
                        
                        
                        
                        
                        
                        
                        
                    
                        
                        
                        
                        
                        
                        
                        %START LINEAR CLAMP ***********************
                        %Resize for speed and filter
                        height=size(I,1);
                        BW=imfilter(imresize(double(I),0.25),filt1, 'replicate');
                        %Normalize
                        BW = (BW - min(min(BW)))/(max(max(BW)) - min(min(BW)));
                        if (DEBUG==1) figure; imagesc(BW);colormap gray; end;
                        
                        %Threshold Image
                        %Get top black line
                        mt = MUSCLE_START_THRESHOLD;
                        while (mt < 1.0)
                            BW2 = ~(BW > mt);
                            if ((nnz(BW2)/prod(size(BW2))) > PERCENT_WHITE2) break; end;
                            mt = mt + 0.01;
                        end
                        %Get top white line
                        mt = MUSCLE_START_THRESHOLD;
                        while (mt < 1.0)
                            BW1 = BW > mt;
                            if ((nnz(BW1)/prod(size(BW1))) < PERCENT_WHITE) break; end;
                            mt = mt + 0.05;
                        end
                        BW = BW1 | BW2;
                        BW=imresize(BW,4);
                        if (DEBUG==1) figure; imagesc(BW);colormap gray; end;
                        
                        %START ADJUSTED MATLAB CODE FOR USING HOUGHLINES
                        [H,T,R] = hough(BW);
                        P  = houghpeaks(H,20,'threshold',ceil(0.1*max(H(:))));% 5 0.5
                        x = T(P(:,2)); y = R(P(:,1));
                        % Find lines and plot them
                        lines = houghlines(BW,T,R,P,'FillGap',5,'MinLength',500);
                        if (DEBUG>=1) figure(2), imagesc(I), colormap gray, hold on; end;
                        max_len = 0;
                        miny = 0;
                        maxy = height;
                        for k = 1:length(lines)
                            xy = [lines(k).point1; lines(k).point2];
                            if (DEBUG>=1) plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green'); end;
                            
                            % Plot beginnings and ends of lines
                            if (DEBUG>=1) plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow'); end;
                            if (DEBUG>=1) plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red'); end;
                            
                            % Determine the endpoints of the longest line segment
                            angl = atan((xy(1,2)-xy(2,2))/(xy(1,1)-xy(2,1)))*180/pi;
                            if ((angl > MIN_MUSCLE_ANGLE) && (angl < MAX_MUSCLE_ANGLE))
                                len = norm(lines(k).point1 - lines(k).point2);
                                if (DEBUG>=1) plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','cyan'); end;
                                if (len > max_len)
                                    max_len = len;
                                    xy_long = xy;
                                end
                                
                                if (xy(1,2) > (height / 2))
                                    if (xy(1,2) < maxy) maxy = xy(1,2); end
                                else
                                    if (xy(1,2) > miny) miny = xy(1,2); end
                                end
                                if (xy(2,2) > (height / 2))
                                    if (xy(2,2) < maxy) maxy = xy(2,2); end
                                else
                                    if (xy(2,2) > miny) miny = xy(2,2); end
                                end
                                
                            end
                        end
                        % highlight the longest line segment
                        if (DEBUG>=1) if (max_len > 0)   plot(xy_long(:,1),xy_long(:,2),'LineWidth',2,'Color','blue'); end; end
                        %END ADJUSTED MATLAB CODE FOR USING HOUGHLINES
                        
                        if (max_len > 1000) display(['Found Linear Clamp ', num2str(int16(max_len))]); end
                        I2 = I;
                        I2(1:miny+100,:) = 0;
                        I2(maxy-100:height,:) = 0;
                        if (DEBUG >= 1) figure(3); imagesc(I2);colormap gray; end
                        if (max_len > 1000) continue; end
                        %END LINEAR CLAMP  ***********************
                        
                      
                        
                        %START C CLAMP  ***********************
                        for threshold = 4000:-100:3000
                            threshold
                            Iboundary=imdilate(double(I>threshold),ones(60)); %15
                            %Iboundary=~(imdilate(double(I<2000),ones(50)));
                            if (DEBUG >= 1) figure; imagesc(Iboundary); colormap gray; end
                            %BW = edge(Iboundary);
                            %BW = edge(Iboundary,'canny', .02);
                            %figure; imagesc(BW); colormap gray;
                            
                            %Blur image
                            %I2 = medfilt2(I, [300 300]);
                            %find edge
                            %BW = edge(I2,'canny', .02);
                            
                            
                            BW = Iboundary;
                            
                            BW = bwlabel(BW);
                            r = regionprops(BW, 'All');
                            max1 = size(r(1).PixelList, 1);
                            idx = 1;
                            for k=2:size(r, 1)
                                if (size(r(k).PixelList,1) > max1)
                                    max1 = size(r(k).PixelList,1);
                                    idx = k;
                                end
                            end
                            if (max1 > 500000) break; end
                        end
                        max2 = 0;
                        idx2 = 0;
                        for k=1:size(r, 1)
                            if (k == idx) continue; end
                            if (size(r(k).PixelList,1) > max2)
                                max2 = size(r(k).PixelList,1);
                                idx2 = k;
                            end
                        end
                        max3 = 0;
                        idx3 = 0;
                        for k=1:size(r, 1)
                            if ((k == idx) || (k == idx2)) continue; end
                            if (size(r(k).PixelList,1) > max3)
                                max3 = size(r(k).PixelList,1);
                                idx3 = k;
                            end
                        end
                        
                        BW1 = (BW==idx);
                        if (DEBUG >= 2) figure; imagesc(BW1);colormap gray; end
                        BW1 = (imdilate(double(BW1==1),ones(75)));
                        if (DEBUG >= 2) figure; imagesc(BW1);colormap gray; end
                        
                        BW2 = (BW==idx2);
                        if (DEBUG >= 2) figure; imagesc(BW2);colormap gray; end
                        BW2 = (imdilate(double(BW2==1),ones(75)));
                        if (DEBUG >= 2) figure; imagesc(BW2);colormap gray; end
                        
                        BW3 = (BW==idx3);
                        if (DEBUG >= 2) figure; imagesc(BW3);colormap gray; end
                        BW3 = (imdilate(double(BW3==1),ones(75)));
                        if (DEBUG >= 2) figure; imagesc(BW3);colormap gray; end
                        
                        if (max2 > 250000)
                            BW4 = BW1 | BW2;
                        else
                            BW4 = BW1;
                        end
                        if (DEBUG >= 2) figure; imagesc(BW4);colormap gray; end
                        
                        if (max3 > 100000)
                            BW5 = BW4 | BW3;
                        else
                            BW5 = BW4;
                        end
                        if (DEBUG >= 1) figure; imagesc(BW5);colormap gray; end
                        
                        coutline = zeros(size(BW5));
                        maxxtop = 0;
                        maxxbot = 0;
                        for i = 1:size(I,1)
                            endpt = max(find(BW5(i,:) > 0));
                            if (endpt)
                                coutline(i, (endpt+1):end) = I(i, (endpt+1):end);
                                if (i < r(idx).Centroid(2))
                                    if (endpt > maxxtop) maxxtop = endpt; end
                                else
                                    if (endpt > maxxbot) maxxbot = endpt; end
                                end
                            end
                        end
                        firsty = 0;
                        lasty = 0;
                        for i = 1:size(I,1)
                            endpt = max(find(BW5(i,:) > 0));
                            if (i < r(idx).Centroid(2))
                                if (endpt >= maxxtop-15)
                                    %coutline(i, (endpt+1):end) = 0;
                                    firsty = i;
                                end
                            else
                                if (endpt >= maxxbot-15)
                                    %coutline(i, (endpt+1):end) = 0;
                                    if (lasty == 0) lasty = i; end
                                end
                            end
                        end
                        if (DEBUG >= 2) figure; imagesc(coutline);colormap gray; end
                        if ((lasty - firsty)  > 100)
                            coutline(1:firsty,:) = 0;
                            coutline(lasty:end,:) = 0;
                        end
                        
                        if (DEBUG >= 1)
                            figure; imagesc(coutline);colormap gray;
                            title(strrep(d2(i2).name(1:min([size(d2(i2).name,2) 40])),'_',' '));
                        end
                        
                        
                        BW6 = I .* uint16(~BW5);
                        if (DEBUG >= 2) figure; imagesc(BW6);colormap gray; end
                        %END C CLAMP  ***********************
                        
                    end
                end
            end
        end
end
