function [dataOCT,dataFluo,handles]=acqOCTFluozStack(handles)
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
        dataOCT=abs(0.5*sqrt((I4-I2).^2+(I1-I3).^2));
        wait(handles.fluoCam.vid,5*handles.fluoCam.Naccu)
        [data,handles.save.timeFluo]=getdata(handles.fluoCam.vid,handles.fluoCam.Naccu,'double');
        dataFluo=mean(data,4);
    case 4
end
% Stop camera and DAQ ant restore parameters
stop(handles.octCam.vid);
stop(handles.fluoCam.vid);
stop(handles.DAQ.s);
set(handles.octCam.vid, 'TriggerFrameDelay', 0)
set(handles.fluoCam.vid, 'TriggerFrameDelay', 0)
acq_state=0;