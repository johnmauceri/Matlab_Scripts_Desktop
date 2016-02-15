% Input I - Image
%       DEBUG - [optional] Debug info displayed [0-2], default 0.
% Output
%       Iremove - Image with device removed.
%       Imask - Mask of device.
function [Iremove Imask] = linear_clamp_finder(I, DEBUG)

filt1 = [ones(5,25);-1*ones(5,25)];
MUSCLE_START_THRESHOLD = 0.40;
PERCENT_WHITE = 0.40;
PERCENT_WHITE2 = 0.05;
MIN_MUSCLE_ANGLE = -4;
MAX_MUSCLE_ANGLE = 4;

%Resize for speed and filter
height=size(I,1);
width=size(I,2);
BW=imfilter(imresize(double(I),0.25),filt1, 'replicate');
%Normalize
BW = (BW - min(min(BW)))/(max(max(BW)) - min(min(BW)));
if (DEBUG==1) figure(1); imagesc(BW);colormap gray; end;

%Threshold Image
%Get top black line
mt = MUSCLE_START_THRESHOLD;
while (mt < 1.0)
    BW2 = ~(BW > mt);
    if ((nnz(BW2)/prod(size(BW2))) > PERCENT_WHITE2) break; end;
    mt = mt + 0.01;
end
%Get top white line
mt = MUSCLE_START_THRESHOLD;
while (mt < 1.0)
    BW1 = BW > mt;
    if ((nnz(BW1)/prod(size(BW1))) < PERCENT_WHITE) break; end;
    mt = mt + 0.05;
end
BW = BW1 | BW2;
BW=imresize(BW,4);
if (DEBUG==1) figure(2); imagesc(BW);colormap gray; end;

%START ADJUSTED MATLAB CODE FOR USING HOUGHLINES
[H,T,R] = hough(BW);
P  = houghpeaks(H,20,'threshold',ceil(0.1*max(H(:))));% 5 0.5
% Find lines and plot them
lines = houghlines(BW,T,R,P,'FillGap',5,'MinLength',500);
if (DEBUG>=1) figure(3), imagesc(I), colormap gray, hold on; end;
max_len = 0;
miny = 0;
maxy = height;
for k = 1:length(lines)
    xy = [lines(k).point1; lines(k).point2];
    if (DEBUG>=1) plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green'); end;
    
    % Plot beginnings and ends of lines
    if (DEBUG>=1) plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow'); end;
    if (DEBUG>=1) plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red'); end;
    
    % Determine the endpoints of the longest line segment
    angl = atan((xy(1,2)-xy(2,2))/(xy(1,1)-xy(2,1)))*180/pi;
    if ((angl > MIN_MUSCLE_ANGLE) && (angl < MAX_MUSCLE_ANGLE))
        len = norm(lines(k).point1 - lines(k).point2);
        if (DEBUG>=1) plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','cyan'); end;
        if (len > max_len)
            max_len = len;
            xy_long = xy;
        end
        
        if (xy(1,2) > (height * 7 / 12))
            if (xy(1,2) < maxy) maxy = xy(1,2); end
        elseif (xy(1,2) < (height * 5 / 12))
            if (xy(1,2) > miny) miny = xy(1,2); end
        end
        if (xy(2,2) > (height * 7 / 12))
            if (xy(2,2) < maxy) maxy = xy(2,2); end
        elseif (xy(2,2) < (height * 5 / 12))
            if (xy(2,2) > miny) miny = xy(2,2); end
        end
        
    end
end
% highlight the longest line segment
if (DEBUG>=1) if (max_len > 0)   plot(xy_long(:,1),xy_long(:,2),'LineWidth',2,'Color','blue'); end; end
%END ADJUSTED MATLAB CODE FOR USING HOUGHLINES

%if (max_len > 1000) display(['Found Linear Clamp ', num2str(int16(max_len))]); end
I2 = I;
I2(1:miny+100,:) = 0;
I2(maxy-100:height,:) = 0;
if (DEBUG >= 1) figure(4); imagesc(I2);colormap gray; end
Iremove = I2;
Imask = logical(ones(size(I)));
Imask(1:miny+100,:) = false;
Imask(maxy-100:height,:) = false;
%if (max_len > 1000) continue; end



%Verticle Lines on measuring linear clamp
filt2 = [ones(25,5),-1*ones(25,5)];
BWv=imfilter(imresize(double(Iremove),0.25),filt2, 'replicate');
%Normalize
BWv = (BWv - min(min(BWv)))/(max(max(BWv)) - min(min(BWv)));
if (DEBUG==1) figure(5); imagesc(BWv);colormap gray; end;
BW2v = ~(BWv > MUSCLE_START_THRESHOLD);
BW1v =  (BWv > 0.8);
BWv = BW1v | BW2v;
BWv=imresize(BWv,4);
if (DEBUG==1) figure(6); imagesc(BWv);colormap gray; end;

%START ADJUSTED MATLAB CODE FOR USING HOUGHLINES
[H,T,R] = hough(BWv);
P  = houghpeaks(H,5,'threshold',ceil(0.1*max(H(:))));% 5 0.5
% Find lines and plot them
lines = houghlines(BWv,T,R,P,'FillGap',5,'MinLength',200);
if (DEBUG>=1) figure(7), imagesc(I), colormap gray, hold on; end;
avex = 0;
cnt = 0;
for k = 1:length(lines)
    xy = [lines(k).point1; lines(k).point2];
    if (DEBUG>=1) plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green'); end;
    
    % Plot beginnings and ends of lines
    if (DEBUG>=1) plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow'); end;
    if (DEBUG>=1) plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red'); end;
    
    % Determine the endpoints of the longest line segment
    angl = atan((xy(1,2)-xy(2,2))/(xy(1,1)-xy(2,1)))*180/pi;
    if ((angl > 87) || (angl < -87))
        if (DEBUG>=1) plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','cyan'); end;  
        avex = avex + xy(1,1);
        cnt = cnt + 1;
    end
end
avex = avex / cnt;
minx = 0;
maxx = width;
for k = 1:length(lines)
    xy = [lines(k).point1; lines(k).point2];
    angl = atan((xy(1,2)-xy(2,2))/(xy(1,1)-xy(2,1)))*180/pi;
    if ((angl > 87) || (angl < -87))
        if (xy(1,1) < avex)
            if (xy(1,1) > minx) minx = xy(1,1); end
        else
            if (xy(1,1) < maxx) maxx = xy(1,1); end
        end
        if (xy(2,1) < avex)
            if (xy(2,1) > minx) minx = xy(2,1); end
        else
            if (xy(2,1) < maxx) maxx = xy(2,1); end
        end
    end
end
% highlight the edges of the measuring device
if (DEBUG>=1) if (minx > 0)       plot([minx minx], [1 height],'LineWidth',2,'Color','blue'); end; end
if (DEBUG>=1) if (maxx < width)   plot([maxx maxx], [1 height],'LineWidth',2,'Color','blue'); end; end
%END ADJUSTED MATLAB CODE FOR USING HOUGHLINES

if ((minx ~= 0) && ((width - maxx) > 20) && ((maxx - minx) > 500))
    Iremove(:,1:minx) = 0;
    Iremove(:,maxx:width) = 0;
    Imask(:,1:minx) = 0;
    Imask(:,maxx:width) = 0;
end

end