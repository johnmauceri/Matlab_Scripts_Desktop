CircleData = 'C:\Users\John Mauceri\Desktop\Curemetrix Data\uncompressed\';

files = dir(strcat(CircleData,'M*'));


for i = 1:length(files)
    list_files = dir(strcat(CircleData, files(i).name, '\*.jpg'));
    for j = 1:length(list_files)
        strcat(CircleData, files(i).name, '\', list_files(j).name)
        if (list_files(j).name(1) == '.') continue; end;
        I = imread(strcat(CircleData, files(i).name, '\', list_files(j).name));              
        if (list_files(j).name(1) == 'L') I = fliplr(I); end
            
        %figure('units','normalized','outerposition',[0 0 0.43 1]); imagesc(I);colormap gray;
        
        
        I2 = I(:,:,1);
        %{
        I3 = false(size(I2));
        I4 = false(size(I2));
        I3 = (I2==0);
        I4 = (I2>200);
        %}
        
        %BW = bwlabel(imdilate((I2==0) | (I2==204),ones(5,5)));
        BW = bwlabel(imdilate((I2==0), ones(5,5)));
        %figure('units','normalized','outerposition',[0 0 0.43 1]); imagesc(BW);colormap gray;
        r = regionprops(BW, 'Perimeter', 'Centroid', 'PixelList', 'Image');

%{       
        cnt = 1;
        kk = 0;
        pl = 0;
        for k=1:size(r, 1) 
            if (size(r(k).PixelList,1) > 1200) 
                kk(cnt) = k;
                pl(cnt) = size(r(k).PixelList,1);
                cnt = cnt + 1;
            end
        end
        BW2 = kk(1) * (BW==kk(1));
        for k=2:cnt-1
            BW2 = BW2 + kk(1) * (BW==kk(k));
        end
        figure('units','normalized','outerposition',[0 0 0.43 1]); imagesc(BW2);colormap gray;
 %}       
        %imagesc(BW);

        %BW = bwlabel(imdilate(BW2,ones(50,50)));
        %figure('units','normalized','outerposition',[0 0 0.43 1]); imagesc(BW);colormap gray;
        
        %se = strel('disk',2);
        %BW = imclose(BW,se);
        %figure('units','normalized','outerposition',[0 0 0.43 1]); imagesc(BW);colormap gray;
        
        %BW = edge(BW, 'sobel');
        
        %figure('units','normalized','outerposition',[0 0 0.43 1]); imagesc(BW);colormap gray;
        %r = regionprops(BW, 'Perimeter', 'Centroid', 'PixelList', 'Image');
        max = size(r(1).PixelList, 1);
        idx = 1;
        for k=2:size(r, 1) 
            if (size(r(k).PixelList,1) > max) 
                max = size(r(k).PixelList,1); 
                idx = k;
            end
        end
        if (max < 1000) continue; end;
        max2 = size(r(1).PixelList, 1);
        idx2 = 1;
        for k=2:size(r, 1) 
            if (k == idx) continue; end
            if (size(r(k).PixelList,1) > max2) 
                max2 = size(r(k).PixelList,1); 
                idx2 = k;
            end
        end
        %{
        max3 = size(r(1).PixelList, 1);
        idx3 = 1;
        for k=2:size(r, 1) 
            if ((k == idx) || (k == idx2)) continue; end
            if (size(r(k).PixelList,1) > max3) 
                max3 = size(r(k).PixelList,1); 
                idx3 = k;
            end
        end
        %}
        
        BW2 = ((BW == idx) | (BW == idx2));

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
        
        I4 = r(1).Image;
        figure('units','normalized','outerposition',[0 0 0.43 1]); imagesc(I4);colormap gray;
        
        %rect = getrect;
     end
end


 

