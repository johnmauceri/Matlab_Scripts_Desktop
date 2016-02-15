    fileID = fopen('C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Location3\xyradius_auto_Noha_nocomments_withsize.txt','wt');
   
    FID = fopen('C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Location3\xyradius_auto_Noha_nocomments.txt');
    C = textscan(FID, '%s %f %f %f %f');
    fclose(FID);  
    fn = C{1, 1};
    x  = C{1, 2};
    y  = C{1, 3};
    r  = C{1, 4};
   
 
    FID = fopen('C:\Users\John Mauceri\DICOM_TEST\DICOM_LOCATION\Mstudy2\M2_sunita.txt');
    C = textscan(FID, '%f %f');
    fclose(FID);  
    accM2 = C{1, 1};
    sizM2  = C{1, 2};
    
    FID = fopen('C:\Users\John Mauceri\DICOM_TEST\DICOM_LOCATION\Bstudy\B_sunita.txt');
    C = textscan(FID, '%f %f');
    fclose(FID);  
    accB = C{1, 1};
    sizB  = C{1, 2};    
        
    FID = fopen('C:\Users\John Mauceri\DICOM_TEST\DICOM_LOCATION\Mstudy\M1_sunita.txt');
    C = textscan(FID, '%f %f');
    fclose(FID);  
    accM1 = C{1, 1};
    sizM1  = 10 * C{1, 2};
    
    cntM2 = 0; cntB = 0; cntM1 = 0;
    for i = 1: size(fn, 1)
        cnt_ = strfind(fn{i}, '_');
        accession = fn{i}(cnt_(1)+1:cnt_(2)-1);

        foundM2 = 0;
        for j = 1: size(accM2, 1)
            if (accession == num2str(accM2(j)))
                INFO = dicominfo(strcat('C:\Users\John Mauceri\Desktop\Mstudy2', fn{i}));
                fprintf(fileID,'%s %4.0f %4.0f %4.0f %4.0f\n', fn{i}, x(i), y(i), r(i), sizM2(j)/INFO.ImagerPixelSpacing(1));
                foundM2 = 1;
                cntM2 = cntM2 + 1;
                break;
            end
        end
        
        foundB = 0;
        for j = 1: size(accB, 1)
            if (accession == num2str(accB(j)))
                if (exist(strcat('C:\Users\John Mauceri\Desktop\Bstudy', fn{i})))
                    INFO = dicominfo(strcat('C:\Users\John Mauceri\Desktop\Bstudy', fn{i}));
                    fprintf(fileID,'%s %4.0f %4.0f %4.0f %4.0f\n', fn{i}, x(i), y(i), r(i), sizB(j)/INFO.ImagerPixelSpacing(1));
                    foundB = 1;
                    cntB = cntB + 1;
                    break;
                end
            end
        end
        
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
        
        if ((foundM2 + foundB + foundM1) > 1)
            display(['Multiple SIZE match in Mstudy2, Bstudy and Mstudy ', accession, foundM2, foundB, foundM1]);
        end
        
        if ((foundM2 == 0) && (foundB == 0) && (foundM1 == 0))
            fprintf(fileID,'%s %4.0f %4.0f %4.0f %4.0f\n', fn{i}, x(i), y(i), r(i), 0);
        end
    end
    fclose(fileID);
    display(['Count: Mstudy2 Bstudy Mstudy ', int2str(cntM2), ' ', int2str(cntB), ' ', int2str(cntM1)]);