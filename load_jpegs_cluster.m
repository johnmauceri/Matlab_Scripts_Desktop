%{
dirSource = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Crop_03202015';

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

labels = transpose(labels);
no_dims = round(intrinsic_dim(MT, 'MLE'));
[mappedX, mapping] = compute_mapping(MT, 'Laplacian', no_dims, 7);
figure, scatter3(mappedX(:,1), mappedX(:,2), mappedX(:,3), 1, labels); title('Result of Laplacian Eigenmaps'); drawnow
%}
x = mappedX(:,1);
y = mappedX(:,2);
z = mappedX(:,3);
for i = 1:cnt
    if (x(i) < 0.018)
        x(i) = 0;
        y(i) = 0;
        z(i) = 0;
    else
        if ((labels(i) == 0) && (files(i).name(strfind(files(i).name, '_T') + 2) == '0'))
            II = imread(fullfile(dirSource,files(i).name));
            figure;
            imagesc(II);
            colormap gray;
        end
    end
end
figure, scatter(x, y, 1); title('X Y'); drawnow
figure, scatter(x, z, 1); title('X Z'); drawnow
figure, scatter3(x, y, z, 1, labels); title('Result of Laplacian Eigenmaps'); drawnow


