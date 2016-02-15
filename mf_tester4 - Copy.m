Source_AJ = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Location7\xyradius1_rmnonmatch_hasbothviews.txt';

SourceData = 'C:\Users\John Mauceri\Desktop\Mstudy\';

dirDest = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Location8';

DEBUG = 0;
PERCENT_WHITE = 0.10;

FID = fopen(Source_AJ);
fgetl(FID);
C = textscan(FID, '%s %f %f %f %f');
fclose(FID);
M = C(2:end);
M = cell2mat(M);
directory = cell2mat(C{1, 1});
directory = directory(:,1:6);
filename = strcat(SourceData, directory, '\', C{1, 1}, '*.dcm');

filenameCC = filename(1:2:end);
XCC_AJ = M(1:2:end, 1);
YCC_AJ = M(1:2:end, 2);
RCC_AJ = M(1:2:end, 3);
[m n] = size(filenameCC);

filenameMLO = filename(2:2:end);
XMLO_AJ = M(2:2:end, 1);
YMLO_AJ = M(2:2:end, 2);
RMLO_AJ = M(2:2:end, 3);

fn_error = fopen(fullfile(dirDest, 'error.txt'),'wt');
fprintf(fn_error,'            target filename                          source filename              error (cm)     error wedge (cm)     Flag in/out Circle\n');

for i = 1:m
    i
    %check if either image is magnified and skip
    file = num2str(cell2mat(filenameCC(i)));
    if (isempty(strfind(file, 'M00045'))); continue; end;
    df = dir(file);
    file = strcat(file(1:44), df.name);
    I = dicomread(file);
    Iboundary=(I==0);
    if ((nnz(Iboundary)/prod(size(Iboundary))) < PERCENT_WHITE) 
        display('Skip Magnified Image:', file);
        continue; 
    end;
    file = num2str(cell2mat(filenameMLO(i)));
    df = dir(file);
    file = strcat(file(1:44), df.name);
    I = dicomread(file);
    Iboundary=(I==0);
    if ((nnz(Iboundary)/prod(size(Iboundary))) < PERCENT_WHITE) 
        display('Skip Magnified Image:', file);
        continue; 
    end;
    
    for j = 1:4
        %CC to MLO j = 1,2
        %MLO to CC j = 3,4

        if ((j == 1) || (j == 4))
            file = num2str(cell2mat(filenameCC(i)));
            df = dir(file);
            file = strcat(file(1:44), df.name);
            X = XCC_AJ(i);
            Y = YCC_AJ(i);
        end
        if ((j == 2) || (j == 3))
            file = num2str(cell2mat(filenameMLO(i)));
            df = dir(file);
            file = strcat(file(1:44), df.name);
            X = XMLO_AJ(i);
            Y = YMLO_AJ(i);
        end           
        if ((j == 1) || (j == 3))
            dist = 0;
            found_CC = 0;
            found_MLO = 0;
            store_file = file;
        end     
        
        if (~isempty(strfind(file, 'CC'))) found_CC = 1; end;
        if (~isempty(strfind(file, 'MLO'))) found_MLO = 1; end;
        
        I = dicomread(file);
        INFO = dicominfo(file);
        if (INFO.PatientOrientation(1) == 'A')
            I = fliplr(I);
        end
        if (DEBUG==1) figure; imagesc(I); colormap gray; end;
        
        ps = INFO.PixelSpacing;
        height = INFO.Height;
        width = INFO.Width;
        
        %Finding Pectoral Muscle in MLO
        if (~isempty(strfind(file, 'MLO')))    
            [xy_long max_angl min_angl] = muscle_finder(I, file(45:85), DEBUG); 
            max_len = xy_long(1,1);
            if (max_len == 0) 
                display('Error Could not find Muscle in file:', file);
                muscle_angl = 0;
            else
                muscle_angl = atan((xy_long(1,2)-xy_long(2,2))/(xy_long(1,1)-xy_long(2,1)))*180/pi;
            end
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
        if (~isempty(strfind(file, 'MLO')) && (max_len > 0))
            if ((xy_long(1,1)-xy_long(2,1)) == 0)
                display('No Muscle Rotation in file:', file);
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
            display('Error Empty Matrix in file:', file);
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
            display('Error Empty Matrix in file:', file);
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
        
        if (~isempty(strfind(file, 'MLO')))
            %MLO case
            x_nip = min(Ibx);
            y_nip = Iby(find(Ibx==x_nip));
            y_nip = (max(y_nip) + min(y_nip)) / 2;
            xmin = min(Ibx); xmax = max(Ibx); ymin = min(Iby); ymax = max(Iby);

            if (DEBUG==2) figure; hold on; plot(Ibx, Iby, '.', x_nip, y_nip, 'o'); end
            
            if ((found_CC == 0) && (found_MLO == 1))
                
                %Rotate point specified the same angle
                ytmp = Y;
                BW3=BW;
                BW3(:,:)=0;
                BW3(ytmp-1:ytmp+1, X-1:X+1)=1;
                if (max_len > 0) BW3 = rotateAround(BW3, xy_long(2,2), xy_long(2,1), angl); end;
                [ytmp, xtmp] = find(BW3==1);
                if (DEBUG==2) plot(xtmp(1), (double(height) - ytmp(1)), 'X'); end
                dist = xtmp(1) - x_nip;
                
                fn_box = fullfile(dirDest, strcat(file(45:84), '_BOX.jpg'));
                IC = I;
                IC([(Y-100) (Y-99) (Y+99) (Y+100)],(X-100):(X+100)) = 4000;
                IC((Y-100):(Y+100),[(X-100) (X-99) (X+99) (X+100)]) = 4000;
                imwrite(mat2gray(IC), fn_box, 'jpg');
            end
            
            if ((found_CC == 1) && (found_MLO == 1))
                %Go from CC to MLO
                X = x_nip + dist;
                Ymax = max(Iby(find(Ibx==X)));
                Ymin = min(Iby(find(Ibx==X)));
                if (isempty(Ymax) || isempty(Ymin)) Ymax = ymax; Ymin = ymin; end
                if (Ymax < y_nip)
                    if (max(Iby(find(Ibx==X+1))) < y_nip)
                        Ymax = ymax;
                    else
                        Ymax = max(Iby(find(Ibx==X+1)));
                    end
                    if (isempty(Ymax)) Ymax = ymax; end
                end
                if (Ymin > y_nip)
                    if (min(Iby(find(Ibx==X+1))) >  y_nip)
                        Ymin = ymin;
                    else
                        Ymin = min(Iby(find(Ibx==X+1)));
                    end
                    if (isempty(Ymin)) Ymin = ymin; end
                end
                if (DEBUG==2) line([X X],[Ymax Ymin]); end
                
                %Generate Error Wedges from Muscle Error
                demax = (Ymax-y_nip) * tan(pi/180*(max_angl-muscle_angl)) / cos(pi/180*(max_angl-muscle_angl));
                demin = (Ymax-y_nip) * tan(pi/180*(min_angl-muscle_angl)) / cos(pi/180*(min_angl-muscle_angl));
                if (DEBUG==2)          
                    line([X-demax X+demax],[Ymin Ymax]);
                    line([X-demin X+demin],[Ymin Ymax]);
                end
                sYmax = Ymax;sYmin = Ymin;
                
                
                %Rotate back to get cancer location on original image
                Ymax = height - Ymax;
                Ymin = height - Ymin;
                BW3=BW;
                BW3(:,:)=0;
                
                BW3(Ymax:Ymin, X-1:X+1)=1;
                if (max_len > 0) BW3 = rotateAround(BW3, xy_long(2,2), xy_long(2,1), -1 * angl); end;
                [ytmp, xtmp] = find(BW3==1);
                Xmax = max(xtmp);
                Xmin = min(xtmp);
                Ymax = max(ytmp);
                Ymin = min(ytmp);
                
                IC = I;
                min_dist = 9999;
                Xstore = Xmin;
                Xtmp = XMLO_AJ(i);
                if ((Xmax - Xmin) > 10)
                    for step = Xmin: Xmax
                      out = (((Ymax-Ymin)/(Xmax-Xmin))*(step-Xmin))+Ymin;
                      IC([uint16(out)-1: uint16(out)+1], step) = 4000;
                  
                      %find shorted distance to line easier than rotating
                      if (pdist([Xtmp (YMLO_AJ(i)); step out]) < min_dist) 
                        min_dist = pdist([Xtmp (YMLO_AJ(i)); step out]); 
                        Xstore = step;
                      end
                    end
                else
                    IC([Ymin:Ymax], [X-1:X+1]) = 4000;             
                    min_dist = X - Xtmp; 
                    Xstore = X;
                end   
                if (Xstore == Xmax)
                    for step = Xmax: Xmax+1000
                        out = (((Ymax-Ymin)/(Xmax-Xmin))*(step-Xmin))+Ymin;
                        %find shorted distance to line easier than rotating
                        if (pdist([Xtmp (YMLO_AJ(i)); step out]) < min_dist)
                            min_dist = pdist([Xtmp (YMLO_AJ(i)); step out]);
                            Xstore = step;
                        end
                    end
                end
                    
                
                %Generate Error Wedges from Muscle Error
                min_wedg_dist = 9999;
                Xstore_wdg = Xmin;
                BW3=BW;
                BW3(:,:)=0;
                for step = X-demax: X+demax
                    out = height-((((sYmax-sYmin)/(2*demax))*(step-(X-demax)))+sYmin);
                    if (out > 0 ) BW3([uint16(out)-1: uint16(out)+1], uint16(step)) = 1; end
                end
                if (max_len > 0) BW3 = rotateAround(BW3, xy_long(2,2), xy_long(2,1), -1 * angl); end;
                [ytmp, xtmp] = find(BW3==1);
                Xmax = max(xtmp);
                Xmin = min(xtmp);
                Ymax = max(ytmp);
                Ymin = min(ytmp);
                for step = Xmin: Xmax
                    if (step > width) continue; end
                    out = (((Ymax-Ymin)/(Xmax-Xmin))*(step-Xmin))+Ymin;
                    IC([uint16(out)-1: uint16(out)+1], step) = 4000;
                    if (pdist([XMLO_AJ(i) YMLO_AJ(i); double(step) double(out)]) < min_wedg_dist)
                        min_wedg_dist = pdist([XMLO_AJ(i) YMLO_AJ(i); double(step) double(out)]);
                        Xstore_wdg = step;
                    end
                end
                BW3=BW;
                BW3(:,:)=0;
                for step = X-demin:-1: X+demin
                    out = height-((((sYmax-sYmin)/(2*demin))*(step-(X-demin)))+sYmin);
                    if (out > 0 ) BW3([uint16(out)-1: uint16(out)+1], uint16(step)) = 1; end
                end
                if (max_len > 0) BW3 = rotateAround(BW3, xy_long(2,2), xy_long(2,1), -1 * angl); end;
                [ytmp, xtmp] = find(BW3==1);
                Xmax = max(xtmp);
                Xmin = min(xtmp);
                Ymax = max(ytmp);
                Ymin = min(ytmp);
                for step = Xmin: Xmax
                    if (step > width) continue; end
                    out = (((Ymax-Ymin)/(Xmax-Xmin))*(step-Xmin))+Ymin;
                    IC([uint16(out)-1: uint16(out)+1], step) = 4000;
                    if (pdist([XMLO_AJ(i) YMLO_AJ(i); double(step) double(out)]) < min_wedg_dist)
                        min_wedg_dist = pdist([XMLO_AJ(i) YMLO_AJ(i); double(step) double(out)]);
                        Xstore_wdg = step;
                    end
                end
                if (min_dist < min_wedg_dist)
                    min_wedg_dist = min_dist;
                    Xstore_wdg = Xstore;
                end
                
                %Note assumes ps(1) & ps(2) the same calc min_dist in cm to fix
                fprintf(fn_error,'%s  %s %6.2f            %6.2f            %1.0f\n', file(45:84), store_file(45:83), sign(Xtmp - Xstore) * min_dist * ps(1) / 10, sign(XMLO_AJ(i) - Xstore_wdg) * min_wedg_dist * ps(1) / 10, (abs(Xtmp-Xstore)) <= RMLO_AJ(i));
                fn_line = fullfile(dirDest, strcat(file(45:84), '_vs_', store_file(45:83), '_LINE.jpg'));
                %show box with line to visualize error
                IC([(YMLO_AJ(i)-RMLO_AJ(i)) (YMLO_AJ(i)-RMLO_AJ(i)-1) (YMLO_AJ(i)+RMLO_AJ(i)-1) (YMLO_AJ(i)+RMLO_AJ(i))],(XMLO_AJ(i)-RMLO_AJ(i)):(XMLO_AJ(i)+RMLO_AJ(i))) = 4000;
                IC((YMLO_AJ(i)-RMLO_AJ(i)):(YMLO_AJ(i)+RMLO_AJ(i)),[(XMLO_AJ(i)-RMLO_AJ(i)) (XMLO_AJ(i)-RMLO_AJ(i)-1) (XMLO_AJ(i)+RMLO_AJ(i)-1) (XMLO_AJ(i)+RMLO_AJ(i))]) = 4000;
                imwrite(mat2gray(IC), fn_line, 'jpg');
            end
        end
        
        if (~isempty(strfind(file, 'CC')))
            %CC case
            x_nip = min(Ibx);
            y_nip = Iby(find(Ibx==x_nip));
            y_nip = mean(y_nip);
            xmin = min(Ibx); xmax = max(Ibx); ymin = min(Iby); ymax = max(Iby);
            
            if (DEBUG==2) figure; hold on; plot(Ibx, Iby, '.', x_nip, y_nip, 'o'); end
            
            if ((found_CC == 1) && (found_MLO == 0))
                if (DEBUG==2) plot(X, (double(height) - Y), 'X'); end
                dist = X - x_nip;
                
                fn_box = fullfile(dirDest, strcat(file(45:83), '_BOX.jpg'));
                IC = I;
                IC([(Y-100) (Y-99) (Y+99) (Y+100)],(X-100):(X+100)) = 4000;
                IC((Y-100):(Y+100),[(X-100) (X-99) (X+99) (X+100)]) = 4000;
                imwrite(mat2gray(IC), fn_box, 'jpg');
            end
            
            if ((found_CC == 1) && (found_MLO == 1))
                %Go from MLO to CC
                X = x_nip + dist;
                Ymax = max(Iby(find(Ibx==X)));
                Ymin = min(Iby(find(Ibx==X)));
                if (isempty(Ymax) || isempty(Ymin)) Ymax = ymax; Ymin = ymin; end          
                if (Ymax < y_nip)
                    if (max(Iby(find(Ibx==X+1))) < y_nip)
                        Ymax = ymax;
                    else
                        Ymax = max(Iby(find(Ibx==X+1)));
                    end
                    if (isempty(Ymax)) Ymax = ymax; end
                end
                if (Ymin > y_nip)
                    if (min(Iby(find(Ibx==X+1))) >  y_nip)
                        Ymin = ymin;
                    else
                        Ymin = min(Iby(find(Ibx==X+1)));
                        
                    end
                    if (isempty(Ymin)) Ymin = ymin; end
                end
                if (DEBUG==2) line([X X],[Ymax Ymin]); end
                
                %Generate Error Wedges from Muscle Error
                demax = (Ymax-y_nip) * tan(pi/180*(max_angl-muscle_angl)) / cos(pi/180*(max_angl-muscle_angl));
                demin = (Ymax-y_nip) * tan(pi/180*(min_angl-muscle_angl)) / cos(pi/180*(min_angl-muscle_angl));
                if (DEBUG==2)          
                    line([X-demax X+demax],[Ymin Ymax]);
                    line([X-demin X+demin],[Ymin Ymax]);
                end
                
                IC = I;
                IC([(height-Ymax):(height-Ymin)], [X-1:X+1]) = 4000;
                
                %Generate Error Wedges from Muscle Error
                min_wedg_dist = 9999;
                Xstore_wdg = Xmin;
                for step = X-demax: X+demax
                    if (step > width) continue; end
                    out = height-((((Ymax-Ymin)/(2*demax))*(step-(X-demax)))+Ymin);
                    if (out > 0) IC([uint16(out)-1: uint16(out)+1], uint16(step)) = 4000; end
                    if (pdist([XCC_AJ(i) YCC_AJ(i); double(step) double(out)]) < min_wedg_dist)
                        min_wedg_dist = pdist([XCC_AJ(i) YCC_AJ(i); double(step) double(out)]);
                        Xstore_wdg = step;
                    end
                end
                for step = X-demin:-1: X+demin
                    if (step > width) continue; end
                    out = height-((((Ymax-Ymin)/(2*demin))*(step-(X-demin)))+Ymin);
                    if (out > 0) IC([uint16(out)-1: uint16(out)+1], uint16(step)) = 4000; end
                    if (pdist([XCC_AJ(i) YCC_AJ(i); double(step) double(out)]) < min_wedg_dist)
                        min_wedg_dist = pdist([XCC_AJ(i) YCC_AJ(i); double(step) double(out)]);
                        Xstore_wdg = step;
                    end
                end
                if (abs(Xtmp - X) < min_wedg_dist)
                    min_wedg_dist = abs(Xtmp - X);
                    Xstore_wdg = X;
                end
              
                %show box with line to visualize error 
                IC([(YCC_AJ(i)-RCC_AJ(i)) (YCC_AJ(i)-RCC_AJ(i)-1) (YCC_AJ(i)+RCC_AJ(i)-1) (YCC_AJ(i)+RCC_AJ(i))],(XCC_AJ(i)-RCC_AJ(i)):(XCC_AJ(i)+RCC_AJ(i))) = 4000;
                IC((YCC_AJ(i)-RCC_AJ(i)):(YCC_AJ(i)+RCC_AJ(i)),[(XCC_AJ(i)-RCC_AJ(i)) (XCC_AJ(i)-RCC_AJ(i)-1) (XCC_AJ(i)+RCC_AJ(i)-1) (XCC_AJ(i)+RCC_AJ(i))]) = 4000;
                fn_line = fullfile(dirDest, strcat(file(45:83), '_vs_', store_file(45:84), '_LINE.jpg'));
                imwrite(mat2gray(IC), fn_line, 'jpg');
                
                Xtmp = XCC_AJ(i);
                fprintf(fn_error,'%s  %s %6.2f            %6.2f            %1.0f\n', file(45:83), store_file(45:84), (Xtmp - X) * ps(1) / 10, sign(XCC_AJ(i) - Xstore_wdg) * min_wedg_dist * ps(1) / 10, ((X >= XCC_AJ(i)-RCC_AJ(i)) && (X <= XCC_AJ(i)+RCC_AJ(i))));
            end
        end
        if (DEBUG==2) title(strrep(file(45:84), '_', ' ')); end
    end
end
fclose(fn_error);
