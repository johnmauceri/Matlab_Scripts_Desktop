% Input I - Image
%       DEBUG - [optional] Debug info displayed [0-2], default 0.
% Output
%       Iremove - Image with device removed.
%       Imask - Mask of device.
function [Iremove Imask] = plastic_triangle_skinmarker_finder(I, DEBUG)

FILTER_ANGLE = -60;

filt1 = make_triangle(200, 120, -32);
filt1 = imfill(filt1, 'hole');
filt2 = make_triangle(200, 76, -16);
filt2 = imfill(filt2, 'hole');
filt = filt1 - filt2;
filt_rot = zeros(12, 200, 200);
ang = 0;
for i = 1:12
    hold = imrotate(filt,ang,'crop');
    hold(hold==0) = -1;
    filt_rot(i,:,:) = hold(:,:);
    %Make filter sum to 1
    filt_rot(i) = filt_rot(i) / (sum(sum(filt_rot(i))));
    ang = ang + 30;
end

for i = 1:12
    BW=imfilter(I,filt_rot(i), 'replicate');
    BW = (BW - min(min(BW)))/(max(max(BW)) - min(min(BW)));
    if (DEBUG>=1) figure(2); imagesc(BW);colormap gray; end;
end


    Imask = 1;
    Iremove = I;
    return;

[BW,thres] = edge(I,'Roberts', 0.01); %0.01
BW=(imdilate(BW,ones(5)));
figure(2); imagesc(BW); colormap gray;

BW = bwlabel(BW);
figure(3); imagesc(BW);
r = regionprops(BW, 'All');
    max1 = size(r(1).PixelList, 1);
    idx = 1;
    for k=2:size(r, 1)
        if ((size(r(k).PixelList,1) > 100))
            BW1 = (BW==k);
            if (DEBUG >= 1) figure(3); imagesc(BW1);colormap gray; end
        end
    end
end