% clear;
function [IC] = muscle_finder_function(I)
DEBUG = 0;
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

% I=imread('C:\Users\vikas\Desktop\uncompressed\M01\RMLO.jpg');
I=double(I(:,:,1));
height=size(I,1);
width=size(I,2);
if(1)
    % if (~isempty(strfind(file, 'MLO')))
    
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
    if (DEBUG==1) figure; imagesc(BW);colormap gray; end;
    
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
    if (DEBUG==1) figure; imagesc(BW2);colormap gray; end;
    BW = BW & BW2;
    if (DEBUG==1) figure; imagesc(BW);colormap gray; end;
    
    %START ADJUSTED MATLAB CODE FOR USING HOUGHLINES
    [H,T,R] = hough(BW);
    P  = houghpeaks(H,5,'threshold',ceil(0.5*max(H(:))));
    x = T(P(:,2)); y = R(P(:,1));
    % Find lines and plot them
    lines = houghlines(BW,T,R,P,'FillGap',5,'MinLength',7);
    if (DEBUG==1) figure, imagesc(I), colormap gray, hold on; end;
    max_len = 0;
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
            end
        end
        
    end
    % highlight the longest line segment
    if (DEBUG==1) if (max_len > 0) plot(xy_long(:,1),xy_long(:,2),'LineWidth',2,'Color','blue'); end; end;
    %END ADJUSTED MATLAB CODE FOR USING HOUGHLINES
%     if (DEBUG==1) title(strrep(file(1:40), '_', ' ')); end;
    if (max_len == 0) display('Error Could not find Muscle in file:', file); end

    Ymax=xy_long(1,1);
    Ymin=xy_long(1,2);
    Xmax=xy_long(2,1);
    Xmin=xy_long(2,2);
    
    IC = I;
            if ((Xmax - Xmin) > 10)
                for step1 = Xmin:0.1: Xmax
                    out = (((Ymax-Ymin)/(Xmax-Xmin))*(step1-Xmin))+Ymin;
%                     IC([uint16(out)-1: uint16(out)+1], step1) = 0;
                    IC([uint16(out)-1: uint16(out)+1], step1:end) = 0;
                end
            else
%                 IC([Ymin:Ymax], [X-1:X+1]) = 4000;
                1;
            end

            
end