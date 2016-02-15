DEBUG = 0;

%{
Source = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Location3\bad_list_auto.txt';
FID = fopen(Source);
C = textscan(FID, '%s');
C = C{1};
C = strrep(C, '&', ' ');
fclose(FID);
%}

for loop=12:13
    if (loop == 0)
        CircleData = 'C:\Users\John Mauceri\Desktop\Curemetrix Data\uncompressed\';
        Dest = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Location3\xyradius_auto_Arjan.txt';
    elseif (loop == 1)
        CircleData = 'C:\Users\John Mauceri\Desktop\Noha\Curemetrix Cancer cases (Screening)\';
        Dest = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Location3\xyradius_auto_Noha_S.txt';
    elseif (loop == 2)
        CircleData = 'C:\Users\John Mauceri\Desktop\Noha\Curemetrix cancer cases (Diagnostic)\';
        Dest = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Location3\xyradius_auto_Noha_D.txt';
    elseif (loop == 3)
        CircleData = 'C:\Users\John Mauceri\Desktop\Noha\Curemetrix Diagnostic cases (2)\';
        Dest = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Location3\xyradius_auto_Noha_D_group2.txt';
    elseif (loop == 4)
        CircleData = 'C:\Users\John Mauceri\Desktop\Noha\Curemetrix Diagnostic cases (3)\';
        Dest = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Location3\xyradius_auto_Noha_D_group3.txt';
    elseif (loop == 5)
        CircleData = 'C:\Users\John Mauceri\Desktop\Noha\Curemetrix Diagnostic Cancer cases (4)\';
        Dest = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Location3\xyradius_auto_Noha_D_group4.txt';
    elseif (loop == 6)
        CircleData = 'C:\Users\John Mauceri\Desktop\Noha\Curemetrix Benign cases (Screening)\';
        Dest = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Location3\xyradius_auto_Noha_Benign_S.txt';
    elseif (loop == 7)
        CircleData = 'C:\Users\John Mauceri\Desktop\Noha\Curemetrix Benign cases (Diagnostic)\';
        Dest = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Location3\xyradius_auto_Noha_Benign_D.txt';
    elseif (loop == 8)
        CircleData = 'C:\Users\John Mauceri\Desktop\Noha\Missing Cancer Cases\';
        Dest = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Location3\xyradius_auto_Noha_miss_cancer.txt';
    elseif (loop == 9)
        CircleData = 'C:\Users\John Mauceri\Desktop\Noha\Diagnostic Benign Cases (2)\';
        Dest = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Location3\xyradius_auto_Noha_Benign_D_2.txt';
    elseif (loop == 10)
        CircleData = 'C:\Users\John Mauceri\Desktop\Noha\42416907 (Screening Benign)\';
        Dest = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Location3\xyradius_auto_Noha_Benign_S_2.txt';
    elseif (loop == 11)
        CircleData = 'C:\Users\John Mauceri\Desktop\Noha\Images with black borders\';
        Dest = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Location3\xyradius_auto_Noha_Black_boarder_fixes.txt';
    elseif (loop == 12)
        CircleData = 'C:\Users\John Mauceri\Desktop\Noha\US and CLIP Images of Benign Cases\';
        Dest = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Location3\xyradius_auto_Noha_Black_CLIP_Benign.txt';
    elseif (loop == 13)
        CircleData = 'C:\Users\John Mauceri\Desktop\Noha\US and CLIP Images of Cancer Cases\';
        Dest = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Location3\xyradius_auto_Noha_Black_CLIP_Cancer.txt';
    end
    
    fileID = fopen(Dest,'wt');
    fprintf(fileID,'%s %s %s %s %s\n','filename','x','y','rad_pix','size');
    
    files = dir(strcat(CircleData,'*'));
    
    for i = 1:length(files)
        list_files = dir(strcat(CircleData, files(i).name, '\*.jpg'));
        for j = 1:length(list_files)
            i
            strcat(CircleData, files(i).name, '\', list_files(j).name)
            if (list_files(j).name(1) == '.') continue; end;
            I = imread(strcat(CircleData, files(i).name, '\', list_files(j).name));
            if (list_files(j).name(1) == 'L') I = fliplr(I); end
            
            I2 = I(:,:,1);
            BW = bwlabel(imdilate((I2==0), ones(4,4)));
            r = regionprops(BW, 'PixelList', 'Image');
            
            if (size(r,1) == 0)
                %if (DEBUG == 1) figure('units','normalized','outerposition',[0 0 0.43 1]); imagesc(BW);colormap gray; end
                continue;
            end
            max1 = size(r(1).PixelList, 1);
            idx = 1;
            for k=2:size(r, 1)
                if (size(r(k).PixelList,1) > max1)
                    max1 = size(r(k).PixelList,1);
                    idx = k;
                end
            end
            if (max1 < 600)
                max1
                %if (DEBUG == 1) figure('units','normalized','outerposition',[0 0 0.43 1]); imagesc(BW);colormap gray; end
                continue;
            end;

            max2 = size(r(1).PixelList, 1);
            idx2 = 1;
            for k=2:size(r, 1)
                if (k == idx) continue; end
                if (size(r(k).PixelList,1) > max2)
                    max2 = size(r(k).PixelList,1);
                    idx2 = k;
                end
            end
            
            pl = [r(idx).PixelList;r(idx2).PixelList];
            plmax = max(pl);
            plmin = min(pl);
            
            x = uint16((plmax(1) + plmin(1)) / 2);
            y = uint16((plmax(2) + plmin(2)) / 2);
            radius = uint16(max([(plmax(1) - plmin(1)) (plmax(2) - plmin(2))]) / 2);
            
            
            BW2 = ((BW == idx) | (BW == idx2));
            
            IG=false(size(I2));
            if ((x+radius) > size(IG,2))
                IG((y-1):(y+1),x:size(IG,2)) = true;
            else
                IG((y-1):(y+1),x:(x+radius)) = true;
            end
            if ((x > 11) && ((x+10) < size(IG,2))) IG(y-10:y+10,x-10:x+10) = true; end
            oi = imoverlay(mat2gray(I2), IG(:,:), [1,1,0]);
            overlayImage = imoverlay(oi, BW2, [1,0,0]);
            figure('units','normalized','outerposition',[0 0 0.43 1]); imagesc(overlayImage);
            title(strcat(files(i).name, ' ', list_files(j).name));
            
            %1. instructions first g or b (good or bad)
            %2. if g then go to next image
            %3. if b mark circle
            %4. if only one cirlce hit d (done)
            %5. if more then one hit n (next)
            %6. repeat 3,4,5
            k=0;
            while ~k
                k=waitforbuttonpress;
                if (~strcmp(get(gcf,'currentcharacter'),'g') && (~strcmp(get(gcf,'currentcharacter'),'b')))
                    k=0;
                end
            end
            if (strcmp(get(gcf,'currentcharacter'),'g'))
                fprintf(fileID,'%s %4.0f %4.0f %4.0f %4.0f\n', strcat(files(i).name, '_', strrep(list_files(j).name, ' (', '&(')), x, y, radius, 0);
            else
                k=0;
                while ~k
                    rect = getrect;
                    
                    x = rect(1) + (rect(3)/2);
                    y = rect(2) + (rect(4)/2);
                    radius = ((rect(3)/2)^2 + (rect(4)/2)^2)^0.5;
                    fprintf(fileID,'%s %4.0f %4.0f %4.0f %4.0f\n', strcat(files(i).name, '_', strrep(list_files(j).name, ' (', '&(')), x, y, radius, 0);
                           
                    k=waitforbuttonpress;
                    if (~strcmp(get(gcf,'currentcharacter'),'d'))
                        k=0;
                    end
                end
            end
            close;
            
            
            %{
            I4 = r(idx).Image;
            if (DEBUG == 2) figure('units','normalized','outerposition',[0 0 0.43 1]); imagesc(I4);colormap gray; end
            hold on;
            I4 = r(idx2).Image;
            if (DEBUG == 2) figure('units','normalized','outerposition',[0 0 0.43 1]); imagesc(I4);colormap gray; end
            %}
        end
    end
    fclose(fileID);
end

 


    

%{
for j = 1:size(C, 1);
    j
    file = C{j};
    file
    I = imread(file);
    cnt_ = strfind(file, '\');
    if (file(cnt_(7)+1) == 'L') I = fliplr(I); end
    
    I2 = I(:,:,1);
    BW = bwlabel(imdilate((I2==0), ones(4,4)));
    r = regionprops(BW, 'PixelList', 'Image');
    
    if (size(r,1) == 0)
        if (DEBUG == 1) figure('units','normalized','outerposition',[0 0 0.43 1]); imagesc(BW);colormap gray; end
        continue;
    end
    max1 = size(r(1).PixelList, 1);
    idx = 1;
    for k=2:size(r, 1)
        if (size(r(k).PixelList,1) > max1)
            max1 = size(r(k).PixelList,1);
            idx = k;
        end
    end
    if (max1 < 900)
        if (DEBUG == 1) figure('units','normalized','outerposition',[0 0 0.43 1]); imagesc(BW);colormap gray; end
        continue;
    end;
    max2 = size(r(1).PixelList, 1);
    idx2 = 1;
    for k=2:size(r, 1)
        if (k == idx) continue; end
        if (size(r(k).PixelList,1) > max2)
            max2 = size(r(k).PixelList,1);
            idx2 = k;
        end
    end
    
    pl = [r(idx).PixelList;r(idx2).PixelList];
    plmax = max(pl);
    plmin = min(pl);
    
    x = uint16((plmax(1) + plmin(1)) / 2);
    y = uint16((plmax(2) + plmin(2)) / 2);
    radius = uint16(max([(plmax(1) - plmin(1)) (plmax(2) - plmin(2))]) / 2);
    
    if (DEBUG > 0)
        BW2 = ((BW == idx) | (BW == idx2));
        
        IG=false(size(I2));
        if ((x+radius) > size(IG,2))
            IG((y-1):(y+1),x:size(IG,2)) = true;
        else
            IG((y-1):(y+1),x:(x+radius)) = true;
        end
        if ((x > 11) && ((x+10) < size(IG,2))) IG(y-10:y+10,x-10:x+10) = true; end
        oi = imoverlay(mat2gray(I2), IG(:,:), [1,1,0]);
        overlayImage = imoverlay(oi, BW2, [1,0,0]);
        figure; imagesc(overlayImage);
        title(file(cnt_(6)+1:end));
        
        I4 = r(idx).Image;
        if (DEBUG == 2) figure('units','normalized','outerposition',[0 0 0.43 1]); imagesc(I4);colormap gray; end
        hold on;
        I4 = r(idx2).Image;
        if (DEBUG == 2) figure('units','normalized','outerposition',[0 0 0.43 1]); imagesc(I4);colormap gray; end
    end
end
%}

