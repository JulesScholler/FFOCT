function handles=initialisationFluo(handles)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Défintion paramètres PCO.edge
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

handles.fluoCam.vid = videoinput('pcocameraadaptor', 0, 'CameraLink');
handles.fluoCam.src=getselectedsource(handles.fluoCam.vid);

set(handles.fluoCam.vid, 'TriggerRepeat', 0);
triggerconfig(handles.fluoCam.vid, 'Manual');
set(handles.fluoCam.vid, 'FramesPerTrigger', 1, 'LoggingMode', 'memory');
set(handles.fluoCam.vid, 'Timeout', 25);
set(handles.fluoCam.vid, 'TimerPeriod', 0.1);
handles.fluoCam.Fcam=20;
handles.fluoCam.ExpTime=10; % ms
handles.fluoCam.Naccu=1;
handles.fluoCam.X0=0;
handles.fluoCam.Y0=0;
handles.fluoCam.Nx=2160;
handles.fluoCam.Ny=2560;
handles.fluoCam.src.PCPixelclock_Hz='286000000';  % Hz to pass as string (THX PCO !)
handles.fluoCam.src.E2ExposureTime=10000; % us
handles.fluoCam.src.FRFrameRate_mHz=20000; % mHz
handles.fluoCam.src.FMFpsBased='on';

handles.fluoCam.param=get(handles.fluoCam.src);


%Definition of the structure glvar that will contain the parameters of the camera
% handles.fluoCam.glvar=struct('do_libunload',0,'do_close',0,'camera_open',0,'out_ptr',[]); % Initialisation de la structure caméra
% [~,handles.fluoCam.glvar]=pco_camera_open_close(handles.fluoCam.glvar); % Permet d'ouvrir les libraires et caméra si fermées, et de les fermer si elles sont ouvertes.
% %Description Camera
% handles.fluoCam.cam_desc=libstruct('PCO_Description');
% set(handles.fluoCam.cam_desc,'wSize',handles.fluoCam.cam_desc.structsize);
% [errorCode,handles.fluoCam.glvar.out_ptr,handles.fluoCam.cam_desc] = calllib('PCO_CAM_SDK', 'PCO_GetCameraDescription', handles.fluoCam.glvar.out_ptr,handles.fluoCam.cam_desc);
% pco_errdisp('PCO_GetCameraDescription',errorCode);
% %Description of how the time at which the image was taken is displayed on
% %the image (cf. PCO description)
% enable_timestamp(handles.fluoCam.glvar.out_ptr,1);
% %"2" Default value. Image Time is encoded within the first 14 pixels + is
% %written in ASCII text. However, the text saturates the image and it is
% %required to remove the first line of the image.
% %"O" = Don t save the image time
% %"1" = Encode the time within the first 14 pixels
% %"3" = Write the time in ASCII text only.
% %%Pixel rate. Increase the pixel rate will increase the frame rate, but
% %%increase the noise
% %set_pixelrate(handles.fluoCam.glvar.out_ptr,1); %Pixelrate=95.3MHz
% set_pixelrate(handles.fluoCam.glvar.out_ptr,2); % Pixelrate=286MHz

%Set Trigger

%Trigger: select trigger mode of camera. AUTOTRIGGER en Live et EXTERNAL
%TRIG dans la fonction Save
%            0: TRIGGER_MODE_AUTOTRIGGER
%            1: TRIGGER_MODE_SOFTWARETRIGGER
%            2: TRIGGER_MODE_EXTERNALTRIGGER
%            3: TRIGGER_MODE_EXTERNALEXPOSURECONTROL:

% Trig=uint16(0);
% [errorCode,handles.fluoCam.glvar.out_ptr] = calllib('PCO_CAM_SDK', 'PCO_SetTriggerMode', handles.fluoCam.glvar.out_ptr,Trig);
% pco_errdisp('PCO_SetTriggerMode',errorCode);
% handles.fluoCam.ExpTime=get_exposure_time(handles.fluoCam.glvar.out_ptr);
% handles.fluoCam.Fcam=show_frametime(handles.fluoCam.glvar.out_ptr); % Displays and saves frame rate
% handles.fluoCam.FMax=handles.fluoCam.Fcam;
% handles.fluoCam.Fcam=handles.DAQ.s.Rate/ceil(handles.DAQ.s.Rate/handles.fluoCam.Fcam);
% % Bit alignement
% handles.fluoCam.act_align=uint16(1); % Bit alignement to LSB(=Least Significant Byte). Save how to align the pixel values to rewrite them from 14 bits to 16 bits (cd PCO doc.). Basically, it tells if the two additional bits should go to the left or to the right of the 14bits number.
% [errorCode,handles.fluoCam.glvar.out_ptr] = calllib('PCO_CAM_SDK', 'PCO_SetBitAlignment', handles.fluoCam.glvar.out_ptr,handles.fluoCam.act_align);
% pco_errdisp('PCO_SetBitAlignment',errorCode);
% handles.fluoCam.bitpix=uint16(handles.fluoCam.cam_desc.wDynResDESC);
% % Get the frame Size defined previously (in this software, or in PCO Camware)
% x0=uint16(0);
% y0=uint16(0);
% x1=uint16(0);
% y1=uint16(0);
% [errorCode,handles.fluoCam.glvar.out_ptr,x0,y0,x1,y1] = calllib('PCO_CAM_SDK', 'PCO_GetROI', handles.fluoCam.glvar.out_ptr,x0,y0,x1,y1);
% pco_errdisp('PCO_GetROI',errorCode);
% handles.fluoCam.X0=double(x0);
% handles.fluoCam.Y0=double(y0);
% handles.fluoCam.Nx=double(x1-x0 + 1);
% handles.fluoCam.Ny=double(y1-y0 + 1);
% % Définition de la taille de l'image à transférer! Essentiel
% handles.fluoCam.act_xsize=uint16(0);
% handles.fluoCam.act_ysize=uint16(0);
% handles.fluoCam.max_xsize=uint16(0);
% handles.fluoCam.max_ysize=uint16(0);
% 
% %use PCO_GetSizes because this always returns accurat image size for next recording
% [errorCode,handles.fluoCam.glvar.out_ptr,handles.fluoCam.act_xsize,handles.fluoCam.act_ysize]  = calllib('PCO_CAM_SDK', 'PCO_GetSizes', handles.fluoCam.glvar.out_ptr,handles.fluoCam.act_xsize,handles.fluoCam.act_ysize,handles.fluoCam.max_xsize,handles.fluoCam.max_ysize);
% pco_errdisp('PCO_GetSizes',errorCode);
% 
% %%The next function is crucial to  record the entire frame at the requested
% %%size
% [errorCode,handles.fluoCam.glvar.out_ptr]  = calllib('PCO_CAM_SDK', 'PCO_CamLinkSetImageParameters', handles.fluoCam.glvar.out_ptr,handles.fluoCam.act_xsize,handles.fluoCam.act_ysize);
% pco_errdisp('PCO_CamLinkSetImageParameters',errorCode);
% 
% if(~libisloaded('GRABFUNC'))
%     loadlibrary('grabfunc','grabfunc.h','alias','GRABFUNC')
% end
% 
% calllib('GRABFUNC','pco_edge_transferpar',handles.fluoCam.glvar.out_ptr);% ATTENTION! Works only in Rolling shutter Mode. Olny useful in Rolling shutter mode anyway. It is needed if the required transfer rate exceeds the ability of the two CameraLinks. It then transform 14bits data to 12 bits, and define a square root LUT to increase the dynamics, even with 12bits.
