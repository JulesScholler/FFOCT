function handles=liveFluo(handles)
% Function for live fluo imaging. Trigger is generated numerically with
% the frame grabber.

global acq_state

acq_state=1;

handles.fluoCam.FramesPerTrigger=1;
set(handles.fluoCam.vid, 'FramesPerTrigger', handles.fluoCam.FramesPerTrigger, 'LoggingMode', 'memory');
while acq_state==1
    if ~isrunning(handles.fluoCam.vid)
        start(handles.fluoCam.vid);
        trigger(handles.fluoCam.vid); % Manually initiate data logging.
    end
    while handles.fluoCam.vid.FramesAvailable~=0 || isrunning(handles.fluoCam.vid)
        wait(handles.fluoCam.vid,1)
        data=getdata(handles.fluoCam.vid,handles.fluoCam.vid.FramesAvailable,'double');
        handles=drawInGUI(imresize(data(:,:,1,end),handles.exp.imResize,'bilinear'),4,handles);
    end
end