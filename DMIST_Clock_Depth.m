close all;

Source = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_LOCATION\DMIST\M2.txt'; 
SourceCSV = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_LOCATION\DMIST\dmist_case_location_depth.csv';

SourceData = 'C:\Users\John Mauceri\Desktop\Mstudy2\';

dirDest = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\DMIST';

DEBUG = 0;
depth = [0 0 0];
clock = [0 0 0 0 0 0 0 0 0 0 0];

FID = fopen(SourceCSV);
fgetl(FID);
DATA = textscan(FID, '%s %s %s', 'Delimiter',',');
fclose(FID);
accession = DATA{1};
location = DATA{2};
dep = DATA{3};

 for i = 1: size(accession, 1)
    depth = [0 0 0];
    clock = [0 0 0 0 0 0 0 0 0 0 0 0];
    if ~isempty(strfind(location{i}, '12-1')) clock(1) = 1; end
    if ~isempty(strfind(location{i}, '1-2')) clock(2) = 1; end
    if ~isempty(strfind(location{i}, '2-3')) clock(3) = 1; end
    if ~isempty(strfind(location{i}, '3-4')) clock(4) = 1; end
    if ~isempty(strfind(location{i}, '4-5')) clock(5) = 1; end
    if ~isempty(strfind(location{i}, '5-6')) clock(6) = 1; end
    if ~isempty(strfind(location{i}, '6-7')) clock(7) = 1; end
    if ~isempty(strfind(location{i}, '7-8')) clock(8) = 1; end
    if ~isempty(strfind(location{i}, '8-9')) clock(9) = 1; end
    if ~isempty(strfind(location{i}, '9-10')) clock(10) = 1; end
    if ~isempty(strfind(location{i}, '10-11')) clock(11) = 1; end
    if ~isempty(strfind(location{i}, '11-12')) clock(12) = 1; end
    if ~isempty(strfind(dep{i}, 'osterior')) depth(3) = 1; end
    if ~isempty(strfind(dep{i}, 'nterior')) depth(1) = 1; end
    if ~isempty(strfind(dep{i}, 'entral')) depth(2) = 1; end
    %Only do ones with one Clockface designation 171 of 265.  26 more with
    %greater than 1.
    if (clock(1)+clock(2)+clock(3)+clock(4)+clock(5)+clock(6)+clock(7)+clock(8)+clock(9)+clock(10)+clock(11)+clock(12)~=1) continue; end
    %if depth missing do entire depth of breast
    if (depth(1)+depth(2)+depth(3)==0) depth = [1 1 1]; end
end

FID = fopen(Source);
fgetl(FID);
C = textscan(FID, '%s %s %f %f %f');
fclose(FID);

