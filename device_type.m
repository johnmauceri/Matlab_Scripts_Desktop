% Input I - Image
%       DEBUG - [optional] Debug info displayed [0-2], default 0.
% Output
%       type - Image with device removed. (NONE IMPLANT C-CLAMP L-CLAMP...)

function type = device_type(I, DEBUG)
    Ithreshold=imdilate(double(I>3300),ones(15));
    if (DEBUG >= 1) figure(1); imagesc(Ithreshold); colormap gray; end
    type = 'NONE';
end