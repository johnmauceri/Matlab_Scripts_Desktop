function [filt] = make_triangle(box_size, tri_size, y_offset)
filt = [zeros(box_size,box_size)];
y1 = (box_size - tri_size)/2;
y2 = (box_size + tri_size)/2;
for i = y_offset/2 + y1:y_offset/2 + y2
    filt(i, round(((box_size+y1+(y_offset/2))/2)-i/2)) = 1;
    filt(i, round((((y2-(y_offset/2)))/2)+i/2))= 1;
end
filt(y_offset/2+y2, y1:y2) = 1;
end

%{
function [filt] = make_triangle(box_size, tri_size)
filt = [zeros(box_size,box_size)];
y1 = (box_size - tri_size)/2;
y2 = (box_size + tri_size)/2;
for i = y1:y2
    filt(i, round(((box_size+y1)/2)-i/2)) = 1;
    filt(i, round((y2/2)+i/2))= 1;
end
filt(y2, y1:y2) = 1;
end
%}