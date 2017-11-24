function handles=drawInGUI(im,n,handles)

switch n
    case 1
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
        drawnow
    case 3
        imagesc(handles.axesPhase,im)
        drawnow
    case 4
        axes(handles.axesFluo)
        imagesc(im)
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