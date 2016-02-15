function test
    addpath('../export_fig');
    addpath('./DetectObjects');

    %list       = dir('*.bmp');
    list       = dir('*.dcm');
    for i = 1:size(list,1)
        f_dicom    = list(i).name;
        [objects,number_objects,object_level,object_length, ...
        object_x_begin,object_x_end,object_y_begin, ...
        object_y_end,z] = GetObjects(f_dicom);


        %Overlay objects onto original image
	    h = figure; imshow(16*z); hold on;
	    if number_objects > 0
            for i_obj = 1:number_objects
                x_obj = objects(object_x_begin(i_obj):object_x_end(i_obj));
                y_obj = objects(object_y_begin(i_obj):object_y_end(i_obj));
                if i_obj == 1 
                    plot(x_obj,y_obj,'r','LineWidth',1.);
                elseif i_obj == 2
                    plot(x_obj,y_obj,'g','LineWidth',1.);
                elseif i_obj == 3
                    plot(x_obj,y_obj,'b','LineWidth',1.);
                else
                    plot(x_obj,y_obj,'c','LineWidth',1.);
                end
            end
        end

        %export_fig(h,strrep(f_dicom,'.dcm','-Overlay.jpg'),'-jpg','-nocrop');
        export_fig(h,strrep(f_dicom,'.bmp','-Overlay.jpg'),'-jpg','-nocrop');
        delete(h);
    end
end
