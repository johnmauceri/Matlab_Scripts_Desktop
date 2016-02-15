Source = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_LOCATION\Mstudy\Case Log.txt'; 

SourceData = 'C:\Users\John Mauceri\Desktop\Mstudy\';

SAMPLE_SQUARE = 100;
PERCENT_BLACK = 0.5;
REDUCE_RECT_PCT = 0.25;


FID = fopen(Source);
fgetl(FID);
C = textscan(FID, '%s %s %s %f %f %f');
fclose(FID);

tmp = strrep(C{1, 1}, 'UCSD', '');
filename = strcat(SourceData, tmp, '\', tmp, '_', C{1, 2}, '*.dcm');
fn = strcat(SourceData, tmp);
M = C(4:end);
M = cell2mat(M);
[m, n] = size(M);
side = C{3};
location = C{4};
cmfn = C{5};
    
for i = 1: m
    files = dir(filename{i});
    tmp = strfind(side(i), 'eft');
    rl = isempty(tmp{1});
    for file = files'
        if ((isempty(strfind(file.name, '_L_')) && rl) || (~isempty(strfind(file.name, '_L_')) && ~rl))
            I = dicomread(fullfile(fn{i}, file.name));
            INFO = dicominfo(fullfile(fn{i}, file.name));
            if (INFO.PatientOrientation(1) == 'A')
                I = fliplr(I);
                %I = flipud(I);
            end
            figure; imagesc(I); colormap gray;
            
            ps = INFO.PixelSpacing;
            height = INFO.Height;
            width = INFO.Width;
            
            %play with finding pectoral in MLO
            if (~isempty(strfind(file.name, 'MLO')))
                %Blur image
                I2 = medfilt2(I, [300 300]);
                %find edge
                BW = edge(I2,'canny', .02);
                %remove noise on image boarder
                BW(:,width-5:width)=0;
                BW(1:20,:)=0;
                BW(height-20:height,:)=0;
                figure; imagesc(I2);colormap gray;
                figure; imagesc(BW);colormap gray;     
                
                %remove breast boarder
                Iboundary=(imdilate(double(I==0),ones(15))); 
                BW2 = edge(Iboundary);
                BW2(:,width-5:width)=0;
                BW2(1:20,:)=0;
                BW2(height-20:height,:)=0;
                BW2=(imdilate(double(BW2==1),ones(400)));
                BW2=~BW2;
                figure; imagesc(BW2);colormap gray;
                BW = BW & BW2;
                figure; imagesc(BW);colormap gray;
                
                %connect dots on pectoral muscle
                BW=(imdilate(double(BW==1),ones(15)));
                figure; imagesc(BW);colormap gray;
                
                %START STANDARD MATLAB CODE FOR USING HOUGHLINES
                [H,T,R] = hough(BW);
                P  = houghpeaks(H,10,'threshold',ceil(0.5*max(H(:))));
                x = T(P(:,2)); y = R(P(:,1));
                % Find lines and plot them
                lines = houghlines(BW,T,R,P,'FillGap',5,'MinLength',7);
                figure, imagesc(I), colormap gray, hold on
                max_len = 0;
                for k = 1:length(lines)
                    xy = [lines(k).point1; lines(k).point2];
                    plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');

                    % Plot beginnings and ends of lines
                    plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
                    plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');

                    % Determine the endpoints of the longest line segment
                    len = norm(lines(k).point1 - lines(k).point2);
                    if ( len > max_len)
                        max_len = len;
                        xy_long = xy;
                    end
                end
                % highlight the longest line segment
                plot(xy_long(:,1),xy_long(:,2),'LineWidth',2,'Color','blue');
                %END STANDARD MATLAB CODE FOR USING HOUGHLINES
            end
            
            Iboundary=(imdilate(double(I==0),ones(15)));
            %figure; imagesc(Iboundary);colormap gray;
                
            BW = edge(Iboundary);
            %figure; imagesc(BW); colormap gray;
            
            %For MLO rotate to align Pectoral Muscle
            if (~isempty(strfind(file.name, 'MLO')))
                BW = rotateAround(BW, xy_long(2,2), xy_long(2,1), -90+atan((xy_long(1,2)-xy_long(2,2))/(xy_long(1,1)-xy_long(2,1)))*180/pi);
                figure; imagesc(BW); colormap gray;
            end
                
            [Iby,Ibx]=find(BW==1);
            Iby = double(height) - Iby;

            %remove below cleavage
            jnk = BW(height/2:end,:);
            %figure; imagesc(jnk); colormap gray;
            [Ibyc,Ibxc]=find(jnk==1);
            cleav_x = max(Ibxc);
            tmp1 = Iby(find(Ibx==cleav_x)); 
            tmp1 = tmp1(tmp1<height/2);
            cleav_y = max(tmp1);
            BW(end-cleav_y:end,:)=0;
            %figure; imagesc(BW); colormap gray;
            [Iby,Ibx]=find(BW==1);
            Iby = double(height) - Iby;
            
            p = polyfit(Iby, Ibx, 2);
            y = min(Iby):1:max(Iby);
            x = polyval(p,double(y));
            
            if (~isempty(strfind(file.name, 'MLO')))
                %MLO case
                x_nip = min(Ibx);
                y_nip = Iby(find(Ibx==x_nip));
                y_nip = mean(y_nip);
                xmax = max(Ibx);
            
                y_space = [(y(1):((y_nip - y(1) + 1) / 3.0): y_nip) (y_nip:((y(end) - y_nip + 1) / 3.0): y(end))];
                y_space(7) = y(end);
            
                figure;
                hold on;
                plot(Ibx, Iby, '.', x, y, x_nip, y_nip, 'o', xmax, y_space, '.');
                
                %Fix error here after rotate MLO needs to be recalculated
                pix_distx = int16(10 * cmfn(i) / ps(1));
                pix_disty = int16(10 * cmfn(i) / ps(2));
                
                %right and left
                if (location(i) == 12) ybase = y_space(7); end;
                if ((location(i) == 1) || (location(i) == 11)) ybase = y_space(6); end;
                if ((location(i) == 2) || (location(i) == 10)) ybase = y_space(5); end;
                if ((location(i) == 3) || (location(i) == 9)) ybase = y_space(4); end;
                if ((location(i) == 4) || (location(i) == 8)) ybase = y_space(3); end;
                if ((location(i) == 5) || (location(i) == 7)) ybase = y_space(2); end;
                if (location(i) == 6) ybase = y_space(1); end;

                theta = acos((xmax - x_nip) / pdist([x_nip y_nip; xmax ybase]));
                x_cancer = pix_distx * cos(theta);
                y_cancer = pix_disty * sin(theta);
                line([x_nip xmax],[y_nip ybase]);
                if (ybase < y_nip) 
                    plot(x_nip + x_cancer, y_nip - y_cancer, 'X');
                else
                    plot(x_nip + x_cancer, y_nip + y_cancer, 'X');
                end
            end
            
            if (~isempty(strfind(file.name, 'CC')))
                %CC case
                x_nip = min(x);
                y_nip = y(find(x==x_nip));
                xmax = max(x);
            
                y_space = [(y(1):((y_nip - y(1) + 1) / 3.0): y_nip) (y_nip:((y(end) - y_nip + 1) / 3.0): y(end))];
                y_space(7) = y(end);
            
                figure;
                hold on;
                plot(Ibx, Iby, '.', x, y, x_nip, y_nip, 'o', xmax, y_space, '.');
                plot(cleav_x, cleav_y, '.');
                
                pix_distx = int16(10 * cmfn(i) / ps(1));
                pix_disty = int16(10 * cmfn(i) / ps(2));
                
                if (rl)
                    %right
                    if (location(i) == 9) ybase = y_space(7); end;
                    if ((location(i) == 10) || (location(i) == 8)) ybase = y_space(6); end;
                    if ((location(i) == 11) || (location(i) == 7)) ybase = y_space(5); end;
                    if ((location(i) == 12) || (location(i) == 6)) ybase = y_space(4); end;
                    if ((location(i) == 1) || (location(i) == 5)) ybase = y_space(3); end;
                    if ((location(i) == 2) || (location(i) == 4)) ybase = y_space(2); end;
                    if (location(i) == 3) ybase = y_space(1); end;
                else
                    %left
                    if (location(i) == 9) ybase = y_space(1); end;
                    if ((location(i) == 10) || (location(i) == 8)) ybase = y_space(2); end;
                    if ((location(i) == 11) || (location(i) == 7)) ybase = y_space(3); end;
                    if ((location(i) == 12) || (location(i) == 6)) ybase = y_space(4); end;
                    if ((location(i) == 1) || (location(i) == 5)) ybase = y_space(5); end;
                    if ((location(i) == 2) || (location(i) == 4)) ybase = y_space(6); end;
                    if (location(i) == 3) ybase = y_space(7); end;
                end
                theta = acos((xmax - x_nip) / pdist([x_nip y_nip; xmax ybase]));
                x_cancer = pix_distx * cos(theta);
                y_cancer = pix_disty * sin(theta);
                line([x_nip xmax],[y_nip ybase]);
                if (ybase < y_nip) 
                    plot(x_nip + x_cancer, y_nip - y_cancer, 'X');
                else
                    plot(x_nip + x_cancer, y_nip + y_cancer, 'X');
                end
            end
            
        end
    end
end 


  
 
