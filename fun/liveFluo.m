function handles=liveFluo(handles)
% Function for live fluo imaging. Trigger is generated numerically with
% the frame grabber.

global acq_state SignalDAQ

acq_state=1;

handles.fluoCam.FramesPerTrigger=handles.fluoCam.Naccu;
set(handles.fluoCam.vid, 'FramesPerTrigger', handles.fluoCam.FramesPerTrigger, 'LoggingMode', 'memory');
handles=AnalogicSignalOCT(handles);
while acq_state==1
    if ~isrunning(handles.fluoCam.vid)
        start(handles.fluoCam.vid);
    end
    if ~handles.DAQ.s.IsRunning
        queueOutputData(handles.DAQ.s,SignalDAQ);
        startBackground(handles.DAQ.s);
    end
    wait(handles.fluoCam.vid,handles.fluoCam.FramesPerTrigger*5)
    data=getdata(handles.fluoCam.vid,handles.fluoCam.FramesPerTrigger,'double');
    handles=drawInGUI(imresize(mean(data(:,:,1,:),4),handles.exp.imResize,'bilinear'),4,handles);
%     handles=drawInGUI(imresize(log(abs(fftshift(fft2(mean(data(:,:,1,:),4))))),handles.exp.imResize,'bilinear'),4,handles);
end

stop(handles.fluoCam.vid)