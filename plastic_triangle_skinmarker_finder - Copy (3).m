% Input I - Image
%       DEBUG - [optional] Debug info displayed [0-2], default 0.
% Output
%       Iremove - Image with device removed.
%       Imask - Mask of device.
function [Iremove Imask] = plastic_triangle_skinmarker_finder(I, DEBUG)

I = zeros(size(I));

FILT_SIZE = 200;
filt1 = make_triangle(FILT_SIZE, 120, -32);
filt1 = imfill(filt1, 'hole');
filt2 = make_triangle(FILT_SIZE, 76, -16);
filt2 = imfill(filt2, 'hole');
filt = filt1 - filt2;

%DEBUG = 1
I(1001:1200,1001:1200) = flipud(filt);

Ismall = imresize(double(I),0.25);
for ang = 180% 0:30:330
    filt_rot = imrotate(filt,ang,'crop');
    filt_rot(filt_rot==0) = -1;%
    filt_rot = imresize(filt_rot,0.25);
    if (DEBUG>=1) figure(2); imagesc(filt_rot);colormap gray; end;
    filt_rot = -1 * filt_rot / (sum(sum(filt_rot)));

    if (DEBUG>=1) figure(4); imagesc(Ismall);colormap gray; end;
    
    step = size(filt_rot,1) - 1;
    J = zeros(size(Ismall));
    for y = 1:5:size(Ismall,1)-step
        for x = 1:5:size(Ismall,2)-step
            BW =  filt_rot .* Ismall(y:y+step,x:x+step);
            BW1 = Ismall(y:y+step,x:x+step) .* Ismall(y:y+step,x:x+step);
            bw1 = sum(BW1(:));                        
            if (bw1 == 0)
                J(y+FILT_SIZE/8,x+FILT_SIZE/8) = 0;
            else
                J(y+FILT_SIZE/8,x+FILT_SIZE/8) =  sum(BW(:)) / bw1;
                figure(7); imagesc(filt_rot);colormap gray;
                figure(8); imagesc(Ismall(y:y+step,x:x+step));colormap gray;
                display([y x]);
                J(y+FILT_SIZE/8,x+FILT_SIZE/8)
            end
        end
    end
    figure(6); imagesc(J);colormap gray;
    
    J = (J - min(min(J)))/(max(max(J)) - min(min(J)));
    J = imresize(J, 4);
    if (DEBUG>=1) figure(5); imagesc(J);colormap gray; end;
max(max(J))
[ix, iy] = find(J == max(max(J)))
if (DEBUG>=1) figure(1); imagesc(I);colormap gray; hold on; end;
if (DEBUG>=1) plot(ix,iy,'x','LineWidth',2,'Color','yellow'); end;
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

