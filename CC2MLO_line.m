function line = CC2MLO_line(filenameCC, filenameMLO, dirDest, XCC, YCC)

Direction = 0;

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

line = zeros(2);

for j = (1+2*Direction):(2+2*Direction)
    %CC to MLO j = 1,2
    %MLO to CC j = 3,4
    
    if ((j == 1) || (j == 4))
        file = filenameCC;
        X = XCC;
        Y = YCC;
    end
    if ((j == 2) || (j == 3))
        file = filenameMLO;
        %X = XMLO;
        %Y = YMLO;
    end
    if ((j == 1) || (j == 3))
        dist = 0;
        found_CC = 0;
        found_MLO = 0;
        store_file = file;
    end
    
    if (~isempty(strfind(file, 'CC'))) found_CC = 1; end;
    if (~isempty(strfind(file, 'MLO'))) found_MLO = 1; end;
    
    I = imread(file);
    %INFO = dicominfo(file);
    %We assume now images come in correctly, nipples facing left
    %if (INFO.PatientOrientation(1) == 'A')
    %    I = fliplr(I);
    %end
    if (DEBUG==1) figure; imagesc(I); colormap gray; end;
    
    %ps = INFO.PixelSpacing;
    %height = INFO.Height;
    %width = INFO.Width;
    height = size(I,1);
    width = size(I,2);
    
    %Finding Pectoral Muscle in MLO
    if (~isempty(strfind(file, 'MLO')))
        
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
        if (DEBUG==1) title(strrep(file(1:40), '_', ' ')); end;
        if (max_len == 0) display('Error Could not find Muscle in file:', file); end
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
        
        if (DEBUG==1) figure; hold on; plot(Ibx, Iby, '.', x_nip, y_nip, 'o'); end
        
        if ((found_CC == 0) && (found_MLO == 1))
            if (~isempty(strfind(file, '_L_'))) X = double(width) - X; end;
            if (INFO.PatientOrientation(1) == 'A') X = double(width) - X; end;
            
            %Rotate point specified the same angle
            ytmp = double(height) - Y;
            BW3=BW;
            BW3(:,:)=0;
            BW3(ytmp-1:ytmp+1, X-1:X+1)=1;
            if (max_len > 0) BW3 = rotateAround(BW3, xy_long(2,2), xy_long(2,1), angl); end;
            [ytmp, xtmp] = find(BW3==1);
            if (DEBUG==1) plot(xtmp(1), double(height) - ytmp(1), 'X'); end
            dist = xtmp(1) - x_nip;
            
            fn_box = fullfile(dirDest, strcat(file(45:84), '_BOX.jpg'));
            IC = I;
            Y = double(height) - Y;
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
            if (DEBUG==1) line([X X],[Ymax Ymin]); end
            
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
                    if (step == Xmin)
                        line(1,1) = Xmin;
                        line(1,2) = out;
                    end
                    if (step == Xmax)
                        line(2,1) = Xmax;
                        line(2,2) = out;
                    end
                end
            else
                IC([Ymin:Ymax], [X-1:X+1]) = 4000;
                line(1,1) = X;
                line(1,2) = Ymin;
                line(2,1) = X;
                line(2,2) = Ymax;
            end
            
            %Note assumes ps(1) & ps(2) the same calc min_dist in cm to fix
            fn_line = fullfile(dirDest, strcat('test', '_LINE.jpg'));
            imwrite(mat2gray(IC), fn_line, 'jpg');
        end
    end
    
    if (~isempty(strfind(file, 'CC')))
        %CC case
        x_nip = min(Ibx);
        y_nip = Iby(find(Ibx==x_nip));
        y_nip = mean(y_nip);
        xmin = min(Ibx); xmax = max(Ibx); ymin = min(Iby); ymax = max(Iby);
        
        if (DEBUG==1) figure; hold on; plot(Ibx, Iby, '.', x_nip, y_nip, 'o'); end
        
        if ((found_CC == 1) && (found_MLO == 0))
            %if (~isempty(strfind(file, '_L_'))) X = double(width) - X; end;
            %if (INFO.PatientOrientation(1) == 'A') X = double(width) - X; end;
            if (DEBUG==1) plot(X, Y, 'X'); end
            dist = X - x_nip;
            
            fn_box = fullfile(dirDest, strcat('test', '_BOX.jpg'));
            IC = I;
            %Y = double(height) - Y;
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
            if (DEBUG==1) line([X X],[Ymax Ymin]); end
            
            IC = I;
            IC([(height-Ymax):(height-Ymin)], [X-1:X+1]) = 4000;
            fn_line = fullfile(dirDest, strcat(file(45:83), '_vs_', store_file(45:84), '_LINE.jpg'));
            imwrite(mat2gray(IC), fn_line, 'jpg');
        end
    end
    if (DEBUG==1) title(strrep(file(45:84), '_', ' ')); end
end
