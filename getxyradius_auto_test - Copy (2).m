CircleData = 'C:\Users\John Mauceri\Desktop\Curemetrix Data\uncompressed\';

Dest = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Location3\xyradius.txt'; 

fileID = fopen(Dest,'wt');
fprintf(fileID,'%s %s %s %s %s\n','filename','x','y','rad_pix','size');

files = dir(strcat(CircleData,'M*'));


for i = 1:length(files)
    list_files = dir(strcat(CircleData, files(i).name, '\*.jpg'));
    for j = 1:length(list_files)
        
        strcat(CircleData, files(i).name, '\', list_files(j).name)
        if (list_files(j).name(1) == '.') continue; end;
        I = imread(strcat(CircleData, files(i).name, '\', list_files(j).name));              
        if (list_files(j).name(1) == 'L') I = fliplr(I); end
            
        I2 = I(:,:,1);
        BW = bwlabel(imdilate((I2==0), ones(4,4)));
        r = regionprops(BW, 'PixelList', 'Image');

        max1 = size(r(1).PixelList, 1);
        idx = 1;
        for k=2:size(r, 1) 
            if (size(r(k).PixelList,1) > max1) 
                max1 = size(r(k).PixelList,1); 
                idx = k;
            end
        end
        if (max1 < 1000) continue; end;
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
      
        fprintf(fileID,'%s %4.0f %4.0f %4.0f %4.0f\n', strcat(files(i).name, '_', list_files(j).name), x, y, radius, 0);
        
        BW2 = ((BW == idx) | (BW == idx2));
        
        %{      
        BLUR = 75;
        BW3 = bwlabel(imdilate(BW2, ones(BLUR,BLUR)));
        imagesc(BW3);
        r = regionprops(BW3, 'Perimeter', 'Centroid', 'PixelList', 'Image');

        perimeter = r(1).Perimeter;
        radius = uint16((perimeter/(2*pi)) - (BLUR/1.25));
        xy = uint16(r(1).Centroid);
       
        IG=false(size(I2));
        IG((xy(2)-1):(xy(2)+1),xy(1):(xy(1)+radius)) = true;
        IG(xy(2)-10:xy(2)+10,xy(1)-10:xy(1)+10) = true;
        overlayImage = imoverlay(mat2gray(I2), IG(:,:), [1,1,0]);
        figure; imagesc(overlayImage);
        %}
        
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
        title(strcat(files(i).name, ' ', list_files(j).name));
        
        I4 = r(idx).Image;
        %figure('units','normalized','outerposition',[0 0 0.43 1]); imagesc(I4);colormap gray;
        hold on;
        I4 = r(idx2).Image;
        %figure('units','normalized','outerposition',[0 0 0.43 1]); imagesc(I4);colormap gray;
     end
end


 

