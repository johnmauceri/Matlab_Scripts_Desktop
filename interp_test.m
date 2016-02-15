%3 x 3 matrix
[X,Y] = meshgrid(1:3);
%example data 
V=[384.214114325090,478.932548839674,758.032940311404;18.2206196723684,-302.277504459003,-61.0351233986193;116.837803192749,-117.342337428453,-558.526153284246];
%interpolate to increase granularity
[Xq,Yq] = meshgrid(1:0.1:3);
Vq = interp2(X,Y,V,Xq,Yq,'cubic');
figure
surf(Xq,Yq,Vq)

%find closest location to zero value
[row, col] = find(Vq==min(min(abs(Vq))));
