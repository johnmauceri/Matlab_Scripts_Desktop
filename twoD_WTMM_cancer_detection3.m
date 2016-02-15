      %S=altes(128); [TFR,T,F]=tfrscalo(S,1:128,8);
      %H=holder(TFR,F,1,length(F));




     im = imread('C:\Users\John Mauceri\Desktop\Can1_1_RCC_M00001_t3_Q0_T0_X1942_Y1341_269X269_07X07.jpg');
     %im = imread('C:\Users\John Mauceri\Desktop\Can1_1_RCC_M01_t3_Q605_T0_X2032_Y1428_100X100_07X07.jpg');
         
     scales = 1:0.5:15;
     cwtstruct = cwtft2(im,'wavelet','gaus2','scales',scales,'angles',0);
     
     i=1;
     %figure; colormap('gray'); imagesc(abs(cwtstruct.cfs(:,:,1,i,1))); view(-90,90);
     %title(['Gaus2 scale ' int2str(i)]); 
     BW(:,:,i) = edge(abs(cwtstruct.cfs(:,:,1,i,1)), 'Canny', 0.25);
     BW(:,:,i) = (imdilate(double(BW(:,:,i)),ones(5)));
     BW(:,:,i) = imfill(BW(:,:,i), 'holes');
     BW(1:5,:) = 0; BW(size(im,1)-4:size(im,1),:) = 0;
     BW(:,1:5) = 0; BW(:,size(im,2)-4:size(im,2),:) = 0;
     figure; colormap('gray'); imagesc(BW(:,:,i)); view(-90,90);
     
     im_max = imregionalmax(abs(cwtstruct.cfs(:,:,1,:,1)), 26);
     [rowInd,colInd,zInd]=ind2sub(size(im_max),find(im_max));
     %figure; scatter3(colInd, rowInd, zInd, '.');
     %set(gca,'Xscale','log','Zscale','log','Yscale','log');
     %set(gca,'Zscale','log');
     
     im_max2 = logical(zeros(size(im,1), size(im,2), size(scales,2)));
     im_max2(:,:,:) = logical(im_max(:,:,1,:));
         
     im_max2(:,:,i) = im_max2(:,:,i) .* BW(:,:,i); %Get Curves on MC's
     %im_max2(:,:,i) = im_max2(:,:,i) .* ~BW(:,:,i); %Get Curves not on MC's
     %figure; colormap('gray'); imagesc(im_max2(:,:,i)); view(-90,90);
     
     CC = bwconncomp(im_max2, 26);
     figure; hold on;
     for idx = 1: CC.NumObjects
         im_max3 = logical(zeros(size(im,1), size(im,2), size(scales,2)));
         if (size(CC.PixelIdxList{idx}, 1) < (size(scales,2)/4)) continue; end
         im_max3(CC.PixelIdxList{idx}) = 1;
         if (nnz(im_max3(:,:,i).*im_max2(:,:,i)) == 0)
             continue;
         end
         [rowInd,colInd,zInd]=ind2sub(size(im_max3),find(im_max3));
         plot3(rowInd,colInd,zInd); xlim([0 size(im,1)]); ylim([0 size(im,2)]); zlim([0 size(scales,2)]); view(-39, 30);
         %view(0,90);
     end
     %set(gca,'Zscale','log');
     