accession = strcat('\*', C{1, 1}, '*.dcm');
M = C(3:end);
M = cell2mat(M);
[m, n] = size(M);
side = C{2};
location = C{3};
cmfn = C{4};
siz = C{5} / 10;

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
 
    %if (isempty(strfind(fn, 'M00076'))); continue; end;
    
    tmp = strfind(side(i), 'L');
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
            if (~isempty(strfind(file.name, 'MLO')))
                [xy_long max_angl_err] = muscle_finder(I, file.name(1:40), DEBUG);
                max_len = xy_long(1,1);
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
                
                %right and left
                if (location(i) == 12) ybase = y_space(7); end;
                if ((location(i) == 1) || (location(i) == 11)) ybase = y_space(6); end;
                if ((location(i) == 2) || (location(i) == 10)) ybase = y_space(5); end;
                if ((location(i) == 3) || (location(i) == 9)) ybase = y_space(4); end;
                if ((location(i) == 4) || (location(i) == 8)) ybase = y_space(3); end;
                if ((location(i) == 5) || (location(i) == 7)) ybase = y_space(2); end;
                if (location(i) == 6) ybase = y_space(1); end;
                line([x_nip xmax],[y_nip ybase]);
                
                %Rotate endpoints to original image
                x_cancer = x_nip;
                y_cancer = int16(height) - y_nip;
                BW3=BW;
                BW3(:,:)=0;
                BW3(y_cancer-1:y_cancer+1, x_cancer-1:x_cancer+1)=1;
                if (max_len > 0) BW3 = rotateAround(BW3, xy_long(2,2), xy_long(2,1), -1 * angl); end;
                [y_cancer,x_cancer] = find(BW3==1);
                if (isempty(y_cancer) || isempty(x_cancer))
                    display('Warning Cancer off image (no BOX or CIRCLE created), in file:', file.name);
                    title(strrep(file.name(1:40), '_', ' '));
                    continue;
                end
                x_nip_rot = x_cancer(1);
                y_nip_rot = y_cancer(1);
                
                x_cancer = xmax;
                y_cancer = int16(height) - ybase;
                BW3=BW;
                BW3(:,:)=0;
                BW3(y_cancer-1:y_cancer+1, x_cancer-1:x_cancer+1)=1;
                if (max_len > 0) BW3 = rotateAround(BW3, xy_long(2,2), xy_long(2,1), -1 * angl); end;
                [y_cancer,x_cancer] = find(BW3==1);
                if (isempty(y_cancer) || isempty(x_cancer))
                    display('Warning Cancer off image (no BOX or CIRCLE created), in file:', file.name);
                    title(strrep(file.name(1:40), '_', ' '));
                    continue;
                end
                x_end_rot = x_cancer(1);
                y_end_rot = y_cancer(1);
                
                theta = acos((x_end_rot - x_nip_rot) / pdist([x_nip_rot y_nip_rot; x_end_rot y_end_rot]));
                
                delta = (width - x_nip_rot) / 3;
                xa = x_nip_rot; xc = xa + delta; xp = xc + delta; xe = width;
                xstart = xa; xend = xe;
                if ( depth(1) && ~depth(2) && ~depth(3)) xend = xc; end
                if ( depth(1) &&  depth(2) && ~depth(3)) xend = xp; end
                if (~depth(1) &&  depth(2) && ~depth(3)) xstart = xc; xend = xp; end
                if (~depth(1) &&  depth(2) &&  depth(3)) xstart = xc; end
                if (~depth(1) && ~depth(2) &&  depth(3)) xstart = xp; end
                x_cancer1 = xstart;
                x_cancer2 = xend;
                y_cancer1 = int16((xstart - xa) * tan(theta));
                y_cancer2 = int16((xend - xa) * tan(theta));
                if (y_end_rot < y_nip_rot)
                    y_cancer1 = -1 * y_cancer1;
                    y_cancer2 = -1 * y_cancer2;
                end;
                y_cancer1 = y_nip_rot + y_cancer1;
                y_cancer2 = y_nip_rot + y_cancer2;
            
                fn_box = fullfile(dirDest, strcat(file.name(1:40), '_BOX.jpg')); 
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
                
                delta = (width - x_nip) / 3;
                xa = x_nip; xc = xa + delta; xp = xc + delta; xe = width;
                xstart = xa; xend = xe;
                if ( depth(1) && ~depth(2) && ~depth(3)) xend = xc; end
                if ( depth(1) &&  depth(2) && ~depth(3)) xend = xp; end
                if (~depth(1) &&  depth(2) && ~depth(3)) xstart = xc; xend = xp; end
                if (~depth(1) &&  depth(2) &&  depth(3)) xstart = xc; end
                if (~depth(1) && ~depth(2) &&  depth(3)) xstart = xp; end
                x_cancer1 = xstart;
                x_cancer2 = xend;
                y_cancer1 = int16((xstart - xa) * tan(theta));
                y_cancer2 = int16((xend - xa) * tan(theta));
                if (ybase < y_nip)
                    y_cancer1 = -1 * y_cancer1;
                    y_cancer2 = -1 * y_cancer2;
                end;
                y_cancer1 = y_nip + y_cancer1;
                y_cancer2 = y_nip + y_cancer2;
                line([x_cancer1 x_cancer2],[y_cancer1 y_cancer2],'Color',[1,0,0]);
                plot(x_cancer1, y_cancer1, 'X');
                plot(x_cancer2, y_cancer2, 'X');
                y_cancer1 = int16(height) - y_cancer1;
                y_cancer2 = int16(height) - y_cancer2;
                
                fn_box = fullfile(dirDest, strcat(file.name(1:39), '_BOX.jpg'));
            end                       
            title(strrep(file.name(1:40), '_', ' '));
            
            IC = I;
            %Next 3 lines insert cirle to matrix and save file
            IC = zeros(size(I));
            IC = insertShape(IC, 'circle', [(x_cancer1+x_cancer2)/2 (y_cancer1+y_cancer2)/2 pdist([double(x_cancer1) double(y_cancer1); double(x_cancer2) double(y_cancer2)])/2.0], 'LineWidth', 5);
            overlayImage = imoverlay(mat2gray(I), IC(1:size(I,1),1:size(I,2)), [1,0,0]);
            imwrite(overlayImage, fn_box, 'jpg');
            fprintf(fn_location,'%s  %4.0f %4.0f %4.0f\n', file.name, (x_cancer1+x_cancer2)/2, (y_cancer1+y_cancer2)/2, pdist([double(x_cancer1) double(y_cancer1); double(x_cancer2) double(y_cancer2)])/2.0);
        end
    end
end 
fclose(fn_location);