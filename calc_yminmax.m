function [ymin ymax] = calc_yminmax(Ibx, Iby, y_nip, height, x)
ymin = min(Iby(find(Ibx==x)));
ymax = max(Iby(find(Ibx==x)));
if ((size(ymin,1)==0) || (size(ymax,1)==0) || (ymin > y_nip) || (ymax < y_nip))
    p = polyfit(Iby, Ibx, 2);
    yy = 0:height+500;
    xx = int16(polyval(p,double(yy)));
    %plot(xx, yy, '.');
    if ((size(ymin,1)==0) || (ymin > y_nip)) ymin = min(find(xx==x)); end
    for i = 1:10
        if ((size(ymin,2)~=0) && (ymin < y_nip)) break; end
        ymin = min(find(xx==x+i));
    end
    if (ymin > y_nip) ymin = min(Iby); end
    
    if ((size(ymax,1)==0) || (ymax < y_nip)) ymax = max(find(xx==x)); end
    for i = 1:10
        if ((size(ymax,2)~=0) && (ymax > y_nip)) break; end
        ymax = max(find(xx==x+i));
    end
    if (ymax < y_nip) ymax = max(Iby); end
end