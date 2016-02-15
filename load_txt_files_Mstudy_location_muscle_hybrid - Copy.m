Source = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_LOCATION\Mstudy\Case Log.txt'; 

SourceData = 'C:\Users\John Mauceri\Desktop\Mstudy\';

DEBUG = 1;
MIN_MUSCLE_ANGLE = 30;
MAX_MUSCLE_ANGLE = 85;
EDGE_BOARDER_RATIO = 40/60;

FILTER_ANGLE = -60;
filt1 = [ones(100,200);-1*ones(150,200)];
filt2 = imrotate(filt1,FILTER_ANGLE);

FID = fopen(Source);
fgetl(FID);
C = textscan(FID, '%s %s %s %f %f %f');
fclose(FID);

tmp = strrep(C{1, 1}, 'UCSD', '');
filename = strcat(SourceData, tmp, '\', tmp, '_', C{1, 2}, '*MLO*.dcm');
fn = strcat(SourceData, tmp);
M = C(4:end);
M = cell2mat(M);
[m, n] = size(M);
side = C{3};
location = C{4};
cmfn = C{5};
    
for i = 1:m
    i
    files = dir(filename{i});
    for file = files'
                I = dicomread(fullfile(fn{i}, file.name));
                INFO = dicominfo(fullfile(fn{i}, file.name));
                if (INFO.PatientOrientation(1) == 'A')
                  I = fliplr(I);
                end
                if (DEBUG==1) figure; imagesc(I); colormap gray; end;
            
                height = INFO.Height;
                width = INFO.Width;

                im3=medfilt2(I,[31 31]);
                BW=imfilter(im3,filt2);
                if (DEBUG==1) figure; imagesc(BW);colormap gray; end;
                
                %remove noise on image boarder
                BW(:,width-5:width)=0;
                BW(1:20,:)=0;
                BW(height-20:height,:)=0;
                if (DEBUG==1) figure; imagesc(BW);colormap gray; end;    
                
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
                P  = houghpeaks(H,10,'threshold',ceil(0.5*max(H(:))));
                x = T(P(:,2)); y = R(P(:,1));
                % Find lines and plot them
                lines = houghlines(BW,T,R,P,'FillGap',5,'MinLength',7);
                figure, imagesc(I), colormap gray, hold on;
                max_len = 0;
                for k = 1:length(lines)
                    xy = [lines(k).point1; lines(k).point2];
                    plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');

                    % Plot beginnings and ends of lines
                    plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
                    plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
            
                    % Determine the endpoints of the longest line segment
                    angl = atan((xy(1,2)-xy(2,2))/(xy(1,1)-xy(2,1)))*180/pi;
                    if ((angl > MIN_MUSCLE_ANGLE) && (angl < MAX_MUSCLE_ANGLE))
                        len = norm(lines(k).point1 - lines(k).point2);
                                               
                        % Eliminate lines closer to boarder then right edge
                        dist2edge = double(width - xy(2,1));
                        dist2boarder = double(xy(2,1) - find(Iboundary(int16(xy(2,2)),:), 1, 'last'));
                        if ((dist2boarder / dist2edge) > EDGE_BOARDER_RATIO)
                            plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','cyan');
                            if ( len > max_len)
                               max_len = len;
                               xy_long = xy;
                            end
                        end
                    end
                end
                % highlight the longest line segment
                if (max_len > 0) plot(xy_long(:,1),xy_long(:,2),'LineWidth',2,'Color','blue'); end;
                %END ADJUSTED MATLAB CODE FOR USING HOUGHLINES
                title(strrep(file.name(1:40), '_', ' '));
    end
end

  