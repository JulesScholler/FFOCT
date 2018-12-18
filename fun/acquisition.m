function handles=acquisition(handles)

if handles.gui.oct==1 && handles.gui.fluo==1
    if handles.save.repeat==0
        N=1;
    else
        N=handles.save.repeatN;
    end
    for i=1:N
        tic
        if handles.save.zStack==0
            set(handles.textConsole,'string', sprintf('Acquisition in progress %d/%d',i,N))
            handles=acqOCTFluo(handles,i);
        elseif handles.save.zStack==1
            handles.save.t = datestr(now,'yyyy_mm_dd_HH_MM_ss');
            mkdir([handles.save.path '\' handles.save.t ])
            if handles.save.zStackReturn==1
                posIni=handles.motors.sample.getposition();
            end
            handles.save.zStackPos=handles.save.zStackStart:handles.save.zStackStep:handles.save.zStackEnd;
            nPos=length(handles.save.zStackPos);
            set(handles.editNbImOCT,'string',num2str(nPos))
            dataOCT=zeros(handles.octCam.Nx,handles.octCam.Ny,nPos);
            dataFluo=zeros(handles.fluoCam.Nx,handles.fluoCam.Ny,nPos);
            for j=1:nPos
                set(handles.textConsole,'string', sprintf('zStack plane %d/%d, repeat %d/%d',j,nPos,i,N))
                [dataOCT(:,:,j),dataFluo(:,:,j),handles]=acqOCTFluozStack(handles,j);
                handles=drawInGUI(dataOCT(:,:,j),2,handles);
                handles=drawInGUI(dataFluo(:,:,j),4,handles);
            end
            if handles.save.zStackReturn==1
                handles.motors.sample.moveabsolute(posIni);
            end
            saveAsTiff(dataOCT,'zStack','adimec',handles)
            saveAsTiff(dataFluo,'fluo_zStack','pco',handles)
        end
        daq_output_zero(handles)
        if handles.save.repeat
            pause(handles.save.repeatTime-toc)
        end
    end
    saveParameters(handles)
elseif handles.gui.oct==1
    if handles.save.samefile
        handles=acqSlowOCT(handles);
    else
        if handles.save.repeat==0
            N=1;
        else
            N=handles.save.repeatN;
        end
        for i=1:N
            tic
            if handles.save.zStack==0
                set(handles.textConsole,'string', sprintf('Acquisition in progress %d/%d',i,N))
                handles=acqOCT(handles,i);
            elseif handles.save.zStack==1
                handles.save.t = datestr(now,'yyyy_mm_dd_HH_MM_ss');
                mkdir([handles.save.path '\' handles.save.t ])
                if handles.save.zStackReturn==1
                    posIni=handles.motors.sample.getposition();
                end
                handles.save.zStackPos=handles.save.zStackStart:handles.save.zStackStep:handles.save.zStackEnd;
                nPos=length(handles.save.zStackPos);
                set(handles.editNbImOCT,'string',num2str(nPos))
                data=zeros(handles.octCam.Nx,handles.octCam.Ny,nPos);
                for j=1:nPos
                    set(handles.textConsole,'string', sprintf('zStack plane %d/%d, repeat %d/%d',j,nPos,i,N))
                    [data(:,:,j),handles]=acqOCTzStack(handles,j);
                end
                if handles.save.zStackReturn==1
                    handles.motors.sample.moveabsolute(posIni);
                end
                saveAsTiff(data,'zStack','adimec',handles)
            end
            daq_output_zero(handles)
            if handles.save.repeat
                pause(handles.save.repeatTime-toc)
            end
        end
        saveParameters(handles)
    end
    if handles.exp.piezoMode==6
        colormap = build_colormap(handles);
        imwrite(colormap,[handles.save.path '\' handles.save.t '\' 'colormap.tif'])
    end
elseif handles.gui.fluo==1
    if handles.save.repeat==0
        N=1;
    else
        N=handles.save.repeatN;
    end
    for i=1:N
        tic
        if handles.save.zStack==0
             set(handles.textConsole,'string', sprintf('Acquisition in progress %d/%d',i,N))
            handles=acqFluo(handles);
        elseif handles.save.zStack==1
            handles.save.t = datestr(now,'yyyy_mm_dd_HH_MM_ss');
            mkdir([handles.save.path '\' handles.save.t ])
            if handles.save.zStackReturn==1
                posIni=handles.motors.sample.getposition();
            end
            handles.save.zStackPos=handles.save.zStackStart:handles.save.zStackStep:handles.save.zStackEnd;
            nPos=length(handles.save.zStackPos);
            set(handles.editNbImFluo,'string',num2str(nPos))
            dataFluo=zeros(handles.fluoCam.Nx,handles.fluoCam.Ny,nPos);
            for j=1:nPos
                set(handles.textConsole,'string', sprintf('zStack plane %d/%d, repeat %d/%d',j,nPos,i,N))
                [dataFluo(:,:,j),handles]=acqFluozStack(handles);
                handles=drawInGUI(dataFluo(:,:,j),4,handles);
            end
            if handles.save.zStackReturn==1
                handles.motors.sample.moveabsolute(posIni);
            end
            saveAsTiff(dataFluo,'fluo_zStack','pco',handles)
        end
        if handles.save.repeat
            pause(handles.save.repeatTime-toc)
        end
    end
    saveParameters(handles)
end
set(handles.textConsole,'string', 'Acquisition done!')