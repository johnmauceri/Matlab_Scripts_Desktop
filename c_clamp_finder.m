% Input I - Image
%       DEBUG - [optional] Debug info displayed [0-2], default 0.
% Output
%       Iremove - Image with device removed.
%       Imask - Mask of device.
function [Iremove Imask] = c_clamp_finder(I, DEBUG)
for threshold = 4000:-100:3400
    if (DEBUG >= 1) figure(1); imagesc(I); colormap gray; end
    Iboundary=imdilate(double(I>threshold),ones(60)); %15
    %Iboundary=~(imdilate(double(I<2000),ones(50)));
    if (DEBUG >= 2) figure(2); imagesc(Iboundary); colormap gray; end
    %BW = edge(Iboundary);
    %BW = edge(Iboundary,'canny', .02);
    %figure; imagesc(BW); colormap gray;
    
    %Blur image
    %I2 = medfilt2(I, [300 300]);
    %find edge
    %BW = edge(I2,'canny', .02);
    
    %split the linear clamps in 2 pieces for discrimination
    Iboundary(size(I,1)/2,size(I,2)-1000:size(I,2)) = 0;
    BW = Iboundary;
    
    BW = bwlabel(BW);
    r = regionprops(BW, 'PixelList', 'Centroid');
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
y_cent = r(idx).Centroid(2) / size(I,1);
if ((max1 < 500000) || (y_cent < 0.3) || (y_cent > 0.724))
    Imask = ones(size(I));
    Iremove = I;
    return;
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
if (DEBUG >= 2) figure(3); imagesc(BW1);colormap gray; end
BW1 = (imdilate(double(BW1==1),ones(75)));
if (DEBUG >= 2) figure(4); imagesc(BW1);colormap gray; end

BW2 = (BW==idx2);
if (DEBUG >= 2) figure(5); imagesc(BW2);colormap gray; end
BW2 = (imdilate(double(BW2==1),ones(75)));
if (DEBUG >= 2) figure; imagesc(BW2);colormap gray; end

BW3 = (BW==idx3);
if (DEBUG >= 2) figure(6); imagesc(BW3);colormap gray; end
BW3 = (imdilate(double(BW3==1),ones(75)));
if (DEBUG >= 2) figure; imagesc(BW3);colormap gray; end

if (max2 > 250000)
    BW4 = BW1 | BW2;
else
    BW4 = BW1;
end
if (DEBUG >= 2) figure(7); imagesc(BW4);colormap gray; end

if (max3 > 100000)
    BW5 = BW4 | BW3;
else
    BW5 = BW4;
end
if (DEBUG >= 1) figure(8); imagesc(BW5);colormap gray; end
%Imask = BW5;

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
if (DEBUG >= 2) figure(9); imagesc(coutline);colormap gray; end
if ((lasty - firsty)  > 100)
    coutline(1:firsty,:) = 0;
    coutline(lasty:end,:) = 0;
end

Iremove = coutline;
Imask = (coutline ~= 0);
if (DEBUG >= 1)
    figure(10); imagesc(coutline);colormap gray;
    %title(strrep(d2(i2).name(1:min([size(d2(i2).name,2) 40])),'_',' '));
    figure(11); imagesc(Imask);colormap gray;
end

BW6 = I .* uint16(~BW5);
if (DEBUG >= 2) figure(12); imagesc(BW6);colormap gray; end
end
