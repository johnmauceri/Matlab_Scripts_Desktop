Source = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_LOCATION\Mstudy\Case Log3.txt'; 
Dest = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Location3\xyradius.txt'; 

SourceData = 'C:\Users\John Mauceri\Desktop\Mstudy\';
CircleData = 'C:\Users\John Mauceri\Desktop\Curemetrix Data\uncompressed\';

dirDest = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Location';

fileID = fopen(Dest,'w');
fprintf(fileID,'%s %s %s %s %s\n','filename','x','y','rad_pix','size');
            
FID = fopen(Source);
fgetl(FID);
C = textscan(FID, '%s %s %s %f %f %f');
fclose(FID);

tmp = strrep(C{1, 1}, 'UCSD', '');
filename = strcat(SourceData, tmp, '\', tmp, '_', C{1, 2}, '*.dcm');
fn = strcat(SourceData, tmp);
M = C(4:end);
M = cell2mat(M);
[m, n] = size(M);
side = C{3};
location = C{4};
cmfn = C{5};
siz = C{6};
   
x = [];
y = [];
rad_pix = [];

for i = 1: m
    i
    files = dir(filename{i});
    tmp = strfind(side(i), 'eft');
    rl = isempty(tmp{1});
    found_CC = 0;
    found_MLO = 0;
    for file = files'
        if (isempty(strfind(file.name, '_CC_')) && isempty(strfind(file.name, '_MLO_'))); continue; end;
        if (~isempty(strfind(file.name, 'CC')) && (found_CC == 1)); continue; end;
        if (~isempty(strfind(file.name, 'MLO')) && (found_MLO == 1)); continue; end;
        
        if ((isempty(strfind(file.name, '_L_')) && rl) || (~isempty(strfind(file.name, '_L_')) && ~rl))     
            J = imread(fullfile(CircleData, strcat(file.name(1), file.name(5), file.name(6), '\', strrep(file.name(36:40), '_', ''), '.jpg')));
            
            if (~isempty(strfind(file.name, 'CC'))) found_CC = 1; end;
            if (~isempty(strfind(file.name, 'MLO'))) found_MLO = 1; end;
            
            if (~isempty(strfind(file.name, '_L_'))) J = fliplr(J); end
                
            figure('units','normalized','outerposition',[0 0 0.43 1]); imagesc(J);colormap gray;
            file.name
            rect = getrect;
            
            x = rect(1) + (rect(3)/2);
            y = rect(2) + (rect(4)/2);
            rad_pix = ((rect(3)/2)^2 + (rect(4)/2)^2)^0.5;
            close;
            
            fprintf(fileID,'%s %4.0f %4.0f %4.0f %f\n',file.name(1:40),x,y,rad_pix,siz(i));
        end
    end
end 
fclose(fileID);