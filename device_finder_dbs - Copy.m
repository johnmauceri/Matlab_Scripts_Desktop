clear;
close all

DEBUG = 1;

filt1 = [ones(5,25);-1*ones(5,25)];
MUSCLE_START_THRESHOLD = 0.40;
PERCENT_WHITE = 0.40;
MIN_MUSCLE_ANGLE = -4;
MAX_MUSCLE_ANGLE = 4;

for db=2:2
    if (db == 1) dir1='E:\konica_dx_checker\'; end
    if (db == 2) dir1='C:\Users\John Mauceri\Desktop\Mstudy2\'; end
    if (db == 3) dir1='C:\Users\John Mauceri\Desktop\Mstudy\'; end
    
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

    
    
    %C top bottom line clamp
    store_i1 = ...
        [22 22 30 33 33 33 33 33 33 37 37 37 51 51 51 52 53 53 56 56 59 59 63 63 64 64 68 68 68 68 69 69 70 70 70 75 75 77 88 88 91 91 91 93 ...
         98 98 98 98 100 100 106 106 107 107 107 107];
    store_i2 = ...
        [ 7 12  7  9 10 11 12 14 15 11 12 13  7 12 20 10  7  8 10 11 13 14  8  9 10 11 14 15 16 17  7 12  8  9 10 14 15  9  8 17  9 10 11 15 ...
          9 10 11 12   7   8   7  8    7   8  13  14];
      
      store_i1 = ...
          [53 69 91 98 100 106 107];
      store_i2 = ...
          [ 7  7  9 12   8   8  14];
      
      
      %{
    %C clamps
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
                        INFO=dicominfo(strcat(strcat(dir1,d1(i1).name),'\',d2(i2).name));
                    end
                    I=I(:,:,1);
                    if (INFO.PatientOrientation(1) == 'A')
                        I = fliplr(I);
                    end
                    figure; imagesc(I); colormap gray
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
                    
                    if (found >= 4)
                        %store_i1(matcnt) = i1;
                        %store_i2(matcnt) = i2;
                        %store_i1
                        %store_i2
                        %matcnt = matcnt + 1;
                        %continue;
                        if (DEBUG >= 1) figure; imagesc(I); colormap gray;
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
                        %}
                        %figure; imcontour(I,[3000 4100]);
                        
                        %{
                         [C,h] = contour(I,[3000 4100]);
                         clabel(C,h);
                
                         Cout = contourcs(double(flipud(I)),[3000 4100]);
                        maxlen = 0;
                         idx = 0;
                         for i = 1:size(Cout,1)
                         if (Cout(i).Length > maxlen) maxlen = Cout(i).Length; idx = i; end
                          end
                        %}
                        
                        
                        %START LINEAR CLAMP ***********************
                        %Resize for speed and filter
                        height=size(I,1);
                        BW=imfilter(imresize(double(I),0.25),filt1, 'replicate');
                        %Normalize
                        BW = (BW - min(min(BW)))/(max(max(BW)) - min(min(BW)));
                        if (DEBUG==1) figure; imagesc(BW);colormap gray; end;
                        %Threshold
                        mt = MUSCLE_START_THRESHOLD;
                        BW2 = ~(BW > (mt+0.05));
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
                        if (DEBUG>=1) figure, imagesc(I), colormap gray, hold on; end;
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
                        if (DEBUG >= 1) figure; imagesc(I2);colormap gray; end
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
