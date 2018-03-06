function handles=drawInGUI(im,n,handles)
% This function plots the different FFOCT images with some metrics.
%
% Inputs:   n.          types of FFOCT image 1 = direct image
%                                    2 = amplitude image
%                                    3 = phase image
%                                    4 = fluorescence image
%                                    5 = plot in figure(1)
%           im.         Image to display
%           handles.    GUI structure

switch n
    case 1 % Direct image
        % Compute real framerate
        try
            t0=handles.exp.tPrevImage;
        end
        if exist('t0','var')
            handles.exp.tElapsed=toc(t0);
            set(handles.textFPS,'string',num2str(1/handles.exp.tElapsed,3))
        end
        handles.exp.tPrevImage=tic;
        maxI=sort(im(:));
        N=round(handles.octCam.Nx*handles.octCam.Ny/1000);
        metricI=200*mean(maxI(end-N:end));
        set(handles.textDirectIntensity,'string',[num2str(metricI,3) ' %'])
        axes(handles.axesDirectOCT)
        imagesc(im)
        set(handles.axesDirectOCT,'xticklabel',[],'yticklabel',[])
        drawnow
    case 2
        maxI=sort(im(:));
        N=round(handles.octCam.Nx*handles.octCam.Ny/10000);
        a=mean(maxI(1:N));
        b=mean(maxI(end-N:end));
        set(handles.textTomoIntensity,'string',num2str(100*(b-a),3))
        m=mean(im(:));
        s=std(im(:));
        axes(handles.axesAmplitude)
        imagesc(im,[m-3*s m+3*s])
%         imagesc(log(im))
%         caxis([-10 -5])
        set(handles.axesAmplitude,'xticklabel',[],'yticklabel',[])
        drawnow
    case 3
        imagesc(handles.axesPhase,im)
        set(handles.axesPhase,'xticklabel',[],'yticklabel',[])
        drawnow
    case 4
        axes(handles.axesFluo)
        imagesc(imrotate(im,90))
        set(handles.axesFluo,'xticklabel',[],'yticklabel',[])
        colormap copper
        drawnow
    case 5
        figure(1)
        m=mean(im(:));
        s=std(im(:));
        imagesc(im,[m-3*s m+3*s])
        colormap(gray)
        drawnow
    
end