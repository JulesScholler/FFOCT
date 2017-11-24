function saveAsTiff(im,filename,cam,handles)

cdir=pwd;
cd([handles.save.path '\' handles.save.t])

if strcmp(cam,'adimec')
    im=uint16(2*im*2^16);
    imwrite(im(:,:,1),[filename '.tif'],'Resolution',[1,1])
    if size(im,3)>1 
        for i=2:size(im,3)
            imwrite(im(:,:,i),[filename '.tif'],'tif','WriteMode','append');
        end
    end
elseif strcmp(cam,'pco')
    im=uint16(im*2^16);
    imwrite(im(:,:,1),[filename '.tif'],'Resolution',[1,1])
    if size(im,3)>1 
        for i=2:size(im,3)
            imwrite(im(:,:,i),[filename '.tif'],'tif','WriteMode','append');
        end
    end
end

cd(cdir)