% Input I - Image
%       DEBUG - [optional] Debug info displayed [0-2], default 0.
% Output
%       Iremove - Image with device removed.
%       Mask - Mask of device.
function [Iremove Imask] = implant_finder(I, DEBUG)
width=size(I,2);
height=size(I,1);
se = strel('disk',30,8);
NUM_COUNTOURS = 6;
MIN_NUM_BOARDER_PTS_FOR_IMPLANT = 800;

Iboundary=(imdilate(double(I==0),ones(50)));
IB = I .* uint16(~Iboundary);

if (DEBUG >= 1) figure(1); imagesc(I); colormap gray; end
tic;
Cout = contourcs(double(IB),[3300 4100]);
t1 = toc;
if (t1 > 1) Cout = contourcs(double(IB),[2500 4100]); end
found = 0;
for i = 1:size(Cout,1)
    if (Cout(i).Length > MIN_NUM_BOARDER_PTS_FOR_IMPLANT) found = 1; break; end
end
if (~found) Cout = contourcs(double(IB),[2500 3300]); end

BW = logical(zeros([NUM_COUNTOURS, size(I)]));
maxlen = uint32(zeros(1, NUM_COUNTOURS));
idx = uint32(zeros(1, NUM_COUNTOURS));
num_pt = uint16(zeros(1, NUM_COUNTOURS));
for j = 1:NUM_COUNTOURS
    maxlen(j) = uint16(0);
    idx(j) = uint16(0);
    for i = 1:size(Cout,1)
        if (Cout(i).Length > maxlen(j))
            maxlen(j) = Cout(i).Length; idx(j) = i; end
    end
    Cout(idx(j)).Length = 0;
    
    for i = 1:maxlen(j)
        BW(j, uint16(Cout(idx(j)).Y(i)), uint16(Cout(idx(j)).X(i))) = true;
    end
    %if (DEBUG >= 1) figure(j+1); imagesc(reshape(BW(j,:,:), size(I))); colormap gray; end
    
    BW_right = BW(j,:,width); BW_top = BW(j,1,:); BW_bot = BW(j,height,:);
    BW(j,:,width) = 1; BW(j,1,:) = 1; BW(j,height,:) = 1;
    BW(j,:,:) = imfill(reshape(BW(j,:,:), size(I)), 'holes');
    BW(j,:,width) = BW_right; BW(j,1,:) = BW_top; BW(j,height,:) = BW_bot;
    
    num_pts(j) = nnz(reshape(BW(j,:,:), size(I)));
    
    BW(j,:,:) = imdilate(reshape(BW(j,:,:), size(I)),se);
    BW(j,:,:) = imfill(reshape(BW(j,:,:), size(I)), 'holes');
    %if (DEBUG >= 1) figure(j+1+(2*NUM_COUNTOURS)); imagesc(reshape(BW(j,:,:), size(I))); colormap gray; end
end

max_index = find(num_pts == max(num_pts));
max_index = max_index(1);
Imask = uint16(~reshape(BW(max_index,:,:), size(I)));
Iremove = I .* Imask;
if (DEBUG >= 1) figure(3*NUM_COUNTOURS+2); imagesc(Iremove);colormap gray; end

Ib = find(reshape(BW(max_index,:,:), size(I))==1);
I_mask = I .* uint16(reshape(BW(max_index,:,:), size(I)));
var_msk = var(double(I_mask(Ib)));
mean_msk = mean(double(I_mask(Ib)));
pts = nnz(~Imask);
r = regionprops(~Imask,'Eccentricity', 'Orientation', 'Centroid');
[ymax xmax] = ind2sub(size(I),max(find(Iboundary == 0)));
if ((pts < 40000) || (mean_msk < 3300) || (r.Eccentricity < 0.7) || (abs(r.Orientation) < 83) || ((r.Centroid(2) / ymax) < 0.3) || ((r.Centroid(1) / width) < 0.8))
    Imask(:) = 1;
    Iremove = I;
end

end