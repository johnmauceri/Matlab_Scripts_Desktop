     im = imread('C:\Users\John Mauceri\Desktop\Can1_1_RCC_M00001_t3_Q0_T0_X1942_Y1341_269X269_07X07.jpg');
     im = imread('C:\Users\John Mauceri\Desktop\Can1_1_RCC_M01_t3_Q605_T0_X2032_Y1428_100X100_07X07.jpg');
     %figure; imagesc(im);  colormap('gray');
     
     %wavedec2()
     
     scales = 1:0.5:15;
     cwtstruct = cwtft2(im,'wavelet','gaus2','scales',scales,'angles',0);
                
     cfs = abs(cwtstruct.cfs(:,:,1,:,1));
     
     wtmm = zeros(size(im,1), size(im,2), size(scales,2));
     lmaxima7 = logical(zeros(size(im,1), size(im,2), size(scales,2)));
     lmaxima4 = logical(zeros(size(im,1), size(im,2), size(scales,2)));
     im_max2 = zeros(size(im,1), size(im,2), size(scales,2));
     BW = zeros(size(im,1), size(im,2), size(scales,2));
     for i = 1:size(scales,2)
         %figure; colormap('gray'); imagesc(abs(cwtstruct.cfs(:,:,1,i,1))); title(['Gaus2 scale ' int2str(i)]);
         
         hLocalMax = vision.LocalMaximaFinder; 
         hLocalMax.MaximumNumLocalMaxima = 500; 
         hLocalMax.NeighborhoodSize = [3 3];
         hLocalMax.Threshold = 1; 
         location = step(hLocalMax, abs(cwtstruct.cfs(:,:,1,i,1)));
         for k = 1:size(location, 1)
             if ((location(k,1) ~= 1) && (location(k,1) ~= size(im,1)) && (location(k,2) ~= 1) && (location(k,2) ~= size(im,2)))
                lmaxima7(location(k,2), location(k,1), i) = 1;
             end
         end
         %figure; colormap('gray'); imagesc(lmaxima7(:,:,i)); 
         
         ms = mean2(abs(cwtstruct.cfs(:,:,1,i,1))) + 1 * std2(abs(cwtstruct.cfs(:,:,1,i,1)))
         BW(:,:,i) = abs(cwtstruct.cfs(:,:,1,i,1)) > ms;
         %figure; colormap('gray'); imagesc(BW(:,:,i));
            
         [lmaxima,indices] = localmax(cwtstruct.cfs(:,:,1,i,1),[],false);
         [lmaxima2,indices2] = localmax(transpose(cwtstruct.cfs(:,:,1,i,1)),[],false);
         %[iRow,iCol] = find(lmaxima);
         
         wtmm(:,:,i) = lmaxima > 0;
  
         %figure; colormap('gray'); imagesc(lmaxima); title(['Maxima scale ' int2str(i)]);
         
         %figure; colormap('gray'); imagesc(transpose(lmaxima2)); title(['Maxima2 scale ' int2str(i)]);
         
         lmaxima3 = lmaxima + transpose(lmaxima2);
         %figure; colormap('gray'); imagesc(lmaxima3); title(['Maxima3 scale ' int2str(i)]);
         lmaxima4(:,:,i) = logical(lmaxima3 > 0);
         %figure; colormap('gray'); imagesc(lmaxima4(:,:,i)); title(['Maxima4 scale ' int2str(i)]);
         
         lmaxima6(:,:,i) = bwmorph(lmaxima4(:,:,i), 'skel', Inf);
         %figure; colormap('gray'); imagesc(lmaxima6(:,:,i)); title(['Maxima6 scale ' int2str(i)]);
         
         im_max2(:,:,i) = imregionalmax(abs(cwtstruct.cfs(:,:,1,i,1)),8); 
         %figure; colormap('gray'); imagesc(im_max2(:,:,i));
     end
     
     [rowInd,colInd,zInd]=ind2sub(size(BW),find(BW));
     figure; scatter3(colInd, rowInd, zInd, '.');
     
     [rowInd,colInd,zInd]=ind2sub(size(im_max2),find(im_max2));
     figure; scatter3(colInd, rowInd, zInd, '.');
     
     im_max = imregionalmax(cfs,26);
     [rowInd,colInd,zInd]=ind2sub(size(im_max),find(im_max));
     figure; scatter3(colInd, rowInd, zInd, '.');    
     
     [rowInd,colInd,zInd]=ind2sub(size(lmaxima4),find(lmaxima4));
     figure; scatter3(colInd, rowInd, zInd, '.');
     skel = Skeleton3D(lmaxima4);
     [rowInd,colInd,zInd]=ind2sub(size(skel),find(skel));
     figure; scatter3(colInd, rowInd, zInd, '.');
     CC = bwconncomp(skel, 6);
     numPixels = cellfun(@numel,CC.PixelIdxList);
     [biggest,idx] = max(numPixels);
     for i = 1: CC.NumObjects
        if (i ~= idx) skel(CC.PixelIdxList{i}) = 0;end;
     end
     [rowInd,colInd,zInd]=ind2sub(size(skel),find(skel));
     figure; scatter3(colInd, rowInd, zInd, '.'); xlim([0 size(im,1)]); ylim([0 size(im,2)]); zlim([0 size(scales,2)]); view(-39, 30);
     
     CC = bwconncomp(lmaxima4, 6);
     numPixels = cellfun(@numel,CC.PixelIdxList);
     [biggest,idx] = max(numPixels);
     for i = 1: CC.NumObjects
        if (i ~= idx) lmaxima4(CC.PixelIdxList{i}) = 0;end;
     end
     [rowInd,colInd,zInd]=ind2sub(size(lmaxima4),find(lmaxima4));
     figure; scatter3(colInd, rowInd, zInd, '.');
     
     [rowInd,colInd,zInd]=ind2sub(size(wtmm),find(wtmm));
     figure; scatter3(colInd, rowInd, zInd, '.');
          

     
     

     close all;
     
    
     
     
     
     [A,H,D,V] = dwt2(im,'haar');         
     im_max = imregionalmax(abs(A)); % Modulus Maxima of the wavelet 
                                     %Transform, using the Approximation 
                                     %wavelet
     figure, imshow(im_max);

     %% Partition Function Z

     Z = 0; % Initialization of the partition function

     for q = -5:5

     Z = Z + abs(im_max).^q ;% Definition of the partition function.
     %Certainly wrong, I think q can't be the variable for the loop and 
     % im_max is not the correct input in abs.

     end

    a = 2; % scale factor. It is supposed to vary, I put it to 2 just for
           %  tests

    tau =  log(Z)/log(a); % scaling function, in function of q according to
                          % the article

    plot(tau,q);