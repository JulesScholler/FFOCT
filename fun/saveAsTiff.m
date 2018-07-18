
function saveAsTiff(im,filename,cam,handles)
% Function to save the images as tiff or mat (faster).

cdir=pwd;
cd([handles.save.path '\' handles.save.t])

fprintf('\n SAVING \n')
if handles.save.format==1
    if strcmp(cam,'adimec')
        im=uint16(2*im*2^16);
        imwrite(im(:,:,1),[filename '.tif'],'Resolution',[0.22,0.22])
        if size(im,3)>1
            for i=2:size(im,3)
                fprintf([num2str(i) '\n'])
                imwrite(im(:,:,i),[filename '.tif'],'tif','WriteMode','append');
            end
        end
    elseif strcmp(cam,'phase')
        im=im+pi;
        im=uint16(im*(2^16-1)/(2*pi));
        imwrite(im(:,:,1),[filename '.tif'],'Resolution',[0.22,0.22])
        if size(im,3)>1
            for i=2:size(im,3)
                fprintf([num2str(i) '\n'])
                imwrite(im(:,:,i),[filename '.tif'],'tif','WriteMode','append');
            end
        end
    elseif strcmp(cam,'pco')
        im=uint16(im*2^16);
        imwrite(im(:,:,1),[filename '.tif'],'Resolution',[0.22,0.22])
        if size(im,3)>1
            for i=2:size(im,3)
                fprintf([num2str(i) '\n'])
                imwrite(im(:,:,i),[filename '.tif'],'tif','WriteMode','append');
            end
        end
    end
elseif handles.save.format==2
    if strcmp(cam,'adimec')
        im=uint16(2*im*2^16);
        save(filename, 'im','-v7.3','-nocompression')
    elseif strcmp(cam,'pco')
        im=uint16(im*2^16);
        save(filename, 'im','-v7.3','-nocompression')
    end
end

cd(cdir)