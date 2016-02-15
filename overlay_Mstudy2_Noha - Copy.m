%*******  Ground Zero Files
SourceGT1 = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Location3\xyradius_auto_Noha_S_GOLDEN.txt'; 
SourceGT2 = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Location3\xyradius_auto_Noha_D_GOLDEN.txt'; 
SourceGT3 = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Location3\xyradius_auto_Noha_D_group2_GOLDEN.txt'; 
DestGT = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Location3\xyradius_auto_Noha.txt';
%***************************************

%*******  Bills Files
SourceQC = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_TXT\cancer-Mstudy2.dat'; 
SourceQB = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_TXT\benign-Mstudy2.dat';
%***************************************

%*******  DataBase
SourceData = 'C:\Users\John Mauceri\Desktop\Mstudy2\';
%***************************************


fileID = fopen(DestGT,'wt');
fprintf(fileID,'%s %s %s %s %s\n','filename','x','y','rad_pix','size');

% Ground Truth 
cnt = 1;
filenameGT = cell(1000,1);
XGT = cell(1000,1);
YGT = cell(1000,1);
RGT = cell(1000,1);
for i = 1:3 % loop over all of Noha's files
    if i == 1 FID = fopen(SourceGT1); end
    if i == 2 FID = fopen(SourceGT2); end
    if i == 3 FID = fopen(SourceGT3); end
    fgetl(FID);
    C = textscan(FID, '%s %f %f %f %f');
    fclose(FID);
    
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
                if (strcmp(side(loop,1), side2) && strcmp(strrep(view(loop,1:end),' ',''), view2))
                    if (found == 1)
                        display(['Multiple dcm from jpg matches ', accession(loop, 1:end), ' ', side2, ' ', view2]);
                    end
                    found = 1;
                    
                    %DICOM Match found beginning
                    filenameGT{cnt} = [filename];
                    XGT{cnt} = X_GT(loop);
                    YGT{cnt} = Y_GT(loop);
                    RGT{cnt} = R_GT(loop);
                    fprintf(fileID,'%s %4.0f %4.0f %4.0f %4.0f\n', filenameGT{cnt}(38:end), XGT{cnt}, YGT{cnt}, RGT{cnt}, 0);
        
                    cnt = cnt + 1;
                    if (cnt >= 1000) 
                        display(['!!!Cnt over 1000 make array bigger!!!']); 
                        quit;
                    end
                    %DICOM Match found ending

                end
            end 
        end
        if (~found)
            display(['No dcm from jpg match ', accession(loop, 1:end), ' ',side(loop,1), ' ', strrep(view(loop,1:end),' ','')]);
        end
    end
end
fclose(fileID);


for i = 1:cnt-1    
    I = dicomread(filenameGT{i});
    INFO = dicominfo(filenameGT{i});
    if (INFO.PatientOrientation(1) == 'A')
        I = fliplr(I);
    end
    
    IG=false(size(I));
    Xmin = uint16(XGT{i} - (RGT{i} / sqrt(2)));
    Xmax = uint16(XGT{i} + (RGT{i} / sqrt(2)));
    Ymin = uint16(YGT{i} - (RGT{i} / sqrt(2)));
    Ymax = uint16(YGT{i} + (RGT{i} / sqrt(2)));
    IG([Ymin (Ymin+1) (Ymax-1) Ymax],Xmin:Xmax) = true;
    IG(Ymin:Ymax,[Xmin (Xmin+1) (Xmax-1) Xmax]) = true;
    overlayImage = imoverlay(mat2gray(I), IG(1:size(I,1),1:size(I,2)), [1,1,0]);
    figure; imagesc(overlayImage);
    title(strrep(filenameGT{i}(46:85), '_', '-'));
end


%Bill's Q Files
for i = 1:2 % Loop over Cancer and Benign Files
    if i == 1 FID = fopen(SourceQC);
    else      FID = fopen(SourceQB);
    end
    C = textscan(FID, '%s %s %f %f %f %f %f %f %f %f');
    fclose(FID);

    filename = strcat(SourceData, C{1, 2}, '\', C{1, 1});
    store_filename = C{1,1};
    directory = C{1, 2};
    M = C(3:end);
    M = cell2mat(M);

    cnt = 1;
    for loop = filename'
        cnt
        file = num2str(cell2mat(loop));
        if ~exist(file)
            display('Error file not found.', file);
            cnt = cnt + 1;
            continue
        end
        
        Q = M(cnt, 1);
        type = M(cnt, 2);
        X = M(cnt, 3);
        Y = M(cnt, 4);
        Xmin = M(cnt, 5);
        Xmax = M(cnt, 6);
        Ymin = M(cnt, 7);
        Ymax =M(cnt, 8);
    end
end
 
