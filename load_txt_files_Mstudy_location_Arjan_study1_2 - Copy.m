Source = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_LOCATION\Arjan_study1_2\jenna-for-arjanstudy1&2.txt'; 

SourceData = 'C:\Users\John Mauceri\Desktop\Arjan_study1_2\';

dirDest = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Arjan_study1_2';

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

FID = fopen(Source);
fgetl(FID);
C = textscan(FID, '%s %s %f %f');
fclose(FID);

accession = strcat('\*', C{1, 1}, '*.dcm');
M = C(3:end);
M = cell2mat(M);
[m, n] = size(M);
side = C{2};
location = C{3};
cmfn = C{4};
siz = 2;  %no size given make 2cm x 2cm (Homa)

fn_location = fopen(fullfile(dirDest, 'location.txt'),'wt');
fprintf(fn_location,'            filename                                           x     y     size\n');
    
for i = 1:m
    i
    
    list_dir = dir(SourceData);
    for lp = 1:length(list_dir)
      files = dir(strcat(SourceData, list_dir(lp).name, accession{i}));
      fn = strcat(SourceData, list_dir(lp).name);
      if (~isempty(files)) break; end
    end
    if (isempty(files))
        display('Accession file not found for :', accession{i});
        continue;
    end
 
    %if (isempty(strfind(fn, 'M00014'))); continue; end;
    
    tmp = strfind(side(i), 'eft');
    rl = isempty(tmp{1});
    found_CC = 0;
    found_MLO = 0;
    for file = files'
        %Only look at first CC and MLO.
        %MUST CHECK THIS
        if (isempty(strfind(file.name, '_CC_')) && isempty(strfind(file.name, '_MLO_'))); continue; end;
        if (~isempty(strfind(file.name, '_CC_')) && (found_CC == 1)); continue; end;
        if (~isempty(strfind(file.name, '_MLO_')) && (found_MLO == 1)); continue; end;
        
        if ((isempty(strfind(file.name(1:40), '_L_')) && rl) || (~isempty(strfind(file.name(1:40), '_L_')) && ~rl))
            I = dicomread(fullfile(fn, file.name));
            I = I(:,:,1);
            INFO = dicominfo(fullfile(fn, file.name));
            if (INFO.PatientOrientation(1) == 'A')
                I = fliplr(I);
            end
            if (DEBUG==2) figure; imagesc(I); colormap gray; end;
                
            ps = INFO.PixelSpacing;
            height = INFO.Height;
            width = INFO.Width;
            
            if (~isempty(strfind(file.name, '_CC_'))) found_CC = 1; end;
            if (~isempty(strfind(file.name, '_MLO_'))) found_MLO = 1; end;
            
            %Finding Pectoral Muscle in MLO
            if (~isempty(strfind(file.name, '_MLO_')))
                
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
                if (DEBUG>0) figure, imagesc(I), colormap gray, hold on; end
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
                            if (DEBUG>0) plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','cyan'); end
                            if ( len > max_len)
                               max_len = len;
                               xy_long = xy;
                            end
                        end
                    end
                    
                end
                % highlight the longest line segment
                if (DEBUG>0) if (max_len > 0) plot(xy_long(:,1),xy_long(:,2),'LineWidth',2,'Color','blue'); end; end
                %END ADJUSTED MATLAB CODE FOR USING HOUGHLINES
                if (DEBUG>0) title(strrep(file.name(1:40), '_', ' ')); end
                if (max_len == 0) display('Error Could not find Muscle in file:', file.name); end
            end
            
            Iboundary=(imdilate(double(I==0),ones(15)));
            %Remove Title (ie LCC) from image
            Iboundary=imfill(Iboundary, 'holes');
            %figure; imagesc(Iboundary);colormap gray;
            %Remove stray points
            Iboundary=~imfill(~Iboundary, 'holes');
                
            BW = edge(Iboundary);
            BW(:,width-5:width)=0;
            BW(1:20,:)=0;
            BW(height-20:height,:)=0;
            %figure; imagesc(BW); colormap gray;
            
            %For MLO rotate to align Pectoral Muscle
            angl = 0;
            if (~isempty(strfind(file.name, '_MLO_')) && (max_len > 0))
                if ((xy_long(1,1)-xy_long(2,1)) == 0)
                    display('No Muscle Rotation in file:', file.name);
                else
                    angl = -90+atan((xy_long(1,2)-xy_long(2,2))/(xy_long(1,1)-xy_long(2,1)))*180/pi;
                    BW = rotateAround(BW, xy_long(2,2), xy_long(2,1), angl);
                end
                if (DEBUG==1) figure; imagesc(BW); colormap gray; end;
                BW(:,xy_long(2,1):end) = 0;
                if (DEBUG==1) figure; imagesc(BW); colormap gray; end;
            end
                
            [Iby,Ibx]=find(BW==1);
            Iby = double(height) - Iby;

            %remove below cleavage
            jnk = BW(height/2:end,:);
            %figure; imagesc(jnk); colormap gray;
            [Ibyc,Ibxc]=find(jnk==1);
            if isempty(Ibxc)
                display('Error Empty Matrix in file:', file.name);
                break;
            end
            cleav_x = max(Ibxc);
            tmp1 = Iby(find(Ibx==cleav_x)); 
            tmp1 = tmp1(tmp1<height/2);
            cleav_y = max(tmp1);
            BW(end-cleav_y:end,:)=0;
            if (DEBUG==1) figure; imagesc(BW); colormap gray; end;
            
            %remove other side of breast like cleavage
            jnk = BW(1:height/2,:);
            %figure; imagesc(jnk); colormap gray;
            [Ibyc,Ibxc]=find(jnk==1);
            if isempty(Ibxc)
                display('Error Empty Matrix in file:', file.name);
                break;
            end
            cleav_x = max(Ibxc);
            tmp1 = Iby(find(Ibx==cleav_x)); 
            tmp1 = tmp1(tmp1>height/2);
            cleav_y = min(tmp1);
            BW(1:height-cleav_y,:)=0;
            if (DEBUG==1) figure; imagesc(BW); colormap gray; end;
            
            [Iby,Ibx]=find(BW==1);
            Iby = double(height) - Iby;
            
            %p = polyfit(Iby, Ibx, 2);
            %y = min(Iby):1:max(Iby);
            %x = polyval(p,double(y));
            
            if (~isempty(strfind(file.name, '_MLO_')))
                %MLO case
                x_nip = min(Ibx);
                y_nip = Iby(find(Ibx==x_nip));
                y_nip = (max(y_nip) + min(y_nip)) / 2;
                xmin = min(Ibx); xmax = max(Ibx); ymin = min(Iby); ymax = max(Iby);
            
                y_space = [(ymin:((y_nip - ymin + 1) / 3.0): y_nip) (y_nip:((ymax - y_nip + 1) / 3.0): ymax)];
                y_space(7) = ymax;
            
                figure; hold on; plot(Ibx, Iby, '.', x_nip, y_nip, 'o', xmax, y_space, '.');
                
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
                line([x_nip xmax],[y_nip ybase]);
                
                theta = acos((xmax - x_nip) / pdist([x_nip y_nip; xmax ybase]));
                x_cancer = x_nip + (pix_distx * cos(theta));
                y_cancer = pix_disty * sin(theta);
                if (ybase < y_nip) y_cancer = -1 * y_cancer; end;
                y_cancer = y_nip + y_cancer;
                plot(x_cancer, y_cancer, 'X');   
                
                %Rotate back to get cancer location on original image
                y_cancer = int16(height) - y_cancer;
                BW3=BW;
                BW3(:,:)=0;
                BW3(y_cancer-1:y_cancer+1, x_cancer-1:x_cancer+1)=1;
                if (max_len > 0) BW3 = rotateAround(BW3, xy_long(2,2), xy_long(2,1), -1 * angl); end;
                [y_cancer,x_cancer] = find(BW3==1);
                if (isempty(y_cancer) || isempty(x_cancer))
                    display('Warning Cancer off image (no BOX or CIRCLE created), in file:', file.name);
                    title(strrep(file.name(1:40), '_', ' '));
                    continue;
                else
                    x_cancer = x_cancer(1); y_cancer = y_cancer(1);
                
                    fn_box = fullfile(dirDest, strcat(file.name(1:40), '_BOX.jpg'));
                end
            end
            
            if (~isempty(strfind(file.name, '_CC_')))
                %CC case
                x_nip = min(Ibx);
                y_nip = Iby(find(Ibx==x_nip));
                y_nip = mean(y_nip);
                xmin = min(Ibx); xmax = max(Ibx); ymin = min(Iby); ymax = max(Iby);
            
                y_space = [(ymin:((y_nip - ymin + 1) / 3.0): y_nip) (y_nip:((ymax - y_nip + 1) / 3.0): ymax)];
                y_space(7) = ymax;
            
                figure; hold on; plot(Ibx, Iby, '.', x_nip, y_nip, 'o', xmax, y_space, '.');
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
                line([x_nip xmax],[y_nip ybase]);
                
                theta = acos((xmax - x_nip) / pdist([x_nip y_nip; xmax ybase]));
                x_cancer = x_nip + (pix_distx * cos(theta));
                y_cancer = pix_disty * sin(theta);
                if (ybase < y_nip) y_cancer = -1 * y_cancer; end;
                y_cancer = y_nip + y_cancer;
                plot(x_cancer, y_cancer, 'X');
                y_cancer = int16(height) - y_cancer;
                
                fn_box = fullfile(dirDest, strcat(file.name(1:39), '_BOX.jpg'));
            end                       
            title(strrep(file.name(1:40), '_', ' '));
            
            IC = I;
            %Next 3 lines insert bounding box to matrix and save file
            xsize = int16(10 * siz / (2 * ps(1)));
            ysize = int16(10 * siz / (2 * ps(2)));
            IC([(y_cancer-ysize) (y_cancer-ysize-1) (y_cancer+ysize-1) (y_cancer+ysize)],(x_cancer-xsize):(x_cancer+xsize)) = 4000;
            IC((y_cancer-ysize):(y_cancer+ysize),[(x_cancer-xsize) (x_cancer-xsize-1) (x_cancer+xsize-1) (x_cancer+xsize)]) = 4000;
            imwrite(mat2gray(IC), fn_box, 'jpg');
            fprintf(fn_location,'%s  %4.0f %4.0f %6.4f\n', file.name, x_cancer, y_cancer, siz);
        end
    end
end 
fclose(fn_location);