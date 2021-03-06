
% Input I - Image
%       file - [optional]  filename of image, default 'TEST'
%       DEBUG - [optional] Debug info displayed [0-2], default 0.
% Output
%       xy_long - x,y endpoints of muscle
%       max_angl - maximum muscle angle (due to ambiguities in image).
%       min_angl - minimum muscle angle (due to ambiguities in image).
function [xy_long max_angl min_angl] = muscle_finder_orig(I, file, DEBUG)
xy_long = 0;
max_angl_err = 0;

if nargin == 1
    file = 'TEST';
    DEBUG = 0;
end

MIN_MUSCLE_ANGLE = 30;
MAX_MUSCLE_ANGLE = 85;
EDGE_BOARDER_RATIO = 60/40;
MUSCLE_START_THRESHOLD = 0.40;
PERCENT_WHITE = 0.10;

FILTER_ANGLE = -60;
filt1 = [ones(25,50);-1*ones(25,50)];
filt2 = imrotate(filt1,FILTER_ANGLE);
%Make filter sum to 1
filt3 = filt2 / (sum(sum(filt2)));

I=double(I(:,:,1));
height=size(I,1);
width=size(I,2);

%Resize for speed and filter
BW=imfilter(imresize(double(I),0.25),filt3, 'replicate');
%Normalize
BW = (BW - min(min(BW)))/(max(max(BW)) - min(min(BW)));
%Threshold
mt = MUSCLE_START_THRESHOLD;
while (mt < 1.0)
    BW1 = BW > mt;
    if ((nnz(BW1)/prod(size(BW1))) < PERCENT_WHITE) break; end;
    mt = mt + 0.05;
end
BW = BW1;
BW=imresize(BW,4);
if (DEBUG==1) figure(5); imagesc(BW);colormap gray; end;

%remove noise on image boarder
BW(:,width-5:width)=0;
BW(1:20,:)=0;
BW(height-20:height,:)=0;
%figure; imagesc(BW);colormap gray;

%remove TITLE on image
BW(1:800,1:1000) = 0;

%remove breast boarder
Iboundary=(imdilate(double(I==0),ones(15)));
BW2 = edge(Iboundary);
BW2(:,width-5:width)=0;
BW2(1:20,:)=0;
BW2(height-20:height,:)=0;
BW2=(imdilate(double(BW2==1),ones(500)));
BW2=~BW2;
if (DEBUG==1) figure(6); imagesc(BW2);colormap gray; end;
if (size(BW) ~= size(BW2)) 
    BW = imresize(BW, size(BW2)) & BW2;
else
    BW = BW & BW2;
end
if (DEBUG==1) figure(7); imagesc(BW);colormap gray; end;


%START ADJUSTED MATLAB CODE FOR USING HOUGHLINES
[H,T,R] = hough(BW);
P  = houghpeaks(H,5,'threshold',ceil(0.5*max(H(:))));
% Find lines and plot them
lines = houghlines(BW,T,R,P,'FillGap',5,'MinLength',300);
if (DEBUG>=1) h = figure(8); imagesc(I); colormap gray; hold on; end;
max_len = 0;
min_angl = 90;
max_angl = 0;
for k = 1:length(lines)
    xy = [lines(k).point1; lines(k).point2];
    if (DEBUG==1) plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green'); end;
    
    % Plot beginnings and ends of lines
    if (DEBUG==1) plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow'); end;
    if (DEBUG==1) plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red'); end;
    
    % Determine the endpoints of the longest line segment
    angl = atan((xy(1,2)-xy(2,2))/(xy(1,1)-xy(2,1)))*180/pi;
    if ((angl > MIN_MUSCLE_ANGLE) && (angl < MAX_MUSCLE_ANGLE))
        len = norm(lines(k).point1 - lines(k).point2);
        
        % Eliminate lines closer to boarder then right edge
        dist2edge = double(width - xy(2,1));
        dist2boarder = double(xy(2,1) - find(Iboundary(int16(xy(2,2)),:), 1, 'last'));
        if ((dist2boarder / dist2edge) > EDGE_BOARDER_RATIO)
            if (DEBUG==1) plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','cyan'); end;
            if ( len > max_len)
                max_len = len;
                xy_long = xy;
            end
            if (angl > max_angl)
                max_angl = angl;
                xy_long_max = xy;
            end
            if (angl < min_angl)
                min_angl = angl;
                xy_long_min = xy;
            end
        end
    end
    
end
if (min_angl == 90) min_angl = 0; end

% highlight the longest line segment
if (DEBUG>=1) if (max_angl > 0)  plot(xy_long_max(:,1),xy_long_max(:,2),'LineWidth',2,'Color','yellow'); end; end
if (DEBUG>=1) if ((min_angl ~= 0) && (min_angl < 90)) plot(xy_long_min(:,1),xy_long_min(:,2),'LineWidth',2,'Color','red'); end; end
if (DEBUG>=1) if (max_len > 0)   plot(xy_long(:,1),xy_long(:,2),'LineWidth',2,'Color','blue'); end; end
%END ADJUSTED MATLAB CODE FOR USING HOUGHLINES
if (DEBUG>=1) title(strrep(file, '_', ' ')); end
if (DEBUG>=1) hold off;
    
if (xy_long == 0) saveas(h, strcat('H:\birad_fig_orig\', file,'.png'), 'png'); end
end
