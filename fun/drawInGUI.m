function handles=drawInGUI(im,n,handles)
% This function plots the different FFOCT images with some metrics.
%
% Inputs:   n.          types of FFOCT image 1 = direct image
%                                    2 = amplitude image
%                                    3 = phase image
%                                    4 = fluorescence image
%                                    5 = plot in figure(1)
%                                    6 = plot dffoct
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
        im=im(handles.octCam.Y0:handles.octCam.Y0+handles.octCam.Ny-1,handles.octCam.X0:handles.octCam.X0+handles.octCam.Nx-1);
        maxI=sort(im(:));
        N=round(handles.octCam.Nx*handles.octCam.Ny/1000);
        metricI=200*mean(maxI(end-N:end));
        set(handles.textDirectIntensity,'string',[num2str(metricI,3) ' %'])
        axes(handles.axesDirectOCT)
        imagesc(imrotate(im,-90))
        set(handles.axesDirectOCT,'xticklabel',[],'yticklabel',[])
        drawnow
    case 2 % Amplitude image
        im=im(handles.octCam.Y0:handles.octCam.Y0+handles.octCam.Ny-1,handles.octCam.X0:handles.octCam.X0+handles.octCam.Nx-1);
        maxI=sort(im(:));
        N=round(handles.octCam.Nx*handles.octCam.Ny/10000);
        a=mean(maxI(1:N));
        b=mean(maxI(end-N:end));
        set(handles.textTomoIntensity,'string',num2str(100*(b-a),3))
        m=mean(im(:));
        s=std(im(:));
        axes(handles.axesAmplitude)
        imagesc(imrotate(im,-90),[m-3*s m+3*s])
        set(handles.axesAmplitude,'xticklabel',[],'yticklabel',[])
        drawnow
    case 3 % Phase image
        im=im(handles.octCam.Y0:handles.octCam.Y0+handles.octCam.Ny-1,handles.octCam.X0:handles.octCam.X0+handles.octCam.Nx-1);
        imagesc(handles.axesPhase,imrotate(im,-90))
        set(handles.axesPhase,'xticklabel',[],'yticklabel',[])
        drawnow
    case 4 % Fluorescence image
        axes(handles.axesFluo)
        imagesc(im)
        set(handles.axesFluo,'xticklabel',[],'yticklabel',[])
        colormap copper
        axis equal
        drawnow
    case 5
        figure(1)
        m=mean(im(:));
        s=std(im(:));
        imagesc(im,[m-3*s m+3*s])
        colormap(gray)
        axis equal
        drawnow
    case 6 % Dynamic image
        axes(handles.axesDirectOCT)
        image(imrotate(im,-90))
        set(handles.axesDirectOCT,'xticklabel',[],'yticklabel',[])
        drawnow
end