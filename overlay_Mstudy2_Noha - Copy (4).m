%*******  Ground Truth Files
SourceGT1 = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Location3\xyradius_auto_Noha_S_GOLDEN.txt'; 
SourceGT2 = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Location3\xyradius_auto_Noha_D_GOLDEN.txt'; 
SourceGT3 = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Location3\xyradius_auto_Noha_D_group2_GOLDEN.txt'; 
SourceGT4 = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Location3\xyradius_auto_Noha_D_group3_GOLDEN.txt';
DestGT = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Location3\xyradius_auto_Noha.txt';
%***************************************

%*******  Bills Files
SourceQC = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_TXT\cancer-Mstudy2.dat'; 
SourceQB = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_TXT\benign-Mstudy2.dat';
%***************************************

%*******  Location File
SourceL = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Mstudy2\location - Copy.txt'; 
%***************************************

%*******  DataBase
SourceData = 'C:\Users\John Mauceri\Desktop\Mstudy2\';
%***************************************

%*******  Noha DataBase
CircleData1 = 'C:\Users\John Mauceri\Desktop\Noha\Curemetrix Cancer cases (Screening)\';
CircleData2 = 'C:\Users\John Mauceri\Desktop\Noha\Curemetrix cancer cases (Diagnostic)\';
CircleData3 = 'C:\Users\John Mauceri\Desktop\Noha\Curemetrix Diagnostic cases (2)\';
CircleData4 = 'C:\Users\John Mauceri\Desktop\Noha\Curemetrix Diagnostic cases (3)\';
%***************************************

%*******  Output Image Directory
DestDir = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Overlay\Mstudy2\';
%***************************************

%*******  Store Ground Truth Results in file
fileID = fopen(DestGT,'wt');
fprintf(fileID,'%s %s %s %s %s\n','filename','x','y','rad_pix','size');
%***************************************


