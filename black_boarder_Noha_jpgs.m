%*******  Noha DataBase
CircleData1 = 'C:\Users\John Mauceri\Desktop\Noha\Curemetrix Cancer cases (Screening)\';
CircleData2 = 'C:\Users\John Mauceri\Desktop\Noha\Curemetrix cancer cases (Diagnostic)\';
CircleData3 = 'C:\Users\John Mauceri\Desktop\Noha\Curemetrix Diagnostic cases (2)\';
CircleData4 = 'C:\Users\John Mauceri\Desktop\Noha\Curemetrix Diagnostic cases (3)\';
CircleData5 = 'C:\Users\John Mauceri\Desktop\Noha\Curemetrix Diagnostic Cancer cases (4)\';
CircleData6 = 'C:\Users\John Mauceri\Desktop\Noha\Curemetrix Benign cases (Screening)\';
CircleData7 = 'C:\Users\John Mauceri\Desktop\Noha\Curemetrix Benign cases (Diagnostic)\';
CircleData8 = 'C:\Users\John Mauceri\Desktop\Noha\Missing Cancer Cases\';
CircleData9 = 'C:\Users\John Mauceri\Desktop\Noha\Diagnostic Benign Cases (2)\';
CircleData10 = 'C:\Users\John Mauceri\Desktop\Noha\42416907 (Screening Benign)\';
%***************************************


total_blk_boarder = 0;
min_blk_boarder_sum = 1000000;
for i = 1:10 % loop over all of Noha's files
    if i == 1 CircleData = CircleData1; end
    if i == 2 CircleData = CircleData2; end
    if i == 3 CircleData = CircleData3; end
    if i == 4 CircleData = CircleData4; end
    if i == 5 CircleData = CircleData5; end
    if i == 6 CircleData = CircleData6; end
    if i == 7 CircleData = CircleData7; end
    if i == 8 CircleData = CircleData8; end
    if i == 9 CircleData = CircleData9; end
    if i == 10 CircleData = CircleData10; end
    CircleData(35:end)
    
    directory = dir(CircleData);
    for loop = 3: size(directory)
        directory2 = dir(strcat(CircleData, directory(loop).name, '\*.jpg'));
        for loop2 = 3: size(directory2)
            IN = imread(strcat(CircleData, directory(loop).name, '\', directory2(loop2).name));
            if (sum(sum(IN(10,10:end-10))+sum(IN(end-10,10:end-10))+sum(IN(10:end-10,10))+sum(IN(10:end-10,end-10))) < min_blk_boarder_sum)
                if (sum(sum(IN(10,10:end-10))+sum(IN(end-10,10:end-10))+sum(IN(10:end-10,10))+sum(IN(10:end-10,end-10))) > 0)
                    min_blk_boarder_sum = sum(sum(IN(10,10:end-10))+sum(IN(end-10,10:end-10))+sum(IN(10:end-10,10))+sum(IN(10:end-10,end-10)));
                end
            end
            
            if (sum(sum(IN(10,10:end-10))+sum(IN(end-10,10:end-10))+sum(IN(10:end-10,10))+sum(IN(10:end-10,end-10))) < 10000)
                figure; imagesc(IN); colormap gray;
                total_blk_boarder = total_blk_boarder + 1;
                display([directory(loop).name, ' ', directory2(loop2).name]);
            end
        end
    end
end
total_blk_boarder
min_blk_boarder_sum
%***************************************
