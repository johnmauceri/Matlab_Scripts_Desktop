%*******  Ground Truth Files
SourceGT0 = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Location3\xyradius_auto_Ajay_GOLDEN.txt'; 
DestGT = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Location3\xyradius_auto_Noha.txt';
%***************************************

%*******  Noha Constants
IMAGE_THRESHOLD = 100;
GOOD_BAD_MATCH_NUM_POINT_LIMIT = 50000;
%***************************************

%*******  Bills Files
SourceQC = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_TXT\cancer-Mstudy2.dat'; 
SourceQB = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_TXT\benign-Mstudy2.dat';
%***************************************

%*******  Location File
SourceL = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Mstudy2\location - Copy.txt'; 
%***************************************

%*******  DataBases
SourceDataM1 = 'C:\Users\John Mauceri\Desktop\Mstudy\';
%***************************************

%*******  Arjan DataBase
CircleData0 = 'C:\Users\John Mauceri\Desktop\Curemetrix Data\uncompressed\';
%***************************************

%*******  Output Image Directory
DestDir = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Overlay\Mstudy2\';
%***************************************

%*******  Store Ground Truth Results in file
fileID = fopen(DestGT,'wt');
fprintf(fileID,'%s %s %s %s %s\n','filename','x','y','rad_pix','size');
%***************************************


% Ground Truth 
nnz_max = 0;
nnz_min = 1000000;
cntGT = 1;
filenameGT = cell(10000,1);
XGT = cell(10000,1);

