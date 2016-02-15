%*******  Ground Truth Files
SourceGT0 = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Location3\xyradius_auto_Ajay_GOLDEN.txt';
%***************************************

%*******  Ground Truth Files
SourceGT1 = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Location3\xyradius_auto_Noha_S_GOLDEN.txt'; 
SourceGT2 = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Location3\xyradius_auto_Noha_D_GOLDEN.txt'; 
SourceGT3 = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Location3\xyradius_auto_Noha_D_group2_GOLDEN.txt'; 
SourceGT4 = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Location3\xyradius_auto_Noha_D_group3_GOLDEN.txt';
SourceGT5 = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Location3\xyradius_auto_Noha_D_group4_GOLDEN.txt';
SourceGT6 = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Location3\xyradius_auto_Noha_Benign_S_GOLDEN.txt';
SourceGT7 = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Location3\xyradius_auto_Noha_Benign_D_GOLDEN.txt';
SourceGT8 = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Location3\xyradius_auto_Noha_miss_cancer_GOLDEN.txt';
SourceGT9 = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Location3\xyradius_auto_Noha_Benign_D_2_GOLDEN.txt';
SourceGT10 = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Location3\xyradius_auto_Noha_Benign_S_2_GOLDEN.txt';
DestGT = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Location3\mapping.txt';
Boarder = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Location3\boarder.txt';
SourceLookup = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Location3\MBKmasterlist.txt';
%***************************************

%*******  Arjan DataBase
CircleData0 = 'D:\uncompressed\';  %Cancer Screening M1 <=90
%***************************************

%*******  Noha DataBase
CircleData1 = 'C:\Users\John Mauceri\Desktop\Noha\Curemetrix Cancer cases (Screening)\';
CircleData2 = 'C:\Users\John Mauceri\Desktop\Noha\Curemetrix cancer cases (Diagnostic)\';
CircleData3 = 'C:\Users\John Mauceri\Desktop\Noha\Curemetrix Diagnostic cases (2)\';
CircleData4 = 'C:\Users\John Mauceri\Desktop\Noha\Curemetrix Diagnostic cases (3)\';
CircleData5 = 'C:\Users\John Mauceri\Desktop\Noha\Curemetrix Diagnostic Cancer cases (4)\';
CircleData6 = 'C:\Users\John Mauceri\Desktop\Noha\Curemetrix Benign cases (Screening)\';
CircleData7 = 'C:\Users\John Mauceri\Desktop\Noha\Curemetrix Benign cases (Diagnostic)\';
CircleData8 = 'C:\Users\John Mauceri\Desktop\Noha\Missing Cancer Cases\';  %Cancer Screening M1 >90
CircleData9 = 'C:\Users\John Mauceri\Desktop\Noha\Diagnostic Benign Cases (2)\';
CircleData10 = 'C:\Users\John Mauceri\Desktop\Noha\42416907 (Screening Benign)\';
%***************************************

%*******  Store Ground Truth Results in file
fileID = fopen(DestGT,'wt');
fprintf(fileID,'Accession Side      View Cancer/Benign Screen/Diag X    Y     R   HorzPct VertPct Calc Mass ALN FAsym DAsym GAsym Asym ARCD DD\n');
%***************************************

fileID_Boarder = fopen(Boarder,'wt');

DEBUG = 0; %0 - none, 1 - detailed, 2 - plots and saves images
dirDest = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Location5';

FID = fopen(SourceLookup);
fgetl(FID);
CSV = textscan(FID, '%s');
fclose(FID);

LU = cell2char(CSV{1});

name = repmat(cellstr(''), size(LU,1), 1);
type = repmat(cellstr(''), size(LU,1), 1);
c_b = zeros(size(LU,1), 1);
for i = 1:size(LU,1)
    cnt_ = strfind(LU(i,:), ',');
    name{i} = LU(i,cnt_(2)+1:cnt_(3)-1);
    type{i} = LU(i,cnt_(8)+1:end);
    if (strcmp(LU(i,cnt_(7)+1:cnt_(8)-1), 'Cancer')) c_b(i) = 1; end
end

