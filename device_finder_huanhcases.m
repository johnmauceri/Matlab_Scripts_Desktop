clear;
close all

dir1='C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Hoanh_device\DetectObjects\';
dirout='C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Hoanh_device\DetectObjects\';

d1=dir(dir1);
for i1=8:size(d1,1)

    strcat(dir1,d1(i1).name)
    I=dicomread(strcat(dir1,d1(i1).name));
    INFO=dicominfo(strcat(dir1,d1(i1).name)); 
    I=I(:,:,1); 
    figure; imagesc(I); colormap gray 
  
    Iboundary=imdilate(double(I>4000),ones(15));
    figure; imagesc(Iboundary); colormap gray;
    BW = Iboundary;
    
    
    BW = bwlabel(BW);
    r = regionprops(BW, 'All');
    max1 = size(r(1).PixelList, 1);
    idx = 1;
    for k=2:size(r, 1)
        if (size(r(k).PixelList,1) > max1)
            max1 = size(r(k).PixelList,1);
            idx = k;
        end
    end  
    max2 = 0;
    idx2 = 0;
    for k=1:size(r, 1)
        if (k == idx) continue; end
        if (size(r(k).PixelList,1) > max2)
            max2 = size(r(k).PixelList,1);
            idx2 = k;
        end
    end
    max3 = 0;
    idx3 = 0;
    for k=1:size(r, 1)
        if ((k == idx) || (k == idx2)) continue; end
        if (size(r(k).PixelList,1) > max3)
            max3 = size(r(k).PixelList,1);
            idx3 = k;
        end
    end
    
    BW1 = (BW==idx);
    figure; imagesc(BW1);colormap gray;
    BW1 = (imdilate(double(BW1==1),ones(100)));
    figure; imagesc(BW1);colormap gray;
    
    BW2 = (BW==idx2);
    figure; imagesc(BW2);colormap gray;
    BW2 = (imdilate(double(BW2==1),ones(100)));
    figure; imagesc(BW2);colormap gray;  
    
    BW3 = (BW==idx3);
    figure; imagesc(BW3);colormap gray;
    BW3 = (imdilate(double(BW3==1),ones(100)));
    figure; imagesc(BW3);colormap gray;  
    
    if (max2 > 250000)
        BW4 = BW1 | BW2;
    else
        BW4 = BW1;
    end
    figure; imagesc(BW4);colormap gray;
    
    if (max3 > 50000)
        BW5 = BW4 | BW3;
    else
        BW5 = BW4;
    end
    figure; imagesc(BW4);colormap gray;
    
    BW6 = I .* uint16(~BW5);
    figure; imagesc(BW6);colormap gray;
  
end  
