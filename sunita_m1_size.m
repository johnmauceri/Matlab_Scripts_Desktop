    fileID = fopen('C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Location3\xyradius_auto_Ajay_M1_withsize.txt','wt');
   
    FID = fopen('C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Location3\xyradius_auto_Noha_M1.txt');
    fgetl(FID); fgetl(FID);
    C = textscan(FID, '%s %f %f %f %f');
    fclose(FID);  
    fn = C{1, 1};
    x  = C{1, 2};
    y  = C{1, 3};
    r  = C{1, 4};  
        
    FID = fopen('C:\Users\John Mauceri\DICOM_TEST\DICOM_LOCATION\Mstudy\M1_sunita.txt');
    C = textscan(FID, '%f %f');
    fclose(FID);  
    accM1 = C{1, 1};
    sizM1  = 10 * C{1, 2};
    
    cntM1 = 0;
    for i = 1: size(fn, 1)
        cnt_ = strfind(fn{i}, '_');
        accession = fn{i}(cnt_(1)+1:cnt_(2)-1);

        foundM1 = 0;
        for j = 1: size(accM1, 1)
            if (accession == num2str(accM1(j)))
                if (exist(strcat('C:\Users\John Mauceri\Desktop\Mstudy', fn{i})))
                    INFO = dicominfo(strcat('C:\Users\John Mauceri\Desktop\Mstudy', fn{i}));
                    fprintf(fileID,'%s %4.0f %4.0f %4.0f %4.0f\n', fn{i}, x(i), y(i), r(i), sizM1(j)/INFO.ImagerPixelSpacing(1));
                    foundM1 = 1;
                    cntM1 = cntM1 + 1;
                    break;
                end
            end
        end
        
        if (foundM1 == 0)
            fprintf(fileID,'%s %4.0f %4.0f %4.0f %4.0f\n', fn{i}, x(i), y(i), r(i), 0);
        end
    end
    fclose(fileID);
    display(['Count: Mstudy ', int2str(cntM1)]);