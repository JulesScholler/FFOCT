function handles=spatiale_coherence(handles)

global SignalDAQ

handles.save.allraw=1;
handles.save.direct=1;
handles.save.amplitude=1;
handles.save.phase=0;
handles.save.path='C:\Users\OCTfast\Desktop\Mesures\coherence_investigation\mesures';
handles.save.format=1;
handles.exp.imresize=1;

x=2;
move_sample=round(handles.motors.sample.Units.positiontonative(x*1e-6)*5); % Translates the value in microns to the number of microsteps. We multiply by 5 for the Thorlabs translation stage.
move_ref=round(handles.motors.ref.Units.positiontonative(x*1e-6)*1.41);


% 4 Phases
for i = 1:200
    [direct(:,:,i),amplitude(:,:,i)] = take_image(handles);
    drawInGUI(direct(:,:,i),1,handles)
    drawInGUI(amplitude(:,:,i),2,handles)
    handles.motors.ref.moverelative(move_ref);
    handles.motors.sample.moverelative(move_sample);
    pause(1)
end
handles.save.t = datestr(now,'yyyy_mm_dd_HH_MM_ss');
mkdir([handles.save.path '\' handles.save.t ])
saveAsTiff(direct, 'direct.tif', 'adimec', handles)
saveAsTiff(amplitude, 'amplitude.tif', 'adimec', handles)

    function [direct, amplitude] = take_image(handles)
        set(handles.octCam.vid, 'TriggerFrameDelay', 10)
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
        amplitude=0.5*sqrt((I4-I2).^2+(I1-I3).^2);
        direct=(I1+I2+I3+I4)/4;
        stop(handles.octCam.vid);
        stop(handles.DAQ.s);
    end
end