function [dataOut,handles]=acqOCTzStack(handles,j)
% Funciton to acquire OCT only images for zStack. Each plane is recorded as the third dimension in
% a 3D array and saved in a multi-dimensionnal tiff file. Parameters are specified into the
% GUI and carried here by handles struct. OCT trigger is done by the
% National Instrument DAQ in order to synchronize the piezo and the camera.

global SignalDAQ acq_state
acq_state=1;

set(handles.octCam.vid, 'TriggerFrameDelay', 10) % We leave the first 10 frames because the camera is not stable
switch handles.exp.piezoMode
    case 1 % Direct image only for zStack
        handles.exp.FramesPerTrigger=handles.octCam.Naccu;
        set(handles.octCam.vid, 'FramesPerTrigger', handles.exp.FramesPerTrigger, 'LoggingMode', 'memory');
        handles=AnalogicSignalOCT(handles);
        if ~isrunning(handles.octCam.vid)
            start(handles.octCam.vid);
            trigger(handles.octCam.vid); % Manually initiate data logging.
        end
        if ~handles.DAQ.s.IsRunning
            queueOutputData(handles.DAQ.s,SignalDAQ);
            startBackground(handles.DAQ.s);
        end
        wait(handles.octCam.vid,5*handles.exp.FramesPerTrigger)
        [data,handles.save.timeOCT,~]=getdata(handles.octCam.vid,handles.exp.FramesPerTrigger,'double');
        dataOut=mean(data,4);
        if handles.save.direct
            saveAsTiff(data,sprintf('dffoct_plane_%d',j),'adimec',handles)
        end
    case 2 % Tomo image for zStack
        handles.exp.FramesPerTrigger=2*handles.octCam.Naccu;
        set(handles.octCam.vid, 'FramesPerTrigger', handles.exp.FramesPerTrigger, 'LoggingMode', 'memory');
        handles=AnalogicSignalOCT(handles);
        if ~isrunning(handles.octCam.vid)
            start(handles.octCam.vid);
            trigger(handles.octCam.vid); % Manually initiate data logging.
        end
        if ~handles.DAQ.s.IsRunning
            queueOutputData(handles.DAQ.s,SignalDAQ);
            startBackground(handles.DAQ.s);
        end
        wait(handles.octCam.vid,5*handles.exp.FramesPerTrigger)
        [data,handles.save.timeOCT,~]=getdata(handles.octCam.vid,handles.exp.FramesPerTrigger,'double');
        dataOut=abs(mean(data(:,:,1,1:2:2*handles.octCam.Naccu),4)-mean(data(:,:,1,2:2:2*handles.octCam.Naccu),4));
        if handles.save.direct
            saveAsTiff(data(:,:,1:2:end),sprintf('dffoct_plane_%d',j),'adimec',handles)
        end
    case 3 % 4 phase imaging
        handles.exp.FramesPerTrigger=4*handles.octCam.Naccu;
        set(handles.octCam.vid, 'FramesPerTrigger', handles.exp.FramesPerTrigger, 'LoggingMode', 'memory');
        handles=AnalogicSignalOCT(handles);
        if ~isrunning(handles.octCam.vid)
            start(handles.octCam.vid);
            trigger(handles.octCam.vid); % Manually initiate data logging.
        end
        if ~handles.DAQ.s.IsRunning
            queueOutputData(handles.DAQ.s,SignalDAQ);
            startBackground(handles.DAQ.s);
        end
        wait(handles.octCam.vid,5*handles.exp.FramesPerTrigger)
        [data,handles.save.timeOCT,~]=getdata(handles.octCam.vid,handles.exp.FramesPerTrigger,'double');
        I1=mean(data(:,:,1,1:4:4*handles.octCam.Naccu),4);
        I2=mean(data(:,:,1,2:4:4*handles.octCam.Naccu),4);
        I3=mean(data(:,:,1,3:4:4*handles.octCam.Naccu),4);
        I4=mean(data(:,:,1,4:4:4*handles.octCam.Naccu),4);
        dataOut=abs(0.5*sqrt((I4-I2).^2+(I1-I3).^2));
        if handles.save.direct
            saveAsTiff(data(:,:,1:4:end),sprintf('dffoct_plane_%d',j),'adimec',handles)
        end
    case 4
end
stop(handles.octCam.vid);
stop(handles.DAQ.s);
set(handles.octCam.vid, 'TriggerFrameDelay', 0)
acq_state=0;