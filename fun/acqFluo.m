function handles=acqFluo(handles)
% Function to acquire fluo only images. Parameters are specified into the
% GUI and carried here by handles struct.

global acq_state SignalDAQ
acq_state=1;

handles.save.t = datestr(now,'yyyy_mm_dd_HH_MM_ss');
mkdir([handles.save.path '\' handles.save.t ])

set(handles.fluoCam.vid, 'TriggerFrameDelay', 10) % We leave the first 10 frames because the camera is not stable

set(handles.fluoCam.vid, 'FramesPerTrigger', handles.fluoCam.Naccu*handles.save.Nfluo, 'LoggingMode', 'memory');
handles=AnalogicSignalOCT(handles);
if ~isrunning(handles.fluoCam.vid)
    start(handles.fluoCam.vid);
end
if ~handles.DAQ.s.IsRunning
    queueOutputData(handles.DAQ.s,SignalDAQ);
    startBackground(handles.DAQ.s);
end
wait(handles.fluoCam.vid,handles.fluoCam.Naccu*handles.save.Nfluo*5)
[data,handles.save.timeFluo]=getdata(handles.fluoCam.vid,handles.fluoCam.Naccu*handles.save.Nfluo,'double');
stop(handles.fluoCam.vid);
if handles.save.fluo
    fluo=zeros(size(data,1),size(data,2),handles.save.Nfluo);
    for i=1:handles.save.Nfluo
        fluo(:,:,i)=mean(data(:,:,1,(i-1)*handles.fluoCam.Naccu+1:i*handles.fluoCam.Naccu),4);
    end
    saveAsTiff(fluo,'fluo','pco',handles)
end

set(handles.fluoCam.vid, 'TriggerFrameDelay', 0)

acq_state=0;