% Ground Truth 
cntGT = 1;
filenameGT = cell(1000,1);
XGT = cell(1000,1);
YGT = cell(1000,1);
RGT = cell(1000,1);
for i = 1:4 % loop over all of Noha's files
    i
    if i == 1 SourceGT = SourceGT1; CircleData = CircleData1; end
    if i == 2 SourceGT = SourceGT2; CircleData = CircleData2; end
    if i == 3 SourceGT = SourceGT3; CircleData = CircleData3; end
    if i == 4 SourceGT = SourceGT4; CircleData = CircleData4; end
    FID = fopen(SourceGT);
    fgetl(FID);
    C = textscan(FID, '%s %f %f %f %f');
    fclose(FID);
    
    storefn = C{1, 1};
    storefn = strcat(CircleData,strrep(storefn,'_','\'));
    storefn = strrep(storefn,'&',' ');
    C{1, 1} = strrep(C{1, 1}, '.jpg', '');
    C{1, 1} = strrep(C{1, 1}, '&(', ' (');
    
    fn = cell2char(C{1, 1});
    accession = fn(:, 1:8);
    side = fn(:, 10:10);
    view = fn(:, 11:end);
    
    M = C(2:end);
    M = cell2mat(M);
    X_GT = M(:, 1);
    Y_GT = M(:, 2);
    R_GT = M(:, 3);
    
    directory = dir(SourceData);
    for loop = 1: size(accession,1)   %loop for every one of Noha's circles (multiple per image)
        found = 0;
        for k = 3: size(directory)    %check all Mstudy2 directories for a match
            file = strcat(SourceData, directory(k).name, '\*', accession(loop, 1:end), '*.dcm');
            listing = dir(file);
            for j = 1:size(listing,1) %check each file in each directory for a match
                cnt_ = strfind(listing(j).name, '_');
                side2 = listing(j).name(cnt_(5)+1:cnt_(6)-1);
                view2 = listing(j).name(cnt_(6)+1:cnt_(7)-1);
                filename = strcat(SourceData, directory(k).name, '\',listing(j).name);
                INFO = dicominfo(filename);
                %Until Doug adds Magnification fix to filename I check the
                %dicom and fix myself
                if isfield(INFO.ViewCodeSequence.Item_1.ViewModifierCodeSequence, 'Item_1')
                    if (strcmp(INFO.ViewCodeSequence.Item_1.ViewModifierCodeSequence.Item_1.CodeMeaning, 'Magnification'))
                        view2 = strcat('M', view2);
                    end
                end
                view_clean = strrep(view(loop,1:end),' ','');
                view_clean = strrep(view_clean,'(','');
                view_clean = strrep(view_clean,')','');
                view_clean = strrep(view_clean,'1','');
                view_clean = strrep(view_clean,'2','');
                view_clean = strrep(view_clean,'3','');
                view_clean = strrep(view_clean,'4','');
                view_clean = strrep(view_clean,'5','');
                if (strcmp(side(loop,1), side2) && strcmp(view_clean, view2))
                    %JGMM  Check if image match
                    IN = imread(storefn{loop});
                    IM2 = dicomread(filename);
                    IN = IN(:,:,1);
                    IM2 = IM2(:,:,1);
                    IN = (IN - min(min(IN)))/(max(max(IN)) - min(min(IN)));
                    IM2 = (IM2 - min(min(IM2)))/(max(max(IM2)) - min(min(IM2)));
                    
                    cnt_ = strfind(storefn{loop}, '\');
                    if (storefn{loop}(cnt_(7)+1) == 'L') IN = fliplr(IN); end
                    if (size(IN) ~= size(IM2)) 
                        continue;
                    end
                    Idiff = imabsdiff(IN, IM2);
                    %figure; imagesc(IN); colormap gray;
                    %figure; imagesc(IM2); colormap gray;
                    %figure; imagesc(Idiff); colormap gray;
                    %Idiff = imsubtract(IN, IM2);
                    %Idiff = Idiff > 10; 
                    if (nnz(Idiff) > 300000)
                        %display([nnz(Idiff)]);
                        %display([accession(loop, 1:end), ' ', side2, ' ', view2]);
                        %figure; imagesc(IN); colormap gray;
                        %figure; imagesc(IM2); colormap gray;
                        %figure; imagesc(Idiff); colormap gray;
                        continue;
                    end
                    %JGMM
                    
                    if (found == 1)
                        display(['Multiple dcm from jpg matches ', accession(loop, 1:end), ' ', side2, ' ', view2]);
                    end
                    found = 1;
                    
                    %DICOM Match found beginning
                    filenameGT{cntGT} = [filename];
                    XGT{cntGT} = X_GT(loop);
                    YGT{cntGT} = Y_GT(loop);
                    RGT{cntGT} = R_GT(loop);
                    fprintf(fileID,'%s %4.0f %4.0f %4.0f %4.0f\n', filenameGT{cntGT}(38:end), XGT{cntGT}, YGT{cntGT}, RGT{cntGT}, 0);
        
                    cntGT = cntGT + 1;
                    if (cntGT >= 1000) 
                        display(['!!!cntGT over 1000 make array bigger!!!']); 
                        return;
                    end
                    %DICOM Match found ending

                end
            end 
        end
        if (~found)
            display(['No dcm from jpg match (or flip error) ', accession(loop, 1:end), ' ',side(loop,1), ' ', view_clean]);
        end
    end
end
fclose(fileID);
%***************************************


%{
%Bill's Q Files
% Load Cancer Files
FID = fopen(SourceQC);
C = textscan(FID, '%s %s %f %f %f %f %f %f %f %f');
fclose(FID);
filenameQC = strcat(SourceData, C{1, 2}, '\', C{1, 1});
M = C(3:end);
M = cell2mat(M);
QQC = M(:, 1);
typeQC = M(:, 2);
XQC = M(:, 3);
YQC = M(:, 4);
XminQC = M(:, 5);
XmaxQC = M(:, 6);
YminQC = M(:, 7);
YmaxQC = M(:, 8);
% Load Benign Files
FID = fopen(SourceQB);
C = textscan(FID, '%s %s %f %f %f %f %f %f %f %f');
fclose(FID);
filenameQB = strcat(SourceData, C{1, 2}, '\', C{1, 1});
M = C(3:end);
M = cell2mat(M);
QQB = M(:, 1);
typeQB = M(:, 2);
XQB = M(:, 3);
YQB = M(:, 4);
XminQB = M(:, 5);
XmaxQB = M(:, 6);
YminQB = M(:, 7);
YmaxQB = M(:, 8);
%Group Cancer and Benign together    
filenameQ = cat(1, filenameQB, filenameQC);   
QQ = cat(1, QQB, QQC);
typeQ = cat(1, typeQB, typeQC);
XQ = cat(1, XQB, XQC);
YQ = cat(1, YQB, YQC);
XminQ = cat(1, XminQB, XminQC);
XmaxQ = cat(1, XmaxQB, XmaxQC);
YminQ = cat(1, YminQB, YminQC);
YmaxQ = cat(1, YmaxQB, YmaxQC);
%***************************************
%}
 

% Load Location File
FID = fopen(SourceL);
fgetl(FID);
C = textscan(FID, '%s %f %f %f');
fclose(FID);
directory = cell2char(C{1, 1});
directory = directory(:, 1:6);
filenameL = strcat(SourceData, directory, '\', C{1, 1});
M = C(2:end);
M = cell2mat(M);
XL = M(:, 1);
YL = M(:, 2);
RL = M(:, 3);
%***************************************


%Overlay GT and Location if match
cntL = 0;
for loop = filenameL' %loop over Location
    cntL = cntL + 1;
    file = num2str(cell2mat(loop));
    if ~exist(file)
        display('Error file not found.', file);
        continue
    end
    I = dicomread(file);
    I = I(:,:,1);
    INFO = dicominfo(file);
    if (INFO.PatientOrientation(1) == 'A')
        I = fliplr(I);
    end
    ps = INFO.PixelSpacing;
    height = double(INFO.Height);
      
    for i = 1:cntGT-1
        if strcmp(file, filenameGT{i})
            I2=false(size(I));
            
            xsize = int16((10 * RL(cntL) / (2 * ps(1))) / sqrt(2));
            ysize = int16((10 * RL(cntL) / (2 * ps(2))) / sqrt(2));
            
            Xmin = uint16(XL(cntL) - xsize);
            Xmax = uint16(XL(cntL) + xsize);
            Ymin = uint16(YL(cntL) - ysize);
            Ymax = uint16(YL(cntL) + ysize);
            if (Xmin <= 0) Xmin = 1; end
            I2([Ymin (Ymin+1) (Ymax-1) Ymax],Xmin:Xmax) = true;
            I2(Ymin:Ymax,[Xmin (Xmin+1) (Xmax-1) Xmax]) = true;
            overlayImage = imoverlay(mat2gray(I), I2(1:size(I,1),1:size(I,2)), [0,0,1]);
            
            I2=false(size(I));
            Xmin = uint16(XGT{i} - (RGT{i} / sqrt(2)));
            Xmax = uint16(XGT{i} + (RGT{i} / sqrt(2)));
            Ymin = uint16(YGT{i} - (RGT{i} / sqrt(2)));
            Ymax = uint16(YGT{i} + (RGT{i} / sqrt(2)));
            if (Xmin <= 0) Xmin = 1; end
            I2([Ymin (Ymin+1) (Ymax-1) Ymax],Xmin:Xmax) = true;
            I2(Ymin:Ymax,[Xmin (Xmin+1) (Xmax-1) Xmax]) = true;
            overlayImage = imoverlay(overlayImage, I2(1:size(I,1),1:size(I,2)), [1,1,0]);
            cnt_ = strfind(file, '_');
            %figure; imagesc(overlayImage);
            %title(strrep(file(cnt_(1)-6:cnt_(7)-1), '_', '-'));
            fnout = fullfile(DestDir, strcat(file(cnt_(1)-6:cnt_(7)-1), '_GT_L.jpg'));
            imwrite(overlayImage, fnout, 'jpg');
        end
    end
end
%***************************************



%Scan for duplicates in Bill's files save only highest Q per image
filenameQcopy = filenameQ;
for j = 1:length(filenameQcopy)
    name = filenameQcopy{j};
    if (isempty(name)) continue; end
    Q = QQ(j);
    for k = j+1: length(filenameQcopy)
        name2 = filenameQcopy{k};
        if (isempty(name2)) continue; end
        Q2 = QQ(k);
        if (strcmp(name, name2))
            if (Q2 > Q)
                filenameQcopy{j} = filenameQcopy{k};
                Q = Q2;
            end
            filenameQcopy{k} = '';
        end
    end
end
%***************************************


%Display all Bill's Qs and overlay GT if match
filenameGTcopy = filenameGT;
cntQ = 0;
for loop = filenameQcopy' %loop over Bills
    cntQ = cntQ + 1;
    file = num2str(cell2mat(loop));
    if (isempty(file)) continue; end
    if ~exist(file)
        display('Error file not found.', file);
        continue
    end
    I = dicomread(file);
    I = I(:,:,1);
    INFO = dicominfo(file);
    if (INFO.PatientOrientation(1) == 'A')
        I = fliplr(I);
    end
    
    %check if GT match
    found = 0;
    for i = 1:cntGT-1
        if strcmp(file, filenameGT{i})          
            I2=false(size(I));
            I2([YminQ(cntQ) (YminQ(cntQ)+1) (YmaxQ(cntQ)-1) YmaxQ(cntQ)],XminQ(cntQ):XmaxQ(cntQ)) = true;
            I2(YminQ(cntQ):YmaxQ(cntQ),[XminQ(cntQ) (XminQ(cntQ)+1) (XmaxQ(cntQ)-1) XmaxQ(cntQ)]) = true;
            overlayImage = imoverlay(mat2gray(I), I2(1:size(I,1),1:size(I,2)), [1,0,0]);
            
            I2=false(size(I));
            Xmin = uint16(XGT{i} - (RGT{i} / sqrt(2)));
            Xmax = uint16(XGT{i} + (RGT{i} / sqrt(2)));
            Ymin = uint16(YGT{i} - (RGT{i} / sqrt(2)));
            Ymax = uint16(YGT{i} + (RGT{i} / sqrt(2)));
            if (Xmin <= 0) Xmin = 1; end
            I2([Ymin (Ymin+1) (Ymax-1) Ymax],Xmin:Xmax) = true;
            I2(Ymin:Ymax,[Xmin (Xmin+1) (Xmax-1) Xmax]) = true;
            overlayImage = imoverlay(overlayImage, I2(1:size(I,1),1:size(I,2)), [1,1,0]);
            cnt_ = strfind(file, '_');
            %figure; imagesc(overlayImage);
            %title(strrep(file(cnt_(1)-6:cnt_(7)-1), '_', '-'));     
            fnout = fullfile(DestDir, strcat(file(cnt_(1)-6:cnt_(7)-1), '_GT_Q.jpg'));
            imwrite(overlayImage, fnout, 'jpg');
                       
            filenameGTcopy{i} = '';
            found = 1;
        end
    end    
    
    if (~found)
        I2=false(size(I));
        I2([YminQ(cntQ) (YminQ(cntQ)+1) (YmaxQ(cntQ)-1) YmaxQ(cntQ)],XminQ(cntQ):XmaxQ(cntQ)) = true;
        I2(YminQ(cntQ):YmaxQ(cntQ),[XminQ(cntQ) (XminQ(cntQ)+1) (XmaxQ(cntQ)-1) XmaxQ(cntQ)]) = true;
        overlayImage = imoverlay(mat2gray(I), I2(1:size(I,1),1:size(I,2)), [1,0,0]);
        cnt_ = strfind(file, '_');
        %figure; imagesc(overlayImage);
        %title(strrep(file(cnt_(1)-6:cnt_(7)-1), '_', '-'));
        fnout = fullfile(DestDir, strcat(file(cnt_(1)-6:cnt_(7)-1), '_Q.jpg'));
        imwrite(overlayImage, fnout, 'jpg');
    end
end
%***************************************   


%Display GT if not found earlier with Bills Q
for i = 1:cntGT-1    
    if (isempty(filenameGTcopy{i})) continue; end
    I = dicomread(filenameGT{i});
    I = I(:,:,1);
    INFO = dicominfo(filenameGT{i});
    if (INFO.PatientOrientation(1) == 'A')
        I = fliplr(I);
    end
    
    I2=false(size(I));
    Xmin = uint16(XGT{i} - (RGT{i} / sqrt(2)));
    Xmax = uint16(XGT{i} + (RGT{i} / sqrt(2)));
    Ymin = uint16(YGT{i} - (RGT{i} / sqrt(2)));
    Ymax = uint16(YGT{i} + (RGT{i} / sqrt(2)));
    if (Xmin <= 0) Xmin = 1; end
    I2([Ymin (Ymin+1) (Ymax-1) Ymax],Xmin:Xmax) = true;
    I2(Ymin:Ymax,[Xmin (Xmin+1) (Xmax-1) Xmax]) = true;
    overlayImage = imoverlay(mat2gray(I), I2(1:size(I,1),1:size(I,2)), [1,1,0]);
    cnt_ = strfind(filenameGT{i}, '_');
    %figure; imagesc(overlayImage);
    %title(strrep(filenameGT{i}(cnt_(1)-6:cnt_(7)-1), '_', '-'));
    fnout = fullfile(DestDir, strcat(filenameGT{i}(cnt_(1)-6:cnt_(7)-1), '_GT.jpg'));
    imwrite(overlayImage, fnout, 'jpg');
end
%***************************************