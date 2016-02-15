% Input I - Image
%       DEBUG - [optional] Debug info displayed [0-2], default 0.
% Output
%       Iremove - Image with device removed.
%       Imask - Mask of device.
function [Iremove Imask] = metal_triangle_skinmarker_finder(I, DEBUG)

if (DEBUG >= 1) figure(1); imagesc(I); colormap gray; end
BW = I < 4000;%4050 4090
BW(1:1000,1:1000) = 1;

BW = bwlabel(~BW);
%r = regionprops(BW, 'PixelList', 'Solidity');
r = regionprops(BW, 'All');
Imask = zeros(size(BW));
for k=1:size(r, 1)
    if ((size(r(k).PixelList,1) > 1100) && (size(r(k).PixelList,1) < 2100) && (r(k).Solidity < 0.20))
        BW1 = (BW==k);
        Imask = Imask | BW1;
        if (DEBUG >= 1) figure(4); imagesc(BW1);colormap gray; end
        display([r(k).Solidity, r(k).BoundingBox(3), r(k).BoundingBox(4), r(k).MajorAxisLength, r(k).MinorAxisLength, r(k).EquivDiameter, r(k).Perimeter]);
    end
end
Imask=(imdilate(Imask,ones(5)));
Imask = ~Imask;
Iremove = uint16(I) .* uint16(Imask);
end

