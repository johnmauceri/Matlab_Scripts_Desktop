
% Input I - Image
%       file - [optional]  filename of image, default 'TEST'
%       DEBUG - [optional] Debug info displayed [0-2], default 0.
% Output
%       xy_long - x,y endpoints of muscle
%       max_angl - maximum muscle angle (due to ambiguities in image).
%       min_angl - minimum muscle angle (due to ambiguities in image).
function [xy_long max_angl min_angl] = muscle_finder(I, file, DEBUG)
xy_long = 0;
max_angl_err = 0;

if nargin == 1
    file = 'TEST';
    DEBUG = 0;
end

MIN_MUSCLE_ANGLE = 30;
MAX_MUSCLE_ANGLE = 85;
EDGE_BOARDER_RATIO = 55.55/44.44;%60/40 55.55/44.44
MUSCLE_START_THRESHOLD = 0.20;%0.20
PERCENT_WHITE = 0.06; %0.025

FILTER_ANGLE = -60;
filt1 = [ones(25,50);-1*ones(25,50)];
filt2 = imrotate(filt1,FILTER_ANGLE);
%Make filter sum to 1
filt3 = filt2 / (sum(sum(filt2)));

I=double(I(:,:,1));
height=size(I,1);
width=size(I,2);

%remove breast boarder
Iboundary=(imdilate(double(I==0),ones(15)));
BW2 = edge(Iboundary);
BW4 = ~(imdilate(double(BW2==1),ones(100)));
BW2(1:20,:)=0;
BW2(height-20:height,:)=0;

[Iby,Ibx]=find(BW2==1);
[Iby_bot,Ibx_bot]=find(BW2(uint16(0.75 * height):height,:)==1);
if (isempty(Ibx_bot) == 1) [Iby_bot,Ibx_bot]=find(BW2(uint16(0.5 * height):height,:)==1); end
if (isempty(Ibx_bot) == 1) [Iby_bot,Ibx_bot]=find(BW2(uint16(0.25 * height):height,:)==1); end
cleav_y(1) = min(Iby);
cleav_x(1) = min(find(BW2(cleav_y(1),:)));
cleav_x(2) = max(Ibx_bot);
cleav_y(2) = max(find(BW2(:,cleav_x(2))));
cleav_y_sm = uint16(cleav_y * 0.25);
cleav_x_sm = uint16(cleav_x * 0.25);

BW3=ones(size(I));
p = polyfit(cleav_y, cleav_x, 1);
for y = 1:height
    x = uint16(polyval(p,double(y)));
    if (x > 0) BW3(y,x:width) = 0; end
end
BW2 = BW3;
BW2(:,width-50:width)=1;
BW2(height-1000:height,:)=1;
BW2 = ~BW2 & BW4;
%BW2 = ~BW2;
BW2=imresize(BW2, 0.25);

%Resize for speed and filter
BW=imfilter(imresize(double(I),0.25),filt3, 'replicate');
%Normalize
BW = (BW - min(min(BW)))/(max(max(BW)) - min(min(BW)));
BW = BW .* BW2;
if (DEBUG==1) figure(2); imagesc(BW);colormap gray; end;

%Threshold
num_pts = prod(size(BW(cleav_y_sm(1):cleav_y_sm(2),max(cleav_x_sm(1),1):cleav_x_sm(2))));
mt = MUSCLE_START_THRESHOLD;
while (mt < 1.0)
    BW1 = BW > mt;
    if (DEBUG==1) figure(3); imagesc(BW1);colormap gray; end
    if ((nnz(BW1(cleav_y_sm(1):cleav_y_sm(2),max(cleav_x_sm(1),1):cleav_x_sm(2))))/num_pts < PERCENT_WHITE) break; end
    mt = mt + 0.01;
end
BW = BW1;
BW=imresize(BW,4);
if (DEBUG==1) figure(3); imagesc(BW);colormap gray; end;

%remove noise on image boarder
BW(:,width-5:width)=0;
BW(1:20,:)=0;
BW(height-20:height,:)=0;
%figure; imagesc(BW);colormap gray;

%remove TITLE on image
BW(1:800,1:1000) = 0;

%START ADJUSTED MATLAB CODE FOR USING HOUGHLINES
[H,T,R] = hough(BW);
P  = houghpeaks(H,25,'threshold',ceil(0.1*max(H(:))));
% Find lines and plot them
lines = houghlines(BW,T,R,P,'FillGap',5,'MinLength',300);
if (DEBUG>=1) h = figure(4); subplot(1,2,1); imagesc(I); colormap gray;  axis equal tight; subplot(1,2,2); imagesc(I); colormap gray;  hold on; axis equal tight; end
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
            
            
            midy = uint16((xy(1,2)+xy(2,2))/2);
            midx = uint16((xy(2,1)+xy(1,1))/2);
            topy = uint16((xy(1,2)+midy)/2);
            topx = uint16((xy(1,1)+midx)/2);
            boty = uint16((xy(2,2)+midy)/2);
            botx = uint16((xy(2,1)+midx)/2);
            
            cr_top = mean2(double(I(xy(1,2):topy,topx:midx))) / mean2(double(                I(topy:midy,xy(1,1):topx)));
            cr_mid = mean2(double(I(topy:midy,midx:botx))) / mean2(double(                I(midy:boty,topx:midx)));
            cr_bot = mean2(double(I(midy:boty,botx:xy(2,1)))) / mean2(double(                I(boty:xy(2,2),midx:botx)));
            len = double(len) + (2.0 * double((cr_top + cr_mid + cr_bot) / 0.003));
            
            
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
if (DEBUG>=1) hold off; end

if (xy_long ~= 0)
     midy = uint16((xy_long(1,2)+xy_long(2,2))/2);
     midx = uint16((xy_long(2,1)+xy_long(1,1))/2);
     topy = uint16((xy_long(1,2)+midy)/2);
     topx = uint16((xy_long(1,1)+midx)/2);
     boty = uint16((xy_long(2,2)+midy)/2);
     botx = uint16((xy_long(2,1)+midx)/2);
     
     cr_top = mean2(double(I(xy_long(1,2):topy,topx:midx))) / mean2(double(                I(topy:midy,xy_long(1,1):topx)));
     %figure; imagesc(      I(xy_long(1,2):topy,topx:midx));colormap gray; figure; imagesc(I(topy:midy,xy_long(1,1):topx));colormap gray;
     cr_mid = mean2(double(I(topy:midy,midx:botx))) / mean2(double(                I(midy:boty,topx:midx)));
     %figure; imagesc(      I(topy:midy,midx:botx));colormap gray; figure; imagesc(I(midy:boty,topx:midx));colormap gray;
     cr_bot = mean2(double(I(midy:boty,botx:xy_long(2,1)))) / mean2(double(                I(boty:xy_long(2,2),midx:botx)));
     %figure; imagesc(      I(midy:boty,botx:xy_long(2,1)));colormap gray; figure; imagesc(I(boty:xy_long(2,2),midx:botx));colormap gray;
   
     %figure; imagesc(      I(xy_long(1,2):midy,xy_long(1,1):midx));colormap gray;
     %figure; imagesc(      I(topy:boty,topx:botx));colormap gray;
     %figure; imagesc(      I(midy:xy_long(2,2),midx:xy_long(2,1)));colormap gray;
 
     
     cr = uint16((cr_top + cr_mid + cr_bot) / 0.003);
     if (cr < 1500)
         %saveas(h, strcat('H:\birad_fig\', file, '_CR',num2str(cr),'.png'), 'png');
     end
else
     %saveas(h, strcat('H:\birad_fig\', file,'.png'), 'png'); end
end
