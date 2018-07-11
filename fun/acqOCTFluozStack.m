function [dataOCT,dataFluo,handles]=acqOCTFluozStack(handles,j)
% Funciton to acquire OCT and Fluo images for zStack. Each plane is recorded as the third dimension in
% a 3D array and saved in a multi-dimensionnal tiff file. Parameters are specified into the
% GUI and carried here by handles struct. OCT and fluo triggers are done by the
% National Instrument DAQ in order to synchronize the piezo and the camera.

global SignalDAQ acq_state
acq_state=1;

set(handles.octCam.vid, 'TriggerFrameDelay', 10) % We leave the first 10 frames because the camera is not stable
set(handles.fluoCam.vid, 'TriggerFrameDelay', 10) % We leave the first 10 frames because the camera is not stable
set(handles.fluoCam.vid, 'FramesPerTrigger', handles.fluoCam.Naccu, 'LoggingMode', 'memory');
switch handles.exp.piezoMode
    case 1 % Direct image only for zStack
        set(handles.octCam.vid, 'FramesPerTrigger', handles.octCam.Naccu, 'LoggingMode', 'memory');
        handles=AnalogicSignalOCT(handles);
        if ~isrunning(handles.octCam.vid)
            start(handles.octCam.vid);
            trigger(handles.octCam.vid); % Manually initiate data logging.
        end
        if ~isrunning(handles.fluoCam.vid)
            start(handles.fluoCam.vid);
        end
        if ~handles.DAQ.s.IsRunning
            queueOutputData(handles.DAQ.s,SignalDAQ);
            startBackground(handles.DAQ.s);
        end
        wait(handles.octCam.vid,5*handles.octCam.Naccu)
        [data,handles.save.timeOCT]=getdata(handles.octCam.vid,handles.octCam.Naccu,'double');
        dataOCT=mean(data,4);
        wait(handles.fluoCam.vid,5*handles.fluoCam.Naccu)
        [data,handles.save.timeFluo]=getdata(handles.fluoCam.vid,handles.fluoCam.Naccu,'double');
        dataFluo=mean(data,4);
        if handles.save.direct
            saveAsTiff(data,sprintf('dffoct_plane_%d',j),'adimec',handles)
        end
        move=round(handles.motors.sample.Units.positiontonative(handles.save.zStackStep*1e-6)*5);
        handles.motors.sample.moverelative(move);
        pause(5)
    case 2 % Tomo image for zStack
        set(handles.octCam.vid, 'FramesPerTrigger', 2*handles.octCam.Naccu, 'LoggingMode', 'memory');
        handles=AnalogicSignalOCT(handles);
        if ~isrunning(handles.octCam.vid)
            start(handles.octCam.vid);
            trigger(handles.octCam.vid); % Manually initiate data logging.
        end
        if ~isrunning(handles.fluoCam.vid)
            start(handles.fluoCam.vid);
        end
        if ~handles.DAQ.s.IsRunning
            queueOutputData(handles.DAQ.s,SignalDAQ);
            startBackground(handles.DAQ.s);
        end
        wait(handles.octCam.vid,10*handles.octCam.Naccu)
        [data,handles.save.timeOCT]=getdata(handles.octCam.vid,2*handles.octCam.Naccu,'double');
        dataOCT=abs(mean(data(:,:,1,1:2:2*handles.octCam.Naccu),4)-mean(data(:,:,1,2:2:2*handles.octCam.Naccu),4));
        wait(handles.fluoCam.vid,5*handles.fluoCam.Naccu)
        [data,handles.save.timeFluo]=getdata(handles.fluoCam.vid,handles.fluoCam.Naccu,'double');
        dataFluo=mean(data,4);
        if handles.save.direct
            saveAsTiff(data(:,:,1:2:end),sprintf('dffoct_plane_%d',j),'adimec',handles)
        end
        move=round(handles.motors.sample.Units.positiontonative(handles.save.zStackStep*1e-6)*5);
        handles.motors.sample.moverelative(move);
        pause(5)
    case 3 % 4 phase imaging
        set(handles.octCam.vid, 'FramesPerTrigger', 4*handles.octCam.Naccu, 'LoggingMode', 'memory');
        handles=AnalogicSignalOCT(handles);
        if ~isrunning(handles.octCam.vid)
            start(handles.octCam.vid);
            trigger(handles.octCam.vid); % Manually initiate data logging.
        end
        if ~isrunning(handles.fluoCam.vid)
            start(handles.fluoCam.vid);
        end
        if ~handles.DAQ.s.IsRunning
            queueOutputData(handles.DAQ.s,SignalDAQ);
            startBackground(handles.DAQ.s);
        end
        wait(handles.octCam.vid,20*4*handles.octCam.Naccu)
        [data,handles.save.timeOCT]=getdata(handles.octCam.vid,4*handles.octCam.Naccu,'double');
        I1=mean(data(:,:,1,1:4:4*handles.octCam.Naccu),4);
        I2=mean(data(:,:,1,2:4:4*handles.octCam.Naccu),4);
        I3=mean(data(:,:,1,3:4:4*handles.octCam.Naccu),4);
        I4=mean(data(:,:,1,4:4:4*handles.octCam.Naccu),4);
        dataOCT=0.5*sqrt((I4-I2).^2+(I1-I3).^2);
        wait(handles.fluoCam.vid,5*handles.fluoCam.Naccu)
        [data,handles.save.timeFluo]=getdata(handles.fluoCam.vid,handles.fluoCam.Naccu,'double');
        dataFluo=mean(data,4);
        if handles.save.direct
            saveAsTiff(data(:,:,1:4:end),sprintf('dffoct_plane_%d',j),'adimec',handles)
        end
        move=round(handles.motors.sample.Units.positiontonative(handles.save.zStackStep*1e-6)*5);
        handles.motors.sample.moverelative(move);
        pause(5)
    case 6 % DFFOCT + 2 phases
        % First take tome image with 5 accumulations
        Naccu=handles.octCam.Naccu;
        handles.octCam.Naccu=5;
        handles.exp.piezoMode=2;
        [dataOCT, handles]=oct_2phases(handles);
        handles=drawInGUI(dataOCT,2,handles);
        handles.octCam.Naccu=Naccu;
        
        % Then take DFFOCT and Fluo
        handles.exp.piezoMode=1;
        set(handles.octCam.vid, 'FramesPerTrigger', handles.octCam.Naccu*handles.save.Noct, 'LoggingMode', 'memory');
        set(handles.fluoCam.vid, 'FramesPerTrigger', handles.fluoCam.Naccu*handles.save.Nfluo, 'LoggingMode', 'memory');
        handles=AnalogicSignalOCT(handles);
        if ~isrunning(handles.octCam.vid)
            start(handles.octCam.vid);
            trigger(handles.octCam.vid); % Manually initiate data logging.
        end
        if ~isrunning(handles.fluoCam.vid)
            start(handles.fluoCam.vid);
        end
        if ~handles.DAQ.s.IsRunning
            queueOutputData(handles.DAQ.s,SignalDAQ);
            startBackground(handles.DAQ.s);
        end
        wait(handles.octCam.vid,handles.octCam.Naccu*handles.save.Noct*5)
        [data,handles.save.timeOCT]=getdata(handles.octCam.vid,handles.octCam.Naccu*handles.save.Noct,'double');
        stop(handles.octCam.vid);
        % Move before computation (don't need to pause afterwards)
        move=round(handles.motors.sample.Units.positiontonative(handles.save.zStackStep*1e-6)*5);
        handles.motors.sample.moverelative(move);
        [dffoct, handles]=dffoct_gpu(data, handles);
        handles=drawInGUI(dffoct,6,handles);
        imwrite(dffoct,[handles.save.path '\' handles.save.t '\' sprintf('dffoct_plane_%d.tif',j)]);
        if handles.save.allraw
            saveAsTiff(squeeze(data),sprintf('direct_plane_%d.tif',j),'adimec',handles)
        end
        clear data
        wait(handles.fluoCam.vid,handles.fluoCam.Naccu*handles.save.Nfluo*5)
        [data,handles.save.timeFluo]=getdata(handles.fluoCam.vid,handles.fluoCam.Naccu*handles.save.Nfluo,'double');
        stop(handles.fluoCam.vid);
        stop(handles.DAQ.s);
        if handles.save.fluo
            dataFluo=zeros(size(data,1),size(data,2),handles.save.Nfluo);
            for i=1:handles.save.Nfluo
                dataFluo(:,:,i)=mean(data(:,:,1,(i-1)*handles.fluoCam.Naccu+1:i*handles.fluoCam.Naccu),4);
            end
        end
        % Put back the initial mode
        handles.exp.piezoMode=6;
end
% Stop camera and DAQ and restore parameters
stop(handles.octCam.vid);
stop(handles.fluoCam.vid);
stop(handles.DAQ.s);
set(handles.octCam.vid, 'TriggerFrameDelay', 0)
set(handles.fluoCam.vid, 'TriggerFrameDelay', 0)
acq_state=0;