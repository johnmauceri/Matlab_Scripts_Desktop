function [objects,number_objects,object_level,object_length, ...
        object_x_begin,object_x_end,object_y_begin, ...
        object_y_end,z] = GetObjects(f_dicom)

%        Object-detection algorithm - HXV, Curemetrix, Inc - October 2015
%        Detect metal clamps, clips, breast implants, and other hard objects.
%        This algorithm inspects the "saturated-fraction" of each contour and the ratio of standard deviation/mean of its
%        intensity to determine of the contour circumscribes  a hard object.
%        This algorithm works well for close contours, AND for open contours for which the two terminal points lie on the same
%        edge of the image, i.e, left boundary, right boundary, top boundary, or bottom boundary. This algorithm does not work
%        reliably and will need to be modified if the two terminal points (of an open contour) lie on two different edges
%        of the image 


%INPUT:  f_dicom = DICOM file name
%OUTPUT: objects = 1D array containing objects' x and y coordinates
% 	 number_objects = number of objects
% 	 object_level   = 1D array of intensity levels of the contours circumscribing the objects
% 	 object_length  = 1D array of lengths of the contours circumscribing the objects
% 	 object_x_begin = 1D array of beginning index of the objects's x-coordinates array
% 	 object_x_end   = 1D array of ending    index of the objects's x-coordinates array
% 	 object_y_begin = 1D array of beginning index of the objects's y-coordinates array
% 	 object_y_end   = 1D array of ending    index of the objects's y-coordinates array
%    	 z              = original dicom image (converted to grayscale if applicable);
    
        if (1)
            %Read dicom header
            info_ref   = dicominfo(f_dicom); 
            try
                size_match    = size(strmatch('SIGMOID',char(info_ref.VOILUTFunction)));
            catch
                size_match(1) = 0;
            end


            %Read dicom image
            if size_match(1) == 0
                z          = dicomread(f_dicom);
            else
                z          = dicom_vk2(f_dicom);
                z          = uint16(4096*z);
            end

            %Determine if image needs to be flipped to keep nipple pointing left
            info_ref   = dicominfo(f_dicom);
            size_match = size(strmatch('A',char(info_ref.PatientOrientation)));
            if size_match(1)~=0
                z      = flip(z,2);
            end

        else
            z =imread(f_dicom);
        end

        %Convert image from RGB to gray scale if necessary
        if numel(size(z)) > 2
            z = double(rgb2gray(z));
            z = uint16(z*4095/max(max(z)));
        end

        %Compute global maximum intensity of image
        bscale     = double(max(max(z)));

        %Compute the area of one pixel (in mm^2)
        try
            PixelSize_mm = info_ref.PixelSpacing;
        catch
            try
                PixelSize_mm = info_ref.ImagerPixelSpacing;
            catch
                PixelSize_mm(1) = 0.07;
                PixelSize_mm(2) = 0.07;
            end
        end
        PixelArea_mm2    = double(PixelSize_mm(1)*PixelSize_mm(2));

        %Use 10 contour levels, equally spaced from 80% to 100% of maximum intensity
        nlevels     = 10;
        v_intensity = 0.80;
        v_max       = 1;
        dc          = (v_max - v_intensity)/(nlevels - 1);
        for i=1:nlevels
           cvalues(i) = v_intensity + dc * (i-1);
        end
        cvalues = cvalues * bscale;
            
        %Detect clamps, clips and hard objects.
        scale_factor = 1.;
        [objects,number_objects,object_level,object_length, ...
        object_x_begin,object_x_end,object_y_begin, ...
        object_y_end] = DetectObject(scale_factor,single(z'), ...
        single(cvalues),bscale,PixelArea_mm2);

end
function [image,header] = dicom_vk2(dcm_name)
        image=double(dicomread(dcm_name));
        header=dicominfo(dcm_name);
        image = 1./(1.+exp(-4.*(image-header.WindowCenter(1))/header.WindowWidth(1)));
end
