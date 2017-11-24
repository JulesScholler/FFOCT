function handles=findBestAmplitude(handles)

global SignalDAQ

h=waitbar(0,'Processing, please wait.');
set(handles.octCam.vid, 'TriggerFrameDelay', 10) % We leave the first 10 frames because the camera is not stable
handles.exp.FramesPerTrigger=4*10;
set(handles.octCam.vid, 'FramesPerTrigger', handles.exp.FramesPerTrigger, 'LoggingMode', 'memory');
amp=6:0.05:6.6;
for i=1:length(amp)
    waitbar(i/length(amp))
    handles.exp.AmplPiezo=amp(i);
    handles=AnalogicSignalGenerationContinuous(handles);
    if ~isrunning(handles.octCam.vid)
        start(handles.octCam.vid);
        trigger(handles.octCam.vid); % Manually initiate data logging.
    end
    if ~handles.DAQ.s.IsRunning
        queueOutputData(handles.DAQ.s,SignalDAQ);
        startBackground(handles.DAQ.s);
    end
    wait(handles.octCam.vid,10)
    data=getdata(handles.octCam.vid,handles.exp.FramesPerTrigger,'double');
    I1=mean(data(:,:,1,1:2:4*handles.exp.Naccu),4);
    I2=mean(data(:,:,1,2:2:4*handles.exp.Naccu),4);
    I3=mean(data(:,:,1,3:2:4*handles.exp.Naccu),4);
    I4=mean(data(:,:,1,4:2:4*handles.exp.Naccu),4);
    imAmplitude=abs(0.5*sqrt((I4-I2).^2+(I1-I3).^2));
    maxI=sort(imAmplitude(:));
    N=round(handles.octCam.Nx*handles.octCam.Ny/10000);
    a=mean(maxI(1:N));
    b=mean(maxI(end-N:end));
    metric(i)=100*(b-a);
    metric2(i)=sum(imAmplitude(:));
    metric3(i)=sum(imAmplitude(:).^2);
end
close(h)
figure
plot(amp,metric)
xlabel 'Amplitude [V.]'
ylabel 'Metric function [a.u.]'
set(handles.octCam.vid, 'TriggerFrameDelay', 0) % We leave the first 10 frames because the camera is not stable