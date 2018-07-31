function handles=liveOCT(handles)
% Function for live OCT and fluo imaging. Trigger is generated with the DAQ.

global SignalDAQ acq_state
acq_state=1;

switch handles.exp.piezoMode
    case 1 % Direct image only
        if handles.octCam.Naccu==1
            handles.octCam.FramesPerTrigger=inf;
            set(handles.octCam.vid, 'FramesPerTrigger', handles.octCam.FramesPerTrigger, 'LoggingMode', 'memory');
            handles=AnalogicSignalOCT(handles);
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
                        handles=drawInGUI(imresize(data(:,:,1,end),handles.exp.imResize,'bilinear'),1,handles);
%                         handles=drawInGUI(data(:,:,1,end),5,handles);
%                         handles=drawInGUI(imresize(log(abs(fftshift(fft2(data(:,:,1,end))))),handles.exp.imResize,'bilinear'),1,handles);
                    end
                end
            end
%             hImage=image(zeros(1440,1440),'Parent',handles.axesDirectOCT);
%             preview(handles.octCam.vid_preview, hImage);
%             start(handles.octCam.vid_preview);
        else
            handles.octCam.FramesPerTrigger=handles.octCam.Naccu;
            set(handles.octCam.vid, 'FramesPerTrigger', handles.octCam.FramesPerTrigger, 'LoggingMode', 'memory');
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
                wait(handles.octCam.vid,10)
                data=getdata(handles.octCam.vid,handles.octCam.Naccu,'double');
                handles=drawInGUI(imresize(mean(data,4),handles.exp.imResize,'bilinear'),1,handles);
            end
        end
    case 2
        handles.octCam.FramesPerTrigger=2*handles.octCam.Naccu;
        set(handles.octCam.vid, 'FramesPerTrigger', handles.octCam.FramesPerTrigger, 'LoggingMode', 'memory');
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
            wait(handles.octCam.vid,10)
            data=getdata(handles.octCam.vid,handles.octCam.FramesPerTrigger,'double');
            imTomo=abs(mean(data(:,:,1,1:2:2*handles.octCam.Naccu),4)-mean(data(:,:,1,2:2:2*handles.octCam.Naccu),4));
            %                     handles=drawInGUI(imresize(mean(data,4),handles.exp.imResize,'bilinear'),1,handles);
            handles=drawInGUI(imresize(data(:,:,1,end),handles.exp.imResize,'bilinear'),1,handles);
            handles=drawInGUI(imresize(imTomo,handles.exp.imResize,'bilinear'),2,handles);
        end
    case 3 % 4 phase imaging
        handles.octCam.FramesPerTrigger=4*handles.octCam.Naccu;
        set(handles.octCam.vid, 'FramesPerTrigger', handles.octCam.FramesPerTrigger, 'LoggingMode', 'memory');
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
            wait(handles.octCam.vid,10)
            data=getdata(handles.octCam.vid,handles.octCam.FramesPerTrigger,'double');
            I1=double(mean(data(:,:,1,1:2:4*handles.octCam.Naccu),4));
            I2=double(mean(data(:,:,1,2:2:4*handles.octCam.Naccu),4));
            I3=double(mean(data(:,:,1,3:2:4*handles.octCam.Naccu),4));
            I4=double(mean(data(:,:,1,4:2:4*handles.octCam.Naccu),4));
            imAmplitude=0.5*sqrt((I4-I2).^2+(I1-I3).^2);
            imPhase=angle((I4-I2)+1i*(I3-I1));
            handles=drawInGUI(imresize(data(:,:,1,end),handles.exp.imResize,'bilinear'),1,handles);
            handles=drawInGUI(imresize(imAmplitude,handles.exp.imResize,'bilinear'),2,handles);
            handles=drawInGUI(imresize(imPhase,handles.exp.imResize,'bilinear'),3,handles);
        end
    case 4 % 5 phases imaging
        handles.octCam.FramesPerTrigger=10*handles.octCam.Naccu;
        set(handles.octCam.vid, 'FramesPerTrigger', handles.octCam.FramesPerTrigger, 'LoggingMode', 'memory');
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
            wait(handles.octCam.vid,10)
            data=getdata(handles.octCam.vid,handles.octCam.FramesPerTrigger,'double');
            I1=double(mean(data(:,:,1,1:10:10*handles.octCam.Naccu),4)+mean(data(:,:,1,10:10:10*handles.octCam.Naccu),4))/2;
            I2=double(mean(data(:,:,1,2:10:10*handles.octCam.Naccu),4)+mean(data(:,:,1,9:10:10*handles.octCam.Naccu),4))/2;
            I3=double(mean(data(:,:,1,3:10:10*handles.octCam.Naccu),4)+mean(data(:,:,1,8:10:10*handles.octCam.Naccu),4))/2;
            I4=double(mean(data(:,:,1,4:10:10*handles.octCam.Naccu),4)+mean(data(:,:,1,7:10:10*handles.octCam.Naccu),4))/2;
            I5=double(mean(data(:,:,1,5:10:10*handles.octCam.Naccu),4)+mean(data(:,:,1,6:10:10*handles.octCam.Naccu),4))/2;
            imAmplitude=sqrt(abs((I2-I4).^2-(I1-I3).*(I3-I5)))/4;
            imPhase=angle((-I1+2*I3-I5)+1i*(4*(I2-I4).^2-(I1-I5).^2));
            handles=drawInGUI(imresize(data(:,:,1,end),handles.exp.imResize,'bilinear'),1,handles);
            handles=drawInGUI(imresize(imAmplitude,handles.exp.imResize,'bilinear'),2,handles);
            handles=drawInGUI(imresize(imPhase,handles.exp.imResize,'bilinear'),3,handles);
        end
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
stop(handles.DAQ.s);