     im = imread('C:\Users\John Mauceri\Desktop\Can1_1_RCC_M00001_t3_Q0_T0_X1942_Y1341_269X269_07X07.jpg');
     %im = imread('C:\Users\John Mauceri\Desktop\Can1_1_RCC_M01_t3_Q605_T0_X2032_Y1428_100X100_07X07.jpg');
         
     scales = 1:0.5:15;
     cwtstruct = cwtft2(im,'wavelet','gaus2','scales',scales,'angles',0);
     
     im_max = imregionalmax(abs(cwtstruct.cfs(:,:,1,:,1)), 26);
     [rowInd,colInd,zInd]=ind2sub(size(im_max),find(im_max));
     %figure; scatter3(colInd, rowInd, zInd, '.');
     %set(gca,'Xscale','log','Zscale','log','Yscale','log');
     %set(gca,'Zscale','log');
     
     im_max2 = logical(zeros(size(im,1), size(im,2), size(scales,2)));
     im_max2(:,:,:) = logical(im_max(:,:,1,:));
     
     CC = bwconncomp(im_max2, 26);
     save_im_max2 = im_max2;
     figure; hold on;
     for idx = 1: CC.NumObjects
         if (size(CC.PixelIdxList{idx}, 1) < (size(scales,2)/4)) continue; end
         im_max2 = save_im_max2;
         for i = 1: CC.NumObjects
             if (i ~= idx) im_max2(CC.PixelIdxList{i}) = 0;end;
         end
         [rowInd,colInd,zInd]=ind2sub(size(im_max2),find(im_max2));
         plot3(rowInd,colInd,zInd); xlim([0 size(im,1)]); ylim([0 size(im,2)]); zlim([0 size(scales,2)]); view(-39, 30);
     end
     %set(gca,'Zscale','log');
     view(0,0);