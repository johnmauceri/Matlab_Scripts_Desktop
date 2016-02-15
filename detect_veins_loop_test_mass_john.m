clear;
%close all;

dir1='C:\Users\John Mauceri\Desktop\Mstudy2\';
dirout='C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Hoanh_device\DetectObjects\';




d1=dir(dir1);
count_t0=0;
count_t0v1=0;
for i1=37:size(d1,1) %3:
    d2 = dir(strcat(dir1,d1(i1).name));
    for i2=15:size(d2,1) %3:
        I=dicomread(strcat(strcat(dir1,d1(i1).name),'\',d2(i2).name));
        INFO=dicominfo(strcat(strcat(dir1,d1(i1).name),'\',d2(i2).name));
        I=double(I);
        I=I(:,:,1);
        if (INFO.PatientOrientation(1) == 'A')
            I = fliplr(I);
        end
        figure(1); imagesc(I); colormap gray
        
        found = 0;
        if (strfind(INFO.StudyDescription, 'DIAG')) found = 1; end
        if (strfind(INFO.StudyDescription, 'Diag')) found = 1; end
        if (INFO.EstimatedRadiographicMagnificationFactor > 1) found = found + 2; end
        
        if isfield(INFO.ViewCodeSequence.Item_1.ViewModifierCodeSequence, 'Item_1')
            if (strcmp(INFO.ViewCodeSequence.Item_1.ViewModifierCodeSequence.Item_1.CodeMeaning, 'Magnification'))
                found = found + 4;
            end
        end
        if isfield(INFO.ViewCodeSequence.Item_1.ViewModifierCodeSequence, 'Item_1')
            if (strcmp(INFO.ViewCodeSequence.Item_1.ViewModifierCodeSequence.Item_1.CodeMeaning, 'Spot Compression'))
                found = found + 8;
            end
        end
        if isfield(INFO.ViewCodeSequence.Item_1.ViewModifierCodeSequence, 'Item_2')
            if (strcmp(INFO.ViewCodeSequence.Item_1.ViewModifierCodeSequence.Item_2.CodeMeaning, 'Magnification'))
                found = found + 4;
            end
        end
        if isfield(INFO.ViewCodeSequence.Item_1.ViewModifierCodeSequence, 'Item_2')
            if (strcmp(INFO.ViewCodeSequence.Item_1.ViewModifierCodeSequence.Item_2.CodeMeaning, 'Spot Compression'))
                ffound = found + 8;
            end
        end
        
        if (found >= 4)
            [Ivessel,whatScale,Direction]=FrangiFilter2D(I);
            figure(2); imagesc(Ivessel); %colormap gray
            figure(3); imagesc(whatScale);% colormap gray
            figure(4); imagesc(Direction); %colormap gray
            %b1=(Ivessel>0.9999);
            b1=(Direction<-3);
            
            
            BW=b1;
            CC = bwconncomp(BW);
            figure;imshow(BW);
            for i=1:CC.NumObjects
                im=zeros(size(BW));
                bd=CC.PixelIdxList{i};
                if(numel(bd)>100000)
                    numel(bd)
                    im(bd)=1;
                    figure;imshow(im);
                end
            end
            
        end
    end
end