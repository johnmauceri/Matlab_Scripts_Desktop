NIMG = 65;
     

scales = 1:10;
angles = 0:pi/8:pi-pi/8;
angz = {'0', 'pi/8', 'pi/4', '3pi/8', 'pi/2', '5pi/8', '3pi/4', ...
    '7pi/8','pi', '9pi/8', '5pi/4', '11pi/8', '3pi/2', ...
    '13pi/8' '7pi/4', '15pi/8'};

for k = 1:2
    if (k==2) path = 'C:\Users\John Mauceri\Desktop\mstudy2_and_bstudy_256\spiculated\'; end
    if (k==1) path = 'C:\Users\John Mauceri\Desktop\mstudy2_and_bstudy_256\normal\'; end
    dir1 = dir(strcat(path, '*.png'));
    
    var_angle = zeros(size(dir1, 1), size(angles,2));
    %for loop = 1: size(dir1)
    for loop = 1: NIMG
        loop
        dir1(loop).name
        im = imread(strcat(path,dir1(loop).name));
        im = im(:,:,1);
        figure(1); imagesc(im);  colormap('gray');
        
        FFT_EDGE_REMOVE_SIZE1 = int16(0.1*size(im,1));
        FFT_EDGE_REMOVE_SIZE2 = int16(0.1*size(im,2));
        
        cwtstruct = cwtft2(im,'wavelet',{'cauchy',{pi/12,1.0,4.0,4.0}},'scales',scales,'angles',angles);
        
        for i = 1:size(angles,2)
            cfs = zeros(size(im,1)-(2*FFT_EDGE_REMOVE_SIZE1), size(im,2)-(2*FFT_EDGE_REMOVE_SIZE2));
            for j = 1:size(scales,2)
                cfs(:,:)  = cfs(:,:)  + abs(cwtstruct.cfs(FFT_EDGE_REMOVE_SIZE1+1:size(im,1)-FFT_EDGE_REMOVE_SIZE1,FFT_EDGE_REMOVE_SIZE2+1:size(im,2)-FFT_EDGE_REMOVE_SIZE2,1,j,i));
            end
            var_angle(loop,i) = var(cfs(:));
            figure(2); colormap('gray'); imagesc(cfs); title(['Cauchy angle ' angz(i)]);
        end
    end
    if (k==1) spic_var_angle = var_angle; end
    if (k==2) norm_var_angle = var_angle; end
end


X = [spic_var_angle(1:NIMG,:); norm_var_angle(1:NIMG,:)];
labels(1:NIMG) = 1; labels(NIMG+1:2*NIMG) = 0;
no_dims = round(intrinsic_dim(X, 'MLE'));
disp(['MLE estimate of intrinsic dimensionality: ' num2str(no_dims)]);

OPTIONS = statset('MaxIter',10000);
%Run 100 trails breaking the data into different training and testing
for cnt=1:100
    Y = labels;
    %Randomly break original dataset into training and testing
    P = cvpartition(Y,'Holdout',0.30);
    %Use PCA to reduce dimensions on the training set
    [mappedX_train, mapping_train] = compute_mapping(X(P.training,:), 'PCA', no_dims);
    %figure, scatter(mappedX_train(:,1), mappedX_train(:,2), 1, labels); title('Result of PCA');
    
    %Use the training set mapping to map the test set
    mappedX_test = X(P.test,:); %Get test set
    mm = mapping_train.mean; %Get mean from PCA on training
    mm = repmat(mm, size(mappedX_test,1), 1); %Copy mean down to all rows in test set
    mappedX_test = mappedX_test-mm; %Subtract mean
    mappedX_test = mappedX_test*mapping_train.M; %Finish mapping test set
    
    %Run SVM on training set
    svmStruct = svmtrain(mappedX_train,Y(P.training),'showplot',false,'kernel_function','rbf','rbf_sigma',10,'options',OPTIONS);
    %Check how the classifier from the training set works on test set
    C = svmclassify(svmStruct,mappedX_test,'showplot',false);
    err_rate(cnt) = sum(Y(P.test) ~= C')/P.TestSize; % Mis-classification rate
    conMat = confusionmat(Y(P.test),C); % Confusion matrix
    tpr(cnt) = conMat(2,2) / (conMat(2,2) + conMat(2,1)); %True Positive Rate
    fpr(cnt) = conMat(1,2) / (conMat(1,2) + conMat(1,1)); %False Positive Rate
end
display([mean(err_rate) mean(tpr) mean(fpr)]);%average error rate for all 100 cases.
