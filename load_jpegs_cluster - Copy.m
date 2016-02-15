dirSource = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect'; 
files = dir(fullfile(dirSource, '*.jpg'));
cnt = 0;
labels = [];
for file = files'
    I = imread(fullfile(dirSource,file.name));
    [m,n] = size(I);
    V = I(:);
    if cnt == 0 M = V;
    else        M = horzcat(M, V);
    end

    cnt = cnt + 1;
    if (file.name(1) == 'B')
        labels(cnt) = 0;
    elseif (file.name(1) == 'C')
        labels(cnt) = 1;
    end
end
M = double(M);
MT = transpose(M);

%coeff = pca(MT,'Algorithm','eig','Centered',false,'Rows','all','NumComponents',123);

labels = transpose(labels);
figure, scatter3(MT(:,1), MT(:,2), MT(:,3), 1, labels); title('Original dataset'), drawnow
no_dims = round(intrinsic_dim(M, 'MLE'));
disp(['MLE estimate of intrinsic dimensionality: ' num2str(no_dims)]);
[mappedX, mapping] = compute_mapping(MT, 'PCA', no_dims);	
figure, scatter3(mappedX(:,1), mappedX(:,2), mappedX(:,3), 1, labels); title('Result of PCA');
[mappedX, mapping] = compute_mapping(MT, 'Laplacian', no_dims, 7);
figure, scatter3(mappedX(:,1), mappedX(:,2), mappedX(:,3), 1, labels); title('Result of Laplacian Eigenmaps'); drawnow

%MT = MT - mean(MT(:));
sigma = cov(MT);
[U,S,V] = svd(sigma);
pct_var_retained = 100*sum(diag(S(1:600,1:600)))/trace(S);

idx = kmeans(MT, 2);

cluster1 = MT(idx == 1, :);
cluster2 = MT(idx == 2, :);

figure;
hold all;
plot(cluster1(:, 5), cluster1(:, 400), '.');
plot(cluster2(:, 5), cluster2(:, 400), '.');
