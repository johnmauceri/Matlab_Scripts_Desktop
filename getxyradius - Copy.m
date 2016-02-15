CircleData = 'C:\Users\John Mauceri\Desktop\Curemetrix Data\uncompressed\';

files = dir(strcat(CircleData,'M*'));


for i = 1:length(files)
    list_files = dir(strcat(CircleData, files(i).name, '\*.jpg'));
    for j = 1:length(list_files)
        strcat(CircleData, files(i).name, '\', list_files(j).name)
        if (list_files(j).name(1) == '.') continue; end;
        I = imread(strcat(CircleData, files(i).name, '\', list_files(j).name));              
        if (list_files(j).name(1) == 'L') I = fliplr(I); end
            
        figure('units','normalized','outerposition',[0 0 0.43 1]); imagesc(I);colormap gray;
        rect = getrect;
     end
end


 

