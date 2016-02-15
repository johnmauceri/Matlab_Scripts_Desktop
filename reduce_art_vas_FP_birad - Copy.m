
dirSource = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\benign-Birad';

files = dir(fullfile(dirSource, '*.jpg'));
cnt = 1;
labels = [];
for file = files'
    I = imread(fullfile(dirSource,file.name));
    M(:,cnt) = I(:);
    labels(cnt) = 0;
    cnt = cnt + 1;
    cnt
end
M = double(M);
MT = transpose(M);



labels = transpose(labels);

no_dims = round(intrinsic_dim(MT, 'MLE'));

[mappedX, mapping] = compute_mapping(MT, 'Laplacian', no_dims, 7);
figure, scatter3(mappedX(:,1), mappedX(:,2), mappedX(:,3), 1, labels); title('Result of Laplacian Eigenmaps'); drawnow


x = mappedX(:,1);
y = mappedX(:,2);
z = mappedX(:,3);
%mappedX_TRH = mappedX;
%mappedX_TRH(mappedX > 0) = 0;
for i = 1:cnt
    if (x(i) < 0.015)
        x(i) = 0;
        y(i) = 0;
        z(i) = 0;
    else
        II = imread(fullfile(dirSource,files(i).name));
        figure;
        imagesc(II);
        colormap gray;
    end
end
%x(x > 0) = 0;
%y(y > 0) = 0;
%z(z > 0) = 0;
figure, scatter(x, y, 1); title('X Y'); drawnow
figure, scatter(x, z, 1); title('X Z'); drawnow
figure, scatter3(x, y, z, 1, labels); title('Result of Laplacian Eigenmaps'); drawnow
%figure, scatter3(mappedX_TRH(:,1), mappedX_TRH(:,2), mappedX_TRH(:,3), 1, labels); title('Result of Laplacian Eigenmaps'); drawnow
