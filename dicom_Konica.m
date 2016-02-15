function [image,header] = dicom_Konica(dcm_name)
%Hoanh Vu - Curemetrix, Inc.
%Sample usage: [z,z_header] = dicom_Konica('abc.dcm');
%Input: dcm_name = dicom file name
%Output: image = 16-bit image array
%        header = dicom header
        image=double(dicomread(dcm_name));
        header=dicominfo(dcm_name);
        %"NORMAL" sigmoid transform - This is our default as it seems give the best answers.
        image = uint16((2^16 - 1) ./ (1.+exp(-4.*(image-header.WindowCenter(1))/header.WindowWidth(1))));
        
        %"HARDER" sigmoid transform
        %image = uint16((2^16 - 1) ./ (1.+exp(-4.*(image-header.WindowCenter(2))/header.WindowWidth(2))));
        
        %"SOFTER" sigmoid transform
        %image = uint16((2^16 - 1) ./ (1.+exp(-4.*(image-header.WindowCenter(3))/header.WindowWidth(3))));
end
