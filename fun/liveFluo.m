function handles=liveFluo(handles)

global SignalDAQ acq_state

acq_state=1;

% start_camera(handles.fluoCam.glvar.out_ptr);
% 
% handles=AnalogicSignalFluo(handles);
% while acq_state==1
%     if ~handles.DAQ.s.IsRunning
%         queueOutputData(handles.DAQ.s,SignalDAQ);
%         startBackground(handles.DAQ.s);
%     end
%     [data,~]=calllib('GRABFUNC','pco_imagestack',1,handles.fluoCam.glvar.out_ptr,1);
%     handles=drawInGUI(imresize(data,handles.exp.imResize,'bilinear'),4,handles);
% end

handles.fluoCam.FramesPerTrigger=1;
set(handles.fluoCam.vid, 'FramesPerTrigger', handles.fluoCam.FramesPerTrigger, 'LoggingMode', 'memory');
while acq_state==1
    if ~isrunning(handles.fluoCam.vid)
        start(handles.fluoCam.vid);
        trigger(handles.fluoCam.vid); % Manually initiate data logging.
    end
%     if ~handles.DAQ.s.IsRunning
%         queueOutputData(handles.DAQ.s,SignalDAQ);
%         startBackground(handles.DAQ.s);
%     end
    while handles.fluoCam.vid.FramesAvailable~=0 || isrunning(handles.fluoCam.vid)
        wait(handles.fluoCam.vid,1)
        data=getdata(handles.fluoCam.vid,handles.fluoCam.vid.FramesAvailable,'double');
        handles=drawInGUI(imresize(data(:,:,1,end),handles.exp.imResize,'bilinear'),4,handles);
    end
end