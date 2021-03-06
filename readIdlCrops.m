clear all;
close all;

for cnt = 4:4
    loop = 0;
    new_dir = 1;
    if (cnt == 1)
        targetCropDir = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Mstudy-Crops-Nov16\cancer-Mstudy1\';
        fid=fopen('C:\Users\John Mauceri\DICOM_TEST\DICOM_TXT\Mstudy-Crops-Nov16\cancer-Mstudy1.dat','r');
        dataset = 'C:\Users\John Mauceri\Desktop\Mstudy\';
    elseif (cnt == 2)
        targetCropDir = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Mstudy-Crops-Nov16\benign-Mstudy1\';
        fid=fopen('C:\Users\John Mauceri\DICOM_TEST\DICOM_TXT\Mstudy-Crops-Nov16\benign-Mstudy1.dat','r');
        dataset = 'C:\Users\John Mauceri\Desktop\Mstudy\';
    elseif (cnt == 3)
        targetCropDir = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Mstudy-Crops-Nov16\cancer-Mstudy2\';
        fid=fopen('C:\Users\John Mauceri\DICOM_TEST\DICOM_TXT\Mstudy-Crops-Nov16\cancer-Mstudy2.dat','r');
        dataset = 'C:\Users\John Mauceri\Desktop\Mstudy2\';
    elseif (cnt == 4)
        targetCropDir = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Mstudy-Crops-Nov16\benign-Mstudy2\';
        fid=fopen('C:\Users\John Mauceri\DICOM_TEST\DICOM_TXT\Mstudy-Crops-Nov16\benign-Mstudy2.dat','r');
        dataset = 'C:\Users\John Mauceri\Desktop\Mstudy2\';
    end
    
    while ~feof(fid)
        loop = loop + 1;
        if (loop == 1)
            targetCropDirCopy = strcat(targetCropDir,'Group', int2str(new_dir),'\');
            mkdir(targetCropDirCopy);
        elseif (loop == 2500) 
            new_dir = new_dir + 1;
            loop = 0;
        end
        
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

        if ~exist(fileLocAndName)
            display('Error file not found.', fileLocAndName);
            continue
        end

        I = dicomread(fileLocAndName);
        dInfo = dicominfo(fileLocAndName);
        if isfield(dInfo, 'PixelSpacing') 
            ps = dInfo.PixelSpacing;
        else 
            ps = dInfo.ImagerPixelSpacing;
        end
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
        
        %{
        if (w>h) h = w;
        else w = h;
        end
        %}
        
        pad = 0.5; %0.7 40 percent 0.5 50 percent
        y_st = max(1, round(y_ctr - pad*h));
        y_end = min(Isize(1), round(y_ctr + pad*h));
        
        x_st = max(1, round(x_ctr - pad*w));
        x_end = min(Isize(2), round(x_ctr + pad*w));
        
        %Bill pads with 9 mm on each side. Remove it.
        psx = round(9.0 / ps(1));
        psy = round(9.0 / ps(2));
        if ((y_end - psy) > (y_st + psy))
            y_st = y_st + psy;
            y_end = y_end - psy;
        end
        if ((x_end - psx) > (x_st + psx))
            x_st = x_st + psx;
            x_end = x_end - psx;
        end
        
        Iorg = I;
        Icrop = Iorg(y_st:y_end, x_st:x_end, :);
        
        lnth = length(filename);
        targetCropName = strcat(targetCropDirCopy, filename(1:min([160 lnth])), sprintf('_%0.02f_c%d_%d_%d_%d_%d.png', Q, CType, x_st, x_end, y_st, y_end));
        try
            %{
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
            %}
            imwrite(mat2gray(Icrop), targetCropName, 'Compression', 'None');
        catch
            display('Error: Unable to Write file: ', targetCropName);
        end
    end
    fclose(fid);
end