for i = 0:10 % loop over all of Noha's files                       
    if i == 0 SourceGT = SourceGT0; CircleData = CircleData0; end
    if i == 1 SourceGT = SourceGT1; CircleData = CircleData1; end
    if i == 2 SourceGT = SourceGT2; CircleData = CircleData2; end
    if i == 3 SourceGT = SourceGT3; CircleData = CircleData3; end
    if i == 4 SourceGT = SourceGT4; CircleData = CircleData4; end
    if i == 5 SourceGT = SourceGT5; CircleData = CircleData5; end
    if i == 6 SourceGT = SourceGT6; CircleData = CircleData6; end
    if i == 7 SourceGT = SourceGT7; CircleData = CircleData7; end
    if i == 8 SourceGT = SourceGT8; CircleData = CircleData8; end
    if i == 9 SourceGT = SourceGT9; CircleData = CircleData9; end
    if i == 10 SourceGT = SourceGT10; CircleData = CircleData10; end
    if (strfind(CircleData, 'Diagnostic')) continue; end
    if (size(strfind(CircleData, 'Cancer'),1) || size(strfind(CircleData, 'uncompressed'),1))
        cancer = 1;
    else
        cancer = 0;
    end
    %CircleData
    %fprintf(fileID,'%s\n', CircleData);
    FID = fopen(SourceGT);
    fgetl(FID);
    C = textscan(FID, '%s %f %f %f %f');
    fclose(FID);
    
    storefn = C{1, 1};
    fn_save = C{1, 1};
    storefn = strcat(CircleData,strrep(storefn,'_','\'));
    storefn = strrep(storefn,'&',' ');
    C{1, 1} = strrep(C{1, 1}, '.jpg', '');
    C{1, 1} = strrep(C{1, 1}, '.JPG', '');
    C{1, 1} = strrep(C{1, 1}, '&(', ' (');
    
    fn = cell2char(C{1, 1});
    if (i == 0)
        accession = fn(:, 1:3);
        side = fn(:, 5:5);
        view = fn(:, 6:end);
    else
        accession = fn(:, 1:8);
        side = fn(:, 10:10);
        view = fn(:, 11:end);
    end
    
    M = C(2:end);
    M = cell2mat(M);
    X_GT = M(:, 1);
    Y_GT = M(:, 2);
    R_GT = M(:, 3);
    
    for loop = 1: size(accession,1)   %loop for every one of Noha's circles (multiple per image)
        
        calcs = 0; mass = 0; aln = 0; fasym = 0; dasym = 0; gasym = 0; asym = 0; arcd = 0; dd = 0;
        for i_lu = 1:size(name,1)
            if (strcmp(fn_save(loop,:), cellstr(name{i_lu})) && (cancer == c_b(i_lu)))
                if (strfind(type{i_lu}, 'calcs')) calcs = 1; end
                if (strfind(type{i_lu}, 'mass')) mass = 1; end
                if (strfind(type{i_lu}, 'abnormal-lymph-node')) aln = 1; end
                if (strfind(type{i_lu}, 'focal-ASYM')) fasym = 1; end
                if (strfind(type{i_lu}, 'developing-ASYM')) dasym = 1; end
                if (strfind(type{i_lu}, 'global-ASYM')) dasym = 1; end
                if (strfind(type{i_lu}, 'ASYM'))
                    if (strfind(type{i_lu}, '-ASYM'))
                    else
                        asym = 1;
                    end
                end
                if (strfind(type{i_lu}, 'ARCD')) arcd = 1; end
                if (strfind(type{i_lu}, 'ductal-deb')) dd = 1; end
                break;
            end
        end
        if (calcs+mass+aln+fasym+dasym+gasym+asym+arcd+dd == 0)
            calcs+mass+aln+fasym+dasym+gasym+asym+arcd+dd
        end
        if (i_lu == (size(name,1)+1))
            i_lu
        end
        
        if (~strncmp(view(loop,:), 'CC', 2) && ~strncmp(view(loop,:), 'MLO', 3)) continue; end
        file = storefn{loop};
        if ~exist(file)
            display('Error file not found.', file);
            continue;
        end
        I = imread(file);
        I = I(:,:,1);
        
        X = X_GT(loop);
        Y = Y_GT(loop);
        R = R_GT(loop);
        
        height = size(I, 1);
        width = size(I, 2);
        
        if (size(find(I(100:height-100,100:200)==1),1) / size(find(I(100:height-100,width-200:width-100)==1),1) < 1)
            I = fliplr(I);
        end
        
        %Finding Pectoral Muscle in MLO
        if (~isempty(strfind(file, 'MLO')))
            [xy_long max_angl min_angl] = muscle_finder_jpg(I, ' ', DEBUG);
            max_len = xy_long(1,1);
            if (max_len == 0)
                display('ERROR: Could not find Muscle in file:', file);
                continue;
            else
                muscle_angl = atan((xy_long(1,2)-xy_long(2,2))/(xy_long(1,1)-xy_long(2,1)))*180/pi;
            end
        end
        
        Iboundary=(imdilate(double(I==1),ones(15)));
        Iboundary(:,width-5:width)=0;
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
        jnk = BW(round(height/2):end,:);
        %figure; imagesc(jnk); colormap gray;
        [Ibyc,Ibxc]=find(jnk==1);
        if isempty(Ibxc)
            display('ERROR: Empty Matrix in file', file);
            continue;
        end
        cleav_x = max(Ibxc);
        tmp1 = Iby(find(Ibx==cleav_x));
        tmp1 = tmp1(tmp1<height/2);
        cleav_y = max(tmp1);
        BW(end-cleav_y:end,:)=0;
        if (DEBUG==1) figure; imagesc(BW); colormap gray; end;
        
        %remove other side of breast like cleavage
        jnk = BW(1:round(height/2),:);
        %figure; imagesc(jnk); colormap gray;
        [Ibyc,Ibxc]=find(jnk==1);
        if isempty(Ibxc)
            display('ERROR: Empty Matrix in file', file);
            continue;
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
            
            %Rotate point specified the same angle
            ytmp = Y;
            BW3=BW;
            BW3(:,:)=0;
            BW3(ytmp-1:ytmp+1, X-1:X+1)=1;
            if (max_len > 0) BW3 = rotateAround(BW3, xy_long(2,2), xy_long(2,1), angl); end;
            [ytmp, xtmp] = find(BW3==1);
            if ((size(xtmp,1)==0) || (size(ytmp,1)==0)) 
                display('Location behind muscle in file:', file);
                continue; 
            end
            if (DEBUG==2) plot(xtmp(1), (double(height) - ytmp(1)), 'X'); end
            
            X_bottom_muscle = xy_long(2,1); %since rotating about this point it does not change
            horz_pct = (xtmp(1) - x_nip) / (X_bottom_muscle - x_nip);
            Xmid = int16((X_bottom_muscle + x_nip) / 2);
            [ymin ymax] = calc_yminmax(Ibx, Iby, y_nip, height, xtmp(1));
            [ymidmin ymidmax] = calc_yminmax(Ibx, Iby, y_nip, height, Xmid);
            vert_pct = ((double(height) - ytmp(1)) - ymidmin) / (ymidmax - ymidmin);
            
            fprintf(fileID,'%8s    %s   %8s   %d            %d          %4d %4d %4d %1.4f  %1.4f  %d    %d    %d    %d     %d     %d     %d     %d   %d\n', accession(loop,:), side(loop,:), strrep(view(loop,:), ' (', '&('), cancer, 1, X, Y, R, horz_pct, vert_pct, calcs, mass, aln, fasym, dasym, gasym, asym, arcd, dd);
            
            
            for k = 1:500:size(Ibx, 1)
                horz_pct = (Ibx(k) - x_nip) / (X_bottom_muscle - x_nip);
                [ymin ymax] = calc_yminmax(Ibx, Iby, y_nip, height, Ibx(k));
                vert_pct = (Iby(k) - ymidmin) / (ymidmax - ymidmin);
                fprintf(fileID_Boarder,'%8s    %s   %8s   %d            %d          %4d %4d %4d %1.4f  %1.4f  %d    %d    %d    %d     %d     %d     %d     %d   %d\n', accession(loop,:), side(loop,:), strrep(view(loop,:), ' (', '&('), cancer, 1, X, Y, R, horz_pct, vert_pct, calcs, mass, aln, fasym, dasym, gasym, asym, arcd, dd);
            end
            
            fn_box = fullfile(dirDest, strcat('MLO', '_BOX.jpg'));
            IC = I;
            Xmin = uint16(X - (R / sqrt(2)));
            Xmax = uint16(X + (R / sqrt(2)));
            Ymin = uint16(Y - (R / sqrt(2)));
            Ymax = uint16(Y + (R / sqrt(2)));
            if (Xmin <= 0) Xmin = 1; end
            if (Ymin <= 0) Ymin = 1; end
            IC([Ymin (Ymin+1) (Ymax-1) Ymax],Xmin:Xmax) = 4000;
            IC(Ymin:Ymax,[Xmin (Xmin+1) (Xmax-1) Xmax]) = 4000;
            if (DEBUG==2) imwrite(mat2gray(IC), fn_box, 'jpg'); end  
            %figure(100); imagesc(IC); colormap gray;
        end
        
        if (~isempty(strfind(file, 'CC')))
            %CC case
            x_nip = min(Ibx);
            y_nip = Iby(find(Ibx==x_nip));
            y_nip = mean(y_nip);
            
            if (DEBUG==2) figure; hold on; plot(Ibx, Iby, '.', x_nip, y_nip, 'o'); end
              
            if (DEBUG==2) plot(X, (double(height) - Y), 'X'); end
  
            horz_pct = (X - x_nip) / (width - x_nip);
            Xmid = int16((width + x_nip) / 2);
            [ymin ymax] = calc_yminmax(Ibx, Iby, y_nip, height, X);
            [ymidmin ymidmax] = calc_yminmax(Ibx, Iby, y_nip, height, Xmid);
            vert_pct = ((double(height) - Y) - ymidmin) / (ymidmax - ymidmin);
            
            fprintf(fileID,'%8s    %s   %8s   %d            %d          %4d %4d %4d %1.4f  %1.4f  %d    %d    %d    %d     %d     %d     %d     %d   %d\n', accession(loop,:), side(loop,:), strrep(view(loop,:), ' (', '&('), cancer, 1, X, Y, R, horz_pct, vert_pct, calcs, mass, aln, fasym, dasym, gasym, asym, arcd, dd);
            
           
            for k = 1:500:size(Ibx, 1)
                horz_pct = (Ibx(k) - x_nip) / (width - x_nip);
                Xmid = int16((width + x_nip) / 2);
                [ymin ymax] = calc_yminmax(Ibx, Iby, y_nip, height, X);
                [ymidmin ymidmax] = calc_yminmax(Ibx, Iby, y_nip, height, Xmid);
                vert_pct = (Iby(k) - ymidmin) / (ymidmax - ymidmin);
                fprintf(fileID_Boarder,'%8s    %s   %8s   %d            %d          %4d %4d %4d %1.4f  %1.4f  %d    %d    %d    %d     %d     %d     %d     %d   %d\n', accession(loop,:), side(loop,:), strrep(view(loop,:), ' (', '&('), cancer, 1, X, Y, R, horz_pct, vert_pct, calcs, mass, aln, fasym, dasym, gasym, asym, arcd, dd);
            end
            
            
            fn_box = fullfile(dirDest, strcat('CC', '_BOX.jpg'));
            IC = I;
            Xmin = uint16(X - (R / sqrt(2)));
            Xmax = uint16(X + (R / sqrt(2)));
            Ymin = uint16(Y - (R / sqrt(2)));
            Ymax = uint16(Y + (R / sqrt(2)));
            if (Xmin <= 0) Xmin = 1; end
            if (Ymin <= 0) Ymin = 1; end
            IC([Ymin (Ymin+1) (Ymax-1) Ymax],Xmin:Xmax) = 4000;
            IC(Ymin:Ymax,[Xmin (Xmin+1) (Xmax-1) Xmax]) = 4000;
            if (DEBUG==2) imwrite(mat2gray(IC), fn_box, 'jpg'); end  
            %figure(100); imagesc(IC); colormap gray;
        end   
    end
end
fclose(fileID);
fclose(fileID_Boarder);
%***************************************

   