function handles=initialisationFluo(handles)
% This functions initiate and sets the configuration with the fluorescence
% camera.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PCO edge 5.5
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% External trig. for synchronous acquisition
handles.fluoCam.vid = videoinput('pcocameraadaptor', 0, 'CameraLink');
handles.fluoCam.src=getselectedsource(handles.fluoCam.vid);
set(handles.fluoCam.vid, 'TriggerRepeat', 0);
handles.fluoCam.src.E1ExposureTime_unit = 'ms';
config=triggerinfo(handles.fluoCam.vid);
triggerconfig(handles.fluoCam.vid, config(4));
set(handles.fluoCam.vid, 'FramesPerTrigger', 1, 'LoggingMode', 'memory');
set(handles.fluoCam.vid, 'Timeout', 1000);
set(handles.fluoCam.vid, 'TimerPeriod', 0.1);
handles.fluoCam.src.E1ExposureTime_unit = 'ms';
handles.fluoCam.Fcam=20;
handles.fluoCam.ExpTime=10; % ms
handles.fluoCam.src.E2ExposureTime = handles.fluoCam.ExpTime;
handles.fluoCam.Naccu=1;
handles.fluoCam.X0=0;
handles.fluoCam.Y0=0;
handles.fluoCam.Nx=2160;
handles.fluoCam.Ny=2560;
handles.fluoCam.src.PCPixelclock_Hz='286000000';  % Hz to pass as string (THX PCO !)
handles.fluoCam.src.FRFrameRate_mHz=20000; % mHz
handles.fluoCam.src.FMFpsBased='on';
handles.fluoCam.param=get(handles.fluoCam.src);

% Internal trig. for preview/asynchronous acquisition
handles.fluoCam.vid_preview = videoinput('pcocameraadaptor', 0, 'CameraLink');
handles.fluoCam.src_preview=getselectedsource(handles.fluoCam.vid_preview);
handles.fluoCam.src_preview.E1ExposureTime_unit = 'ms';
triggerconfig(handles.fluoCam.vid_preview, 'immediate');
handles.fluoCam.vid_preview.FramesPerTrigger = 1;