function handles=liveOCTFluo(handles)
% Function for live OCT and fluo imaging.
% OCT : trigger is generated with the DAQ.
% Fluo : trigger is generated numerically with the frame grabber.

global SignalDAQ acq_state
acq_state=1;

switch handles.exp.piezoMode
    case 1 % Direct image only
        handles.octCam.FramesPerTrigger=handles.octCam.Naccu;
        set(handles.octCam.vid, 'FramesPerTrigger', handles.octCam.FramesPerTrigger, 'LoggingMode', 'memory');
        handles.fluoCam.FramesPerTrigger=handles.fluoCam.Naccu;
        set(handles.fluoCam.vid, 'FramesPerTrigger', handles.fluoCam.FramesPerTrigger, 'LoggingMode', 'memory');
        handles=AnalogicSignalOCT(handles);
        while acq_state==1
            if ~isrunning(handles.octCam.vid)
                start(handles.octCam.vid);
                trigger(handles.octCam.vid); % Manually initiate data logging.
            end
            if ~handles.DAQ.s.IsRunning
                queueOutputData(handles.DAQ.s,SignalDAQ);
                startBackground(handles.DAQ.s);
            end
            if ~isrunning(handles.fluoCam.vid)
                start(handles.fluoCam.vid);
                trigger(handles.fluoCam.vid); % Manually initiate data logging.
            end
            wait(handles.octCam.vid,1)
            data=getdata(handles.octCam.vid,handles.octCam.vid.FramesAvailable,'double');
            handles=drawInGUI(imresize(mean(data,4),handles.exp.imResize,'bilinear'),1,handles);
            wait(handles.fluoCam.vid,1)
            data=getdata(handles.fluoCam.vid,handles.fluoCam.vid.FramesAvailable,'double');
            handles=drawInGUI(imresize(mean(data,4),handles.exp.imResize,'bilinear'),4,handles);
        end
    case 2
        handles.octCam.FramesPerTrigger=2*handles.octCam.Naccu;
        set(handles.octCam.vid, 'FramesPerTrigger', handles.octCam.FramesPerTrigger, 'LoggingMode', 'memory');
        handles.fluoCam.FramesPerTrigger=handles.fluoCam.Naccu;
        set(handles.fluoCam.vid, 'FramesPerTrigger', handles.fluoCam.FramesPerTrigger, 'LoggingMode', 'memory');
        handles=AnalogicSignalOCT(handles);
        while acq_state==1
            if ~isrunning(handles.octCam.vid)
                start(handles.octCam.vid);
                trigger(handles.octCam.vid); % Manually initiate data logging.
            end
            if ~handles.DAQ.s.IsRunning
                queueOutputData(handles.DAQ.s,SignalDAQ);
                startBackground(handles.DAQ.s);
            end
            if ~isrunning(handles.fluoCam.vid)
                start(handles.fluoCam.vid);
                trigger(handles.fluoCam.vid); % Manually initiate data logging.
            end
            wait(handles.octCam.vid,3)
            data=getdata(handles.octCam.vid,handles.octCam.FramesPerTrigger,'double');
            imTomo=abs(mean(data(:,:,1,1:2:2*handles.octCam.Naccu),4)-mean(data(:,:,1,2:2:2*handles.octCam.Naccu),4));
            handles=drawInGUI(imresize(data(:,:,1,end),handles.exp.imResize,'bilinear'),1,handles);
            handles=drawInGUI(imresize(imTomo,handles.exp.imResize,'bilinear'),2,handles);
            wait(handles.fluoCam.vid,1)
            data=getdata(handles.fluoCam.vid,handles.fluoCam.vid.FramesAvailable,'double');
            handles=drawInGUI(imresize(mean(data,4),handles.exp.imResize,'bilinear'),4,handles);
        end
    case 3 % 4 phase imaging
        handles.octCam.FramesPerTrigger=4*handles.octCam.Naccu;
        set(handles.octCam.vid, 'FramesPerTrigger', handles.octCam.FramesPerTrigger, 'LoggingMode', 'memory');
        handles.fluoCam.FramesPerTrigger=handles.fluoCam.Naccu;
        set(handles.fluoCam.vid, 'FramesPerTrigger', handles.fluoCam.FramesPerTrigger, 'LoggingMode', 'memory');
        handles=AnalogicSignalOCT(handles);
        while acq_state==1
            if ~isrunning(handles.octCam.vid)
                start(handles.octCam.vid);
                trigger(handles.octCam.vid); % Manually initiate data logging.
            end
            if ~handles.DAQ.s.IsRunning
                queueOutputData(handles.DAQ.s,SignalDAQ);
                startBackground(handles.DAQ.s);
            end
            if ~isrunning(handles.fluoCam.vid)
                start(handles.fluoCam.vid);
                trigger(handles.fluoCam.vid); % Manually initiate data logging.
            end
            wait(handles.octCam.vid,5)
            data=getdata(handles.octCam.vid,handles.octCam.FramesPerTrigger,'double');
            I1=mean(data(:,:,1,1:2:4*handles.octCam.Naccu),4);
            I2=mean(data(:,:,1,2:2:4*handles.octCam.Naccu),4);
            I3=mean(data(:,:,1,3:2:4*handles.octCam.Naccu),4);
            I4=mean(data(:,:,1,4:2:4*handles.octCam.Naccu),4);
            imAmplitude=abs(0.5*sqrt((I4-I2).^2+(I1-I3).^2));
            phi=atan((I1-I3)./(I4-I2));
            imPhase=angle(cos(phi)+1i*sin(phi));
            handles=drawInGUI(imresize(data(:,:,1,end),handles.exp.imResize,'bilinear'),1,handles);
            handles=drawInGUI(imresize(imAmplitude,handles.exp.imResize,'bilinear'),2,handles);
            handles=drawInGUI(imresize(imPhase,handles.exp.imResize,'bilinear'),3,handles);
            wait(handles.fluoCam.vid,1)
            data=getdata(handles.fluoCam.vid,handles.fluoCam.vid.FramesAvailable,'double');
            handles=drawInGUI(imresize(mean(data,4),handles.exp.imResize,'bilinear'),4,handles);
        end
        
    case 4
    case 5 % D-FF-OCT
        handles.octCam.FramesPerTrigger=inf;
        set(handles.octCam.vid, 'FramesPerTrigger', handles.octCam.FramesPerTrigger, 'LoggingMode', 'memory');
        handles=AnalogicSignalOCT(handles);
        cnt=0;
        m=0;
        M=0;
        while acq_state==1
            flushdata(handles.octCam.vid)
            if ~isrunning(handles.octCam.vid)
                start(handles.octCam.vid);
                trigger(handles.octCam.vid); % Manually initiate data logging.
            end
            if ~handles.DAQ.s.IsRunning
                queueOutputData(handles.DAQ.s,SignalDAQ);
                startBackground(handles.DAQ.s);
            end
            while (handles.octCam.vid.FramesAvailable~=0 || isrunning(handles.octCam.vid)) && acq_state==1
                if handles.octCam.vid.FramesAvailable>0
                    data=getdata(handles.octCam.vid,handles.octCam.vid.FramesAvailable,'double');
                    [m,M]=online_std(data(:,:,1,end),M,m,cnt);
                    cnt=cnt+1;
                    handles=drawInGUI(imresize(data(:,:,1,end),handles.exp.imResize,'bilinear'),1,handles);
                    if cnt>2
                        imagesc(handles.axesAmplitude,imresize(log(sqrt(M/(cnt-1))),handles.exp.imResize,'bilinear'));
                    end
                end
            end
        end
end
stop(handles.octCam.vid);
stop(handles.fluoCam.vid);
stop(handles.DAQ.s);