YGT = cell(10000,1);
RGT = cell(10000,1);
for i = 0:0 % loop over all of Noha's files
    if i == 0 SourceGT = SourceGT0; CircleData = CircleData0; end
    CircleData(46:end)
    fprintf(fileID,'%s\n', CircleData(46:end));
    FID = fopen(SourceGT);
    fgetl(FID);
    C = textscan(FID, '%s %f %f %f %f');
    fclose(FID);
    
    storefn = C{1, 1};
    storefn = strcat(CircleData,strrep(storefn,'_','\'));
    storefn = strrep(storefn,'&',' ');
    C{1, 1} = strrep(C{1, 1}, '.jpg', '');
    C{1, 1} = strrep(C{1, 1}, '.JPG', '');
    C{1, 1} = strrep(C{1, 1}, '&(', ' (');
    
    fn = cell2char(C{1, 1});
    accession = fn(:, 1:3);
    side = fn(:, 5:5);
    view = fn(:, 6:end);
    
    M = C(2:end);
    M = cell2mat(M);
    X_GT = M(:, 1);
    Y_GT = M(:, 2);
    R_GT = M(:, 3);
        
    %For Benign cases only search Bstudy
    if ((i == 6) || (i == 7) || (i == 9) || (i == 10))      
        directory1 = dir(SourceDataB);
        directory = [directory1(3:end)];
    %For Missing Cancer Cases only search Mstudy1
    elseif ((i == 8) || (i == 0))
        directory1 = dir(SourceDataM1);
        directory = [directory1(3:end)];
    %Else Search Mstudy2 first then Bstudy
    else
        directory1 = dir(SourceDataM2);
        directory2 = dir(SourceDataB);
        directory = [directory1(3:end);directory2(3:end)];
    end
    for loop = 1: size(fn,1)   %loop for every one of Noha's circles (multiple per image)
        found = 0;  
        for k = 1: size(directory)    %check all DB directories for a match
            if (k <= (size(directory1, 1) - 2))
                if ((i == 6) || (i == 7) || (i == 9) || (i == 10))   
                    %Search only Bstudy
                    SourceData = SourceDataB;
                elseif ((i == 8) || (i == 0)) 
                    %Search only Mstudy
                    SourceData = SourceDataM1;
                else
                    %Search Mstudy2 first
                    SourceData = SourceDataM2;
                end
            else
                %Search Bstudy second
                SourceData = SourceDataB;
                %For Cancer cases if Match found in Mstudy2 don't look in Bstudy
                if (found > 0) continue; end
            end
            file = strcat(SourceData, directory(k).name, '\', 'M000', accession(loop, 2:end), '*.dcm');
            listing = dir(file);
            for j = 1:size(listing,1) %check each file in each directory for a match
                cnt_ = strfind(listing(j).name, '_');
                side2 = listing(j).name(cnt_(5)+1:cnt_(6)-1);
                view2 = listing(j).name(cnt_(6)+1:cnt_(7)-1);
                if (strcmp(side2, '0') && strcmp(view2, '00')) continue; end
                filename = strcat(SourceData, directory(k).name, '\',listing(j).name);
                if (strfind(filename, '000000'))
                    continue;
                end
                INFO = dicominfo(filename);
                %Until Doug adds Magnification fix to filename I check the
                %dicom and fix myself
                if isfield(INFO.ViewCodeSequence.Item_1.ViewModifierCodeSequence, 'Item_1')
                    if (strcmp(INFO.ViewCodeSequence.Item_1.ViewModifierCodeSequence.Item_1.CodeMeaning, 'Magnification'))
                        view2 = strcat('M', view2);
                    end
                end
                if isfield(INFO.ViewCodeSequence.Item_1.ViewModifierCodeSequence, 'Item_2')
                    if (strcmp(INFO.ViewCodeSequence.Item_1.ViewModifierCodeSequence.Item_2.CodeMeaning, 'Magnification'))
                        view2 = strcat('M', view2);
                    end
                end
                if isfield(INFO.ViewCodeSequence.Item_1.ViewModifierCodeSequence, 'Item_3')
                    display(['Error: Item_3 (Magnification) found in', filename(46:86)]);
                    pause;
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
                    %Check if image match
                    IN = imread(storefn{loop});
                    IM2 = dicomread(filename);
                    INFO = dicominfo(filename);
                    IN = IN(:,:,1);
                    if isa(IM2,'uint16')
                        IM2 = uint8(double(2^8/INFO.WindowWidth) * IM2(:,:,1));
                    else
                        IM2 = IM2(:,:,1);
                    end
                    
                    cnt_ = strfind(storefn{loop}, '\');
                    if (storefn{loop}(cnt_(7)+1) == 'L') IN = fliplr(IN); end
                    if (size(IN) ~= size(IM2)) 
                        continue;
                    end
                    Idiff = imabsdiff(IN, IM2);
                    Idiff = Idiff > IMAGE_THRESHOLD; 
                    nnz0 = nnz(Idiff);
                    %if (accession(loop, 1:end) == '42090473')
                    %    nnz0
                    %end
                    if ((nnz0 > nnz_max) && (nnz0 <= GOOD_BAD_MATCH_NUM_POINT_LIMIT)) nnz_max = nnz0; end
                    if (nnz0 > GOOD_BAD_MATCH_NUM_POINT_LIMIT)
                        if (nnz0 < nnz_min)  nnz_min = nnz0; end
                        %display(['Skip does not match ', num2str(i), ' ', num2str(loop), ' ', num2str(k), ' ', num2str(j), ' ', fn(loop, 1:end), ' ', filename(46:86), ' ', view(loop,1:end), ' ', side2, ' ', view2, ' ', num2str(nnz0), ' ', num2str(nnz_max), ' ', num2str(nnz_min), ' ', num2str(i), ' ', num2str(loop)]);
                        IN = fliplr(IN);
                        Idiff = imabsdiff(IN, IM2);
                        Idiff = Idiff > IMAGE_THRESHOLD; 
                        if (nnz(Idiff) >  GOOD_BAD_MATCH_NUM_POINT_LIMIT) continue; end
                        display(['Warning: Flipped, X corrected ', fn(loop, 1:end), ' ', side2, ' ', view(loop,1:end)]);
                        X_GT(loop) = INFO.Width - X_GT(loop);
                        %figure; imagesc(IN); colormap gray;
                        %figure; imagesc(IM2); colormap gray;
                        %figure; imagesc(Idiff); colormap gray;
                    end
                    %End of Check if Image Matches
                    
                    if (found == 1)
                        display(['Multiple dcm from jpg matches ', fn(loop, 1:end), ' ', side2, ' ', view2]);
                    end
                    found = 1;
                    
                    %DICOM Match found beginning
                    filenameGT{cntGT} = [filename];
                    XGT{cntGT} = X_GT(loop);
                    YGT{cntGT} = Y_GT(loop);
                    RGT{cntGT} = R_GT(loop);

                    fprintf(fileID,'%s %4.0f %4.0f %4.0f %4.0f\n', filenameGT{cntGT}(37:end), XGT{cntGT}, YGT{cntGT}, RGT{cntGT}, 0);
        
                    cntGT = cntGT + 1;
                    if (cntGT >= 10000) 
                        display(['!!!cntGT over 10000 make array bigger!!!']); 
                        return;
                    end
                    %DICOM Match found ending

                end
            end 
        end
        if (~found)
            display(['No dcm from jpg match ', fn(loop, 1:end), ' ',side(loop,1), ' ', view(loop,1:end)]);
        end
    end
end
fclose(fileID);
%***************************************
