function handles=acquisition(handles)

if handles.gui.oct==1 && handles.gui.fluo==1
    if handles.save.repeat==0
        N=1;
    else
        N=handles.save.repeatN;
    end
    h=waitbar(0,'Acquistion in progess, please wait.');
    for i=1:N
        tic
        if handles.save.zStack==0
            waitbar(i/N)
            handles=acqOCTFluo(handles);
        elseif handles.save.zStack==1
            handles.save.t = datestr(now,'yyyy_mm_dd_HH_MM_ss');
            mkdir([handles.save.path '\' handles.save.t ])
            if handles.save.zStackReturn==1
                posIni=handles.motors.sample.getposition();
            end
            handles.save.zStackPos=handles.save.zStackStart:handles.save.zStackStep:handles.save.zStackEnd;
            nPos=length(handles.save.zStackPos);
            set(handles.editNbImOCT,'string',num2str(nPos))
            move=round(handles.motors.sample.Units.positiontonative(handles.save.zStackStart*1e-6)*5);
            handles.motors.sample.moverelative(move);
            dataOCT=zeros(handles.octCam.Nx,handles.octCam.Ny,nPos);
            dataFluo=zeros(handles.fluoCam.Nx,handles.fluoCam.Ny,nPos);
            for j=1:nPos
                waitbar(i*j/(N*nPos));
                if j>1
                    move=round(handles.motors.sample.Units.positiontonative(handles.save.zStackStep*1e-6)*5);
                    handles.motors.sample.moverelative(move);
                    pause(10)
                end
                [dataOCT(:,:,j),dataFluo(:,:,j),handles]=acqOCTFluozStack(handles);
                handles=drawInGUI(dataOCT(:,:,j),2,handles);
                handles=drawInGUI(dataFluo(:,:,j),4,handles);
            end
            if handles.save.zStackReturn==1
                handles.motors.sample.moveabsolute(posIni);
            end
            saveAsTiff(dataOCT,'zStack','adimec',handles)
            saveAsTiff(dataFluo,'fluo','pco',handles)
        end
        pause(handles.save.repeatTime-toc)
    end
    saveParameters(handles)
    close(h)
elseif handles.gui.oct==1
    if handles.save.samefile
        handles=acqSlowOCT(handles);
    else
        if handles.save.repeat==0
            N=1;
        else
            N=handles.save.repeatN;
        end
        h=waitbar(0,'Acquistion in progess, please wait.');
        for i=1:N
            tic
            if handles.save.zStack==0
                waitbar(i/N)
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
                move=round(handles.motors.sample.Units.positiontonative(handles.save.zStackStart*1e-6)*5);
                handles.motors.sample.moverelative(move);
                data=zeros(handles.octCam.Nx,handles.octCam.Ny,nPos);
                for j=1:nPos
                    waitbar(i*j/(N*nPos));
                    [data(:,:,j),handles]=acqOCTzStack(handles,j);
                end
                if handles.save.zStackReturn==1
                    handles.motors.sample.moveabsolute(posIni);
                end
                saveAsTiff(data,'zStack','adimec',handles)
            end
            pause(handles.save.repeatTime-toc)
        end
        saveParameters(handles)
        close(h)
    end
elseif handles.gui.fluo==1
    if handles.save.repeat==0
        N=1;
    else
        N=handles.save.repeatN;
    end
    h=waitbar(0,'Acquistion in progess, please wait.');
    for i=1:N
        tic
        if handles.save.zStack==0
            waitbar(i/N)
            handles=acqFluo(handles);
        elseif handles.save.zStack==1
            msgbox('zStack with fluo not implemented yet')
        end
        pause(handles.save.repeatTime-toc)
    end
    saveParameters(handles)
    close(h)
end