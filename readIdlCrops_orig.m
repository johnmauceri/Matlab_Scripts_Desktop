clear all;
close all;

dataset = '/Users/snayak/data/Mstudy2_16bit/';

targetCropDir = '/Users/snayak/data/Mstudy2_IdlQ_crops/benign/';
targetCropDir64 = '/Users/snayak/data/Mstudy2_IdlQ_crops_64/benign/';
targetCropDir16Bit = '/Users/snayak/data/Mstudy2_IdlQ_crops_16bit/benign/';
fid=fopen('/Users/snayak/code/Mstudy2_IdlQ_crops/benign-Mstudy2.dat','r');

while ~feof(fid)
    tline = fgetl(fid);
    [filename, remTokens] = strtok(tline);
    [toks] = sscanf(remTokens, '%f');
    if numel(toks)<15
        continue;
    end

    Q = toks(1);
    CType = toks(2);

    XMin=toks(3);
    XMax=toks(4);

    YMin=toks(6);
    YMax=toks(5);

    caseName = strtok(filename, '_');
    fileLocAndName = strcat(dataset, caseName, '/', filename);
    I = dicomread(fileLocAndName);
    dInfo = dicominfo(fileLocAndName);
    if (dInfo.PatientOrientation(1)=='A')
        I = fliplr(I);
    end

    Isize = size(I);
    x_st = round(XMin+1); x_end = round(XMax+1);
    y_st = round(YMin+1); y_end = round(YMax+1);

    x_ctr = (x_st + x_end)/2;
    y_ctr = (y_st + y_end)/2;
    
    h = y_end-y_st;
    w = x_end - x_st;

    if (w>h) h = w;
    else w = h;
    end
    
    y_st = max(1, round(y_ctr - 0.7*h));
    y_end = min(Isize(1), round(y_ctr + 0.7*h));

    x_st = max(1, round(x_ctr - 0.7*w));
    x_end = min(Isize(2), round(x_ctr + 0.7*w));

    Iorg = I;    
    Icrop = Iorg(y_st:y_end, x_st:x_end, :);

    targetCropName16Bit = strcat(targetCropDir16Bit, filename, sprintf('_%0.02f_c%d_%d_%d_%d_%d.png', Q, CType, x_st, x_end, y_st, y_end));
    targetCropName = strcat(targetCropDir, filename, sprintf('_%0.02f_c%d_%d_%d_%d_%d.png', Q, CType, x_st, x_end, y_st, y_end));
    targetCropName64 = strcat(targetCropDir64, filename, sprintf('_%0.02f_c%d_%d_%d_%d_%d_64.png', Q, CType, x_st, x_end, y_st, y_end));
    try
        if (size(Icrop,1)~=size(Icrop,2))
            h = size(Icrop,1); w = size(Icrop,2);
            if h>w
                diff = h-w;
                pad = floor((h-w)/2);
                Icrop = [zeros(h,pad) Icrop zeros(h, diff-pad)];
            else
                diff = w-h;
                pad = floor((w-h)/2);
                Icrop = [zeros(pad,w); Icrop; zeros(diff-pad,w)];
            end
        end
        imwrite(Icrop, targetCropName16Bit, 'Compression', 'None', 'BitDepth', 16);
        imwrite(mat2gray(Icrop), targetCropName, 'Compression', 'None');
        imwrite(imresize(mat2gray(Icrop), [64 64]), targetCropName64, 'Compression', 'None');
    catch
    end
end
fclose(fid);
