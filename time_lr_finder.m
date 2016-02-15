function [X, Y, err] = time_lr_finder(filename1, filename2, X1, Y1)
%{
Given a location X1,Y1 in image filename1 find X2,Y2 location in
image filename2

INPUT
                filename1: Path and filename to source image
                           (nipple facing left)
                filename2: Path and filename to target image
                           (nipple facing left)
                           (filename1 and filename2 must both be CC
                            or both be MLO)
                X1       : X coordinate in source image
                Y1       : Y coordinate in source image

OUTPUT
                X        : X coordinate in target image
                Y        : Y coordinate in target image
%}
DEBUG = 2; %0 - none, 1 - detailed, 2 - plots and saves images
dirDest = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Location5';

X2 = 0; Y2 = 0;
err = '';

if (~exist(filename1, 'file'))
    err = 'ERROR: filenameCC invalid.'; return;
end
if (~exist(filename2, 'file'))
    err = 'ERROR: filenameMLO invalid.'; return;
end

if ((~isempty(strfind(filename1, 'CC')) && ~isempty(strfind(filename2, 'MLO'))) ||...
        (~isempty(strfind(filename1, 'MLO')) && ~isempty(strfind(filename2, 'CC'))))
    err = 'ERROR: Both files must be CC or MLO.'; return;
end

for j = 1:2
    X = X1;
    Y = Y1;
    if (j == 1)
        file = filename1;
        dist = 0;
        vert_pct = 0;
    end
    if (j == 2)
        file = filename2;
    end
    
    I = dicomread(file);
    INFO = dicominfo(file);
    if (DEBUG==1) figure; imagesc(I); colormap gray; end;
    
    height = INFO.Height;
    width = INFO.Width;
    
    if ((X1 < 1) || (X1 > width))
        err = 'ERROR: X1 out of bounds.'; return;
    end
    if ((Y1 < 1) || (Y1 > height))
        err = 'ERROR: Y1 out of bounds.'; return;
    end
    
    %Finding Pectoral Muscle in MLO
    if (~isempty(strfind(file, 'MLO')))
        [xy_long max_angl min_angl] = muscle_finder(I, file(45:85), DEBUG);
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
        
        if (DEBUG==2) figure; hold on; plot(Ibx, Iby, '.', x_nip, y_nip, 'o'); end
        
        if (j == 1)
            %Rotate point specified the same angle
            ytmp = Y;
            BW3=BW;
            BW3(:,:)=0;
            BW3(ytmp-1:ytmp+1, X-1:X+1)=1;
            if (max_len > 0) BW3 = rotateAround(BW3, xy_long(2,2), xy_long(2,1), angl); end;
            [ytmp, xtmp] = find(BW3==1);
            if (DEBUG==2) plot(xtmp(1), (double(height) - ytmp(1)), 'X'); end
            dist = xtmp(1) - x_nip;
         
            [ymin ymax] = calc_yminmax(Ibx, Iby, y_nip, height, xtmp(1));
            vert_pct = (ymax - (double(height) - ytmp(1))) / (ymax - ymin);
            
            fn_box = fullfile(dirDest, strcat('MLO', '_BOX.jpg'));
            IC = I;
            IC([(Y-100) (Y-99) (Y+99) (Y+100)],(X-100):(X+100)) = 4000;
            IC((Y-100):(Y+100),[(X-100) (X-99) (X+99) (X+100)]) = 4000;
            if (DEBUG==2) imwrite(mat2gray(IC), fn_box, 'jpg'); end
        end
        
        if (j == 2)
            %Go from MLO to MLO 
            X = x_nip + dist;
            [ymin ymax] = calc_yminmax(Ibx, Iby, y_nip, height, X);
            Y = int16(ymax - (vert_pct * (ymax - ymin)));
            if (DEBUG==2) plot(X, Y, 'X'); end
            Y = double(height) - Y;
            
            %Rotate back to get cancer location on original image
            BW3=BW;
            BW3(:,:)=0;
            BW3(Y-1:Y+1, X-1:X+1)=1;
            if (max_len > 0) BW3 = rotateAround(BW3, xy_long(2,2), xy_long(2,1), -1 * angl); end;
            [ytmp, xtmp] = find(BW3==1);
            X = xtmp(1);
            Y = ytmp(1);
            
            IC = I;
            IC([(Y-100) (Y-99) (Y+99) (Y+100)],(X-100):(X+100)) = 4000;
            IC((Y-100):(Y+100),[(X-100) (X-99) (X+99) (X+100)]) = 4000;
            fn_box = fullfile(dirDest, strcat('MLO', '_BOXOUT.jpg'));
            if (DEBUG==2) imwrite(mat2gray(IC), fn_box, 'jpg'); end
        end
    end
    
    if (~isempty(strfind(file, 'CC')))
        %CC case
        x_nip = min(Ibx);
        y_nip = Iby(find(Ibx==x_nip));
        y_nip = mean(y_nip);
        
        if (DEBUG==2) figure; hold on; plot(Ibx, Iby, '.', x_nip, y_nip, 'o'); end
        
        if (j == 1)
            if (DEBUG==2) plot(X, (double(height) - Y), 'X'); end
            dist = X - x_nip;
            vert_pct = (max(Iby(find(Ibx==X))) - (double(height) - Y)) / (max(Iby(find(Ibx==X))) - min(Iby(find(Ibx==X))));
            
            fn_box = fullfile(dirDest, strcat('CC', '_BOX.jpg'));
            IC = I;
            IC([(Y-100) (Y-99) (Y+99) (Y+100)],(X-100):(X+100)) = 4000;
            IC((Y-100):(Y+100),[(X-100) (X-99) (X+99) (X+100)]) = 4000;
            if (DEBUG==2) imwrite(mat2gray(IC), fn_box, 'jpg'); end
        end
        
        if (j == 2)
            %Go from CC to CC
            X = x_nip + dist;
            Y = int16(max(Iby(find(Ibx==X))) - (vert_pct * (max(Iby(find(Ibx==X))) - min(Iby(find(Ibx==X))))));
            if (DEBUG==2) plot(X, Y, 'X'); end
            Y = double(height) - Y;
            
            IC = I;
            IC([(Y-100) (Y-99) (Y+99) (Y+100)],(X-100):(X+100)) = 4000;
            IC((Y-100):(Y+100),[(X-100) (X-99) (X+99) (X+100)]) = 4000;
            fn_box = fullfile(dirDest, strcat('CC', '_BOXOUT.jpg'));
            if (DEBUG==2) imwrite(mat2gray(IC), fn_box, 'jpg'); end
        end
    end
    if (DEBUG==2) title(strrep(file(45:84), '_', ' ')); end
end
end


function [ymin ymax] = calc_yminmax(Ibx, Iby, y_nip, height, x)
ymin = min(Iby(find(Ibx==x)));
ymax = max(Iby(find(Ibx==x)));
if ((size(ymin,1)==0) || (size(ymax,1)==0) || (ymin > y_nip) || (ymax < y_nip))
    p = polyfit(Iby, Ibx, 2);
    yy = 0:height;
    xx = int16(polyval(p,double(yy)));
    if ((size(ymin,1)==0) || (ymin > y_nip)) ymin = min(find(xx==x)); end
    if (size(ymin,2)==0) ymin = min(find(xx==x+1)); end
    if ((size(ymax,1)==0) || (ymax < y_nip)) ymax = max(find(xx==x)); end
    if (size(ymax,2)==0) ymax = max(find(xx==x+1)); end
end
end
