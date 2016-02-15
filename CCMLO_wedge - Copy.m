function lin = CC2MLO_wedge(filenameCC, filenameMLO, Direction, dirDest, Xin, Yin)

DEBUG = 2;

lin = zeros(2);

fn_error = fopen(fullfile(dirDest, 'error.txt'),'wt');
fprintf(fn_error,'            target filename                          source filename              error (cm)     error wedge (cm)     Flag in/out Circle     Flag Cancer in/out Wedge     Flag Circle in/out Wedge\n');

line_wedge_endpts = fopen(fullfile(dirDest, 'line_wedge_endpts.txt'),'wt');
fprintf(line_wedge_endpts,'            target filename                 x1 y1 x2 y2 Line        x1 y1 x2 y2 Min Wedge     x1 y1 x2 y2 Max Wedge \n');

for j = (1+2*Direction):(2+2*Direction)
    %CC to MLO j = 1,2
    %MLO to CC j = 3,4
    
    if ((j == 1) || (j == 4))
        file = filenameCC;
        X = Xin;
        Y = Yin;
    end
    if ((j == 2) || (j == 3))
        file = filenameMLO;
        X = Xin;
        Y = Yin;
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
    if (DEBUG==1) figure; imagesc(I); colormap gray; end;
    
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
            demaxT = (Ymax-y_nip) * tan(pi/180*(max_angl-muscle_angl)) / cos(pi/180*(max_angl-muscle_angl));
            deminT = (Ymax-y_nip) * tan(pi/180*(min_angl-muscle_angl)) / cos(pi/180*(min_angl-muscle_angl));
            demaxB = (y_nip-Ymin) * tan(pi/180*(max_angl-muscle_angl)) / cos(pi/180*(max_angl-muscle_angl));
            deminB = (y_nip-Ymin) * tan(pi/180*(min_angl-muscle_angl)) / cos(pi/180*(min_angl-muscle_angl));
            if (DEBUG==2)
                line([X X+demaxT],[y_nip Ymax]);
                line([X-demaxB X],[Ymin y_nip]);
                line([X X+deminT],[y_nip Ymax]);
                line([X-deminB X],[Ymin y_nip]);
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
                    if (step == Xmin)
                        lin(1,1) = Xmin;
                        lin(1,2) = out;
                    end
                    if (step == Xmax)
                        lin(2,1) = Xmax;
                        lin(2,2) = out;
                    end
                end
            else
                IC([Ymin:Ymax], [X-1:X+1]) = 4000;
                min_dist = X - Xtmp;
                Xstore = X;
                lin(1,1) = X;
                lin(1,2) = Ymin;
                lin(2,1) = X;
                lin(2,2) = Ymax;
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
            fprintf(line_wedge_endpts,'%s  %4.0f %4.0f    %4.0f %4.0f    ', file(45:84), Xmax, Ymax, Xmin, Ymin);
            
            
            %Generate Error Wedges from Muscle Error
            min_wedg_dist = 9999;
            Xstore_wdg = Xmin;
            BW3=BW;
            BW3(:,:)=0;
            if ((deminT == 0) || (deminB == 0))
                BW3([height-sYmax:height-sYmin], [X-1:X+1]) = 1;
            else
                for step = X-deminB:-1:X+deminT
                    out = height-((((sYmax-sYmin)/(deminB+deminT))*(step-(X-deminB)))+sYmin);
                    if (out > 0 ) BW3([uint16(out)-1: uint16(out)+1], uint16(step)) = 1; end
                end
            end
            if (max_len > 0) BW3 = rotateAround(BW3, xy_long(2,2), xy_long(2,1), -1 * angl); end;
            [ytmp, xtmp] = find(BW3==1);
            Xmax = max(xtmp);
            Xmin = min(xtmp);
            Ymax = max(ytmp);
            Ymin = min(ytmp);
            if ((Xmax - Xmin) > 10)
                for step = Xmin: Xmax
                    if (step > width) continue; end
                    out = (((Ymax-Ymin)/(Xmax-Xmin))*(step-Xmin))+Ymin;
                    IC([uint16(out)-1: uint16(out)+1], step) = 4000;
                    if (pdist([XMLO_AJ(i) YMLO_AJ(i); double(step) double(out)]) < min_wedg_dist)
                        min_wedg_dist = pdist([XMLO_AJ(i) YMLO_AJ(i); double(step) double(out)]);
                        Xstore_wdg = step;
                    end
                end
            else
                if (abs(XMLO_AJ(i) - X) < min_wedg_dist)
                    min_wedg_dist = abs(XMLO_AJ(i) - X);
                    Xstore_wdg = X;
                end
            end
            fprintf(line_wedge_endpts,'%4.0f %4.0f    %4.0f %4.0f    ', Xmax, Ymax, Xmin, Ymin);
            wedgx2 = (double(YMLO_AJ(i)-Ymin)*((Xmax-Xmin)/(Ymax-Ymin)))+Xmin;
            BW3=BW;
            BW3(:,:)=0;
            if ((demaxT == 0) || (demaxB == 0))
                BW3([height-sYmax:height-sYmin], [X-1:X+1]) = 1;
            else
                for step = X-demaxB:X+demaxT
                    out = height-((((sYmax-sYmin)/(demaxB+demaxT))*(step-(X-demaxB)))+sYmin);
                    if (out > 0 ) BW3([uint16(out)-1: uint16(out)+1], uint16(step)) = 1; end
                end
            end
            if (max_len > 0) BW3 = rotateAround(BW3, xy_long(2,2), xy_long(2,1), -1 * angl); end;
            [ytmp, xtmp] = find(BW3==1);
            Xmax = max(xtmp);
            Xmin = min(xtmp);
            Ymax = max(ytmp);
            Ymin = min(ytmp);
            if ((Xmax - Xmin) > 10)
                for step = Xmin: Xmax
                    if (step > width) continue; end
                    out = (((Ymax-Ymin)/(Xmax-Xmin))*(step-Xmin))+Ymin;
                    IC([uint16(out)-1: uint16(out)+1], step) = 4000;
                    if (pdist([XMLO_AJ(i) YMLO_AJ(i); double(step) double(out)]) < min_wedg_dist)
                        min_wedg_dist = pdist([XMLO_AJ(i) YMLO_AJ(i); double(step) double(out)]);
                        Xstore_wdg = step;
                    end
                end
            else
                if (abs(XMLO_AJ(i) - X) < min_wedg_dist)
                    min_wedg_dist = abs(XMLO_AJ(i) - X);
                    Xstore_wdg = X;
                end
            end
            fprintf(line_wedge_endpts,'%4.0f %4.0f    %4.0f %4.0f\n', Xmax, Ymax, Xmin, Ymin);
            
            wedgx1 = (double(YMLO_AJ(i)-Ymin)*((Xmax-Xmin)/(Ymax-Ymin)))+Xmin;
            wedg_flag = 0;
            if ((XMLO_AJ(i) >= wedgx1) && (XMLO_AJ(i) <= wedgx2)) wedg_flag = 1; end
            if ((XMLO_AJ(i) >= wedgx2) && (XMLO_AJ(i) <= wedgx1)) wedg_flag = 1; end
            circ_wedg_flag = 1;
            if ((((XMLO_AJ(i)-RMLO_AJ(i)) < wedgx2) && ((XMLO_AJ(i)+RMLO_AJ(i)) < wedgx2)) && (((XMLO_AJ(i)-RMLO_AJ(i)) < wedgx1) && ((XMLO_AJ(i)+RMLO_AJ(i)) < wedgx1))) circ_wedg_flag = 0; end
            if ((((XMLO_AJ(i)-RMLO_AJ(i)) > wedgx2) && ((XMLO_AJ(i)+RMLO_AJ(i)) > wedgx2)) && (((XMLO_AJ(i)-RMLO_AJ(i)) > wedgx1) && ((XMLO_AJ(i)+RMLO_AJ(i)) > wedgx1))) circ_wedg_flag = 0; end
            
            
            %Note assumes ps(1) & ps(2) the same calc min_dist in cm to fix
            fprintf(fn_error,'%s  %s %6.2f            %6.2f            %1.0f                      %1.0f                            %1.0f\n', file(45:84), store_file(45:83), sign(Xtmp - Xstore) * min_dist * ps(1) / 10, sign(XMLO_AJ(i) - Xstore_wdg) * min_wedg_dist * ps(1) / 10, (abs(Xtmp-Xstore)) <= RMLO_AJ(i), wedg_flag, circ_wedg_flag);
            fn_line = fullfile(dirDest, strcat('test', '_LINE.jpg'));
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
            
            fn_box = fullfile(dirDest, strcat('test', '_BOX.jpg'));
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
            demaxT = (Ymax-y_nip) * tan(pi/180*(max_angl-muscle_angl)) / cos(pi/180*(max_angl-muscle_angl));
            deminT = (Ymax-y_nip) * tan(pi/180*(min_angl-muscle_angl)) / cos(pi/180*(min_angl-muscle_angl));
            demaxB = (y_nip-Ymin) * tan(pi/180*(max_angl-muscle_angl)) / cos(pi/180*(max_angl-muscle_angl));
            deminB = (y_nip-Ymin) * tan(pi/180*(min_angl-muscle_angl)) / cos(pi/180*(min_angl-muscle_angl));
            if (DEBUG==2)
                line([X X+demaxT],[y_nip Ymax]);
                line([X-demaxB X],[Ymin y_nip]);
                line([X X+deminT],[y_nip Ymax]);
                line([X-deminB X],[Ymin y_nip]);
            end
            
            IC = I;
            IC([(height-Ymax):(height-Ymin)], [X-1:X+1]) = 4000;
            
            %Generate Error Wedges from Muscle Error
            min_wedg_dist = 9999;
            Xstore_wdg = Xmin;
            if ((demaxT == 0) || (demaxB == 0))
                IC([(height-Ymax):(height-Ymin)], [X-1:X+1]) = 4000;
                if (abs(XCC_AJ(i) - X) < min_wedg_dist)
                    min_wedg_dist = abs(XCC_AJ(i) - X);
                    Xstore_wdg = X;
                end
            else
                for step = X-demaxB: X+demaxT
                    if (step > width) continue; end
                    out = height-((((Ymax-Ymin)/(demaxB+demaxT))*(step-(X-demaxB)))+Ymin);
                    if (out > 0) IC([uint16(out)-1: uint16(out)+1], uint16(step)) = 4000; end
                    if (pdist([XCC_AJ(i) YCC_AJ(i); double(step) double(out)]) < min_wedg_dist)
                        min_wedg_dist = pdist([XCC_AJ(i) YCC_AJ(i); double(step) double(out)]);
                        Xstore_wdg = step;
                    end
                end
            end
            if ((deminT == 0) || (deminB == 0))
                IC([(height-Ymax):(height-Ymin)], [X-1:X+1]) = 4000;
                if (abs(XCC_AJ(i) - X) < min_wedg_dist)
                    min_wedg_dist = abs(XCC_AJ(i) - X);
                    Xstore_wdg = X;
                end
            else
                for step = X-deminB:-1: X+deminT
                    if (step > width) continue; end
                    out = height-((((Ymax-Ymin)/(deminB+deminT))*(step-(X-deminB)))+Ymin);
                    if (out > 0) IC([uint16(out)-1: uint16(out)+1], uint16(step)) = 4000; end
                    if (pdist([XCC_AJ(i) YCC_AJ(i); double(step) double(out)]) < min_wedg_dist)
                        min_wedg_dist = pdist([XCC_AJ(i) YCC_AJ(i); double(step) double(out)]);
                        Xstore_wdg = step;
                    end
                end
            end
            
            wedgx1 = (double(height-YCC_AJ(i)-Ymin)*((demaxB+demaxT)/(Ymax-Ymin)))+(X-demaxB);
            wedgx2 = (double(height-YCC_AJ(i)-Ymin)*((deminB+deminT)/(Ymax-Ymin)))+(X-deminB);
            wedg_flag = 0;
            if ((XCC_AJ(i) >= wedgx1) && (XCC_AJ(i) <= wedgx2)) wedg_flag = 1; end
            if ((XCC_AJ(i) >= wedgx2) && (XCC_AJ(i) <= wedgx1)) wedg_flag = 1; end
            circ_wedg_flag = 1;
            if ((((XCC_AJ(i)-RCC_AJ(i)) < wedgx2) && ((XCC_AJ(i)+RCC_AJ(i)) < wedgx2)) && (((XCC_AJ(i)-RCC_AJ(i)) < wedgx1) && ((XCC_AJ(i)+RCC_AJ(i)) < wedgx1))) circ_wedg_flag = 0; end
            if ((((XCC_AJ(i)-RCC_AJ(i)) > wedgx2) && ((XCC_AJ(i)+RCC_AJ(i)) > wedgx2)) && (((XCC_AJ(i)-RCC_AJ(i)) > wedgx1) && ((XCC_AJ(i)+RCC_AJ(i)) > wedgx1))) circ_wedg_flag = 0; end
            
            %show box with line to visualize error
            IC([(YCC_AJ(i)-RCC_AJ(i)) (YCC_AJ(i)-RCC_AJ(i)-1) (YCC_AJ(i)+RCC_AJ(i)-1) (YCC_AJ(i)+RCC_AJ(i))],(XCC_AJ(i)-RCC_AJ(i)):(XCC_AJ(i)+RCC_AJ(i))) = 4000;
            IC((YCC_AJ(i)-RCC_AJ(i)):(YCC_AJ(i)+RCC_AJ(i)),[(XCC_AJ(i)-RCC_AJ(i)) (XCC_AJ(i)-RCC_AJ(i)-1) (XCC_AJ(i)+RCC_AJ(i)-1) (XCC_AJ(i)+RCC_AJ(i))]) = 4000;
            fn_line = fullfile(dirDest, strcat(file(45:83), '_vs_', store_file(45:84), '_LINE.jpg'));
            imwrite(mat2gray(IC), fn_line, 'jpg');
            
            Xtmp = XCC_AJ(i);
            fprintf(fn_error,'%s  %s %6.2f            %6.2f            %1.0f                      %1.0f                            %1.0f\n', file(45:83), store_file(45:84), (Xtmp - X) * ps(1) / 10, sign(XCC_AJ(i) - Xstore_wdg) * min_wedg_dist * ps(1) / 10, ((X >= XCC_AJ(i)-RCC_AJ(i)) && (X <= XCC_AJ(i)+RCC_AJ(i))), wedg_flag, circ_wedg_flag);
            fprintf(line_wedge_endpts,'%s   %4.0f %4.0f    %4.0f %4.0f    %4.0f %4.0f    %4.0f %4.0f    %4.0f %4.0f    %4.0f %4.0f\n', file(45:83), X, height-Ymin, X, height-Ymax, X-deminB, height-Ymin, X+deminT, height-Ymax, X-demaxB, height-Ymin, X+demaxT, height-Ymax);
        end
    end
    if (DEBUG==2) title(strrep(file(45:84), '_', ' ')); end
end
fclose(fn_error);
