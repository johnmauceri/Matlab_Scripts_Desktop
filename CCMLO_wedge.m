function [lin, err] = CCMLO_wedge(filenameCC, filenameMLO, Direction, Xin, Yin)
%{
Generate the 6 sets of (x,y) endpts for the Center Line, Min Wedge Line, Max Wedge Line

INPUT
                filenameCC : Path and filename to CC DICOM 
                             (nipple facing left)
                filenameMLO: Path and filename to MLO DICOM
                             (nipple facing left)
                Direction  : 0 CC to MLO
                             1 MLO to CC
                Xin        : X coordinate in starting image
                Yin        : Y coordinate in starting image

OUTPUT lin      x1 y1 (Line)
                x2 y2 (Line)
                x1 y1 (Min Wedge)
                x2 y2 (Min Wedge)
                x1 y1 (Max Wedge)
                x2 y2 (Max Wedge)
%}
DEBUG = 0; %0 - none, 1 - detailed, 2 - plots and saves images
dirDest = pwd;

lin = zeros(6,2);
err = '';

if (~exist(filenameCC, 'file'))
    err = 'ERROR: filenameCC invalid.'; return;
end
if (~exist(filenameMLO, 'file'))
    err = 'ERROR: filenameMLO invalid.'; return;
end
if ((Direction ~= 0) && (Direction ~= 1))
    err = 'ERROR: Direction must be 0 or 1.'; return;
end

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
    
    if ((Xin < 1) || (Xin > width))
        err = 'ERROR: Xin out of bounds.'; return;
    end
    if ((Yin < 1) || (Yin > height))
        err = 'ERROR: Yin out of bounds.'; return;
    end
    
    %Finding Pectoral Muscle in MLO
    if (~isempty(strfind(file, 'MLO')))
        try
            [xy_long max_angl min_angl] = muscle_finder(I, file(45:85), DEBUG);
        catch
            [xy_long max_angl min_angl] = muscle_finder(I);
        end
        max_len = xy_long(1,1);
        if (max_len == 0)
            err = 'ERROR: Could not find Muscle.';
            muscle_angl = 0;
            return;
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
        err = 'ERROR: Empty Matrix.';
        return;
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
        err = 'ERROR: Empty Matrix.';
        return;
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
            
            fn_box = fullfile(dirDest, strcat('MLO', '_BOX.jpg'));
            IC = I;
            IC([(Y-100) (Y-99) (Y+99) (Y+100)],(X-100):(X+100)) = 4000;
            IC((Y-100):(Y+100),[(X-100) (X-99) (X+99) (X+100)]) = 4000;
            if (DEBUG==2) imwrite(mat2gray(IC), fn_box, 'jpg'); end
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
            if ((Xmax - Xmin) > 10)
                for step = Xmin: Xmax
                    out = (((Ymax-Ymin)/(Xmax-Xmin))*(step-Xmin))+Ymin;
                    IC([uint16(out)-1: uint16(out)+1], step) = 4000;
                end
            else
                IC([Ymin:Ymax], [X-1:X+1]) = 4000;
            end
            lin(1,1) = Xmax; lin(1,2) = Ymax; lin(2,1) = Xmin; lin(2,2) = Ymin;
            
            
            %Generate Error Wedges from Muscle Error
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
                end
            end
            lin(3,1) = Xmax; lin(3,2) = Ymax; lin(4,1) = Xmin; lin(4,2) = Ymin;
            
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
                    out = max((((Ymax-Ymin)/(Xmax-Xmin))*(step-Xmin))+Ymin, 2);
                    IC([uint16(out)-1: uint16(out)+1], step) = 4000;
                end
            end
            lin(5,1) = Xmax; lin(5,2) = Ymax; lin(6,1) = Xmin; lin(6,2) = Ymin;
            fn_line = fullfile(dirDest, strcat('MLO', '_LINE.jpg'));
            if (DEBUG==2) imwrite(mat2gray(IC), fn_line, 'jpg'); end
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
            
            fn_box = fullfile(dirDest, strcat('CC', '_BOX.jpg'));
            IC = I;
            IC([(Y-100) (Y-99) (Y+99) (Y+100)],(X-100):(X+100)) = 4000;
            IC((Y-100):(Y+100),[(X-100) (X-99) (X+99) (X+100)]) = 4000;
            if (DEBUG==2) imwrite(mat2gray(IC), fn_box, 'jpg'); end
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
            if ((demaxT == 0) || (demaxB == 0))
                IC([(height-Ymax):(height-Ymin)], [X-1:X+1]) = 4000;
            else
                for step = X-demaxB: X+demaxT
                    if (step > width) continue; end
                    out = height-((((Ymax-Ymin)/(demaxB+demaxT))*(step-(X-demaxB)))+Ymin);
                    if (out > 0) IC([uint16(out)-1: uint16(out)+1], uint16(step)) = 4000; end
                end
            end
            if ((deminT == 0) || (deminB == 0))
                IC([(height-Ymax):(height-Ymin)], [X-1:X+1]) = 4000;
            else
                for step = X-deminB:-1: X+deminT
                    if (step > width) continue; end
                    out = height-((((Ymax-Ymin)/(deminB+deminT))*(step-(X-deminB)))+Ymin);
                    if (out > 0) IC([uint16(out)-1: uint16(out)+1], uint16(step)) = 4000; end
                end
            end
               
            fn_line = fullfile(dirDest, strcat('CC', '_LINE.jpg'));
            if (DEBUG==2) imwrite(mat2gray(IC), fn_line, 'jpg'); end
            
            lin(1,1) = X;        lin(1,2) = height-Ymin; lin(2,1) = X;        lin(2,2) = height-Ymax;
            lin(3,1) = X-deminB; lin(3,2) = height-Ymin; lin(4,1) = X+deminT; lin(4,2) = height-Ymax;
            lin(5,1) = X-demaxB; lin(5,2) = height-Ymin; lin(6,1) = X+demaxT; lin(6,2) = height-Ymax;
        end
    end
    if (DEBUG==2) title(strrep(file(45:84), '_', ' ')); end
end
