% Jules Scholler - October 2017

% Variable to pass:
% hObject    handle to pushSampleMotorPosition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Types of functions:
% CreateFcn: Executes during object creation, after setting all properties.
% Callback:  Execute during callback event.

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Initialisation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = gui(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before gui is made visible.
function gui_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
addpath('..\');
addpath('fun\'); % Add function folder that contains all the useful things for the gui.
addpath('lib\');
button = questdlg('Which configuration would you like to use?','FFOCT','FFOCT + Fluo','FFOCT + SDOCT','FFOCT inverse','FFOCT + Fluo'); % Ask which configuration to use.
switch button
    case 'FFOCT + Fluo'
        handles.gui.mode=1;
    case 'FFOCT + SDOCT'
        handles.gui.mode=2;
        set(handles.checkFluo,'string','SDOCT')
        set(handles.uipanelSampleMotor,'visible','off')
        set(handles.uipanelRefMotor,'visible','off')
        set(handles.uipanelFluo,'visible','off')
        set(handles.checkboxFluo,'visible','off')
        set(handles.editNbImFluo,'visible','off')
        set(handles.text53,'visible','off')
        set(handles.panelFluo,'title','SDOCT BScan')
    case 'FFOCT inverse'
        handles.gui.mode=3;
        set(handles.checkFluo,'visible','off')
        set(handles.uipanelFluo,'visible','off')
        set(handles.checkboxFluo,'visible','off')
        set(handles.editNbImFluo,'visible','off')
        set(handles.text53,'visible','off')
        set(handles.panelFluo,'visible','off')
end
handles=initialisationGUI(handles); % Initialize GUI
handles=initialisationDAQ(handles); % Initialize DAQ (National Instrument)
handles=initialisationMotors(handles); % Initialize motors (Zaber, needs toolbox installed).
guidata(hObject, handles); % Update handles structure


% --- Do not edit
function varargout = gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  GUI Mode
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check if the user wants to use OCT, fluo or both modes.

% OCT mode
function checkOCT_Callback(hObject, eventdata, handles)
handles.gui.oct=get(hObject,'value');
if handles.gui.oct==1
    set(handles.panelOCTdirect,'Visible','on')
    set(handles.panelOCTtomo,'Visible','on')
    if ~isfield(handles,'octCam')
        handles = initialisationOCT(handles);
    end
elseif handles.gui.oct==0
    set(handles.panelOCTdirect,'Visible','off')
    set(handles.panelOCTtomo,'Visible','off')
end
guidata(hObject,handles)

% Fluo mode
function checkFluo_Callback(hObject, eventdata, handles)
if handles.gui.mode==1
    handles.gui.fluo=get(hObject,'value');
    if handles.gui.fluo==1
        set(handles.panelFluo,'Visible','on')
        if ~isfield(handles,'fluoCam')
            handles = initialisationFluo(handles);
        end
    elseif handles.gui.fluo==0
        set(handles.panelFluo,'Visible','off')
    end
elseif handles.gui.mode==2
    handles.gui.sdoct=get(hObject,'value');
    if handles.gui.sdoct==1
        set(handles.panelFluo,'Visible','on')
        if ~isfield(handles,'fluoCam')
            handles = initialisationSDOCT(handles);
        end
    elseif handles.gui.SDOCT==0
        set(handles.panelFluo,'Visible','off')
    end
end
guidata(hObject,handles)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  General
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback functions related to the general panel (start live image, etc.).

% Starts live image.
function pushLiveImage_Callback(hObject, eventdata, handles)
set(hObject,'backgroundcolor',[0.94 0.94 0.94])
set(handles.pushStop,'backgroundcolor',[1 0 0])
if handles.gui.oct==1 && handles.gui.fluo==1
    handles=liveOCTFluo(handles);
elseif handles.gui.oct==1
    handles=liveOCT(handles);
elseif handles.gui.fluo==1
    handles=liveFluo(handles);
else
    msgbox('Nothing to start (tick at least one imaging mode).')
end
guidata(hObject,handles)

% Stops live image.
function pushStop_Callback(hObject, eventdata, handles)
global acq_state
acq_state=0;
daq_output_zero(handles)
if isfield(handles,'octCam')
    if(isrunning(handles.octCam.vid))
        stop(handles.octCam.vid);
    end
end
if isfield(handles,'fluoCam')
    if(isrunning(handles.fluoCam.vid))
        stop(handles.fluoCam.vid);
    end
end
set(hObject,'backgroundcolor',[0.94 0.94 0.94])
set(handles.pushLiveImage,'backgroundcolor',[0.47 0.67 0.19])
guidata(hObject,handles)

% Quit GUI and release created objects and links to hardware.
function pushQuit_Callback(hObject, eventdata, handles)
quitgui(handles)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  OCT Camera Settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback function related to the ADIMEC camera. It is interfaced through
% a frame grabber (Bitflow) by the image acquisition toolbox. Note that the
% camera is always trigged by the DAQ in order to be synchronized with the
% piezo for producing OCT images. It is possible to trig it numerically but
% the synchronization with the piezo cannot be guaranted.

% Change the camera frame rate.
function editFrameRate_Callback(hObject, eventdata, handles)
handles.octCam.FcamOCT=str2double(get(handles.editFrameRate,'String'));
handles.octCam.FrameTime=1000/handles.octCam.FcamOCT; % ms
if handles.octCam.FrameTime<(handles.octCam.ExpTime+0.2) % Condition to be satisfied for correct imaging.
    handles.octCam.ExpTime=handles.octCam.FrameTime-0.2;
end
% Update GUI with new values.
set(handles.editFrameRate, 'String', num2str(handles.octCam.FcamOCT));
set(handles.editExposureTime, 'String', num2str(handles.octCam.ExpTime));
guidata(hObject,handles)

function editFrameRate_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% Change the camera exposure time.
function editExposureTime_Callback(hObject, eventdata, handles)
handles.octCam.ExpTime=str2double(get(hObject, 'String'));
if  (handles.octCam.ExpTime+0.2)>1000/handles.octCam.FcamOCT
    handles.octCam.FcamOCT=1000/(handles.octCam.ExpTime+0.2); % Condition to be satisfied for correct imaging.
end
% Update the GUI with new values.
set(handles.editFrameRate, 'String', num2str(handles.octCam.FcamOCT));
set(handles.editExposureTime, 'String', num2str(handles.octCam.ExpTime));
guidata(hObject,handles)

function editExposureTime_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% Change the number of accumulation (averaged images).
function editNbAccumulations_Callback(hObject, eventdata, handles)
handles.octCam.Naccu=str2double(get(handles.editNbAccumulations,'String'));
guidata(hObject,handles)

function editNbAccumulations_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% Function to draw the ROI on the live image.
function pushDrawROI_Callback(hObject, eventdata, handles)
global acq_state
if acq_state==0
    axes(handles.axesDirectOCT)
    x=round(ginput(2)/handles.exp.imResize);
    handles.octCam.X0=min(x(:,1))-1;
    handles.octCam.Y0=min(x(:,2))-1;
    handles.octCam.Nx=max(x(:,1))-handles.octCam.X0;
    handles.octCam.Ny=max(x(:,2))-handles.octCam.Y0;
    set(handles.editROI_X0,'String',num2str(handles.octCam.X0))
    set(handles.editROI_Y0,'String',num2str(handles.octCam.Y0))
    set(handles.editROI_Width,'String',num2str(handles.octCam.Nx))
    set(handles.editROI_Height,'String',num2str(handles.octCam.Ny))
%     set(handles.octCam.vid,'ROIPosition',[handles.octCam.X0 handles.octCam.Y0 handles.octCam.Nx handles.octCam.Ny]);
    set(handles.octCam.vid,'ROIPosition',[handles.octCam.X0 1440-handles.octCam.Ny handles.octCam.Nx handles.octCam.Ny]);
else
    msgbox('Stop live before drawing the ROI.')
end
guidata(hObject,handles)

% Reset the ROI to the initial parameters (full sensor).
function pushResetROI_Callback(hObject, eventdata, handles)
global acq_state
if acq_state==0
    handles.octCam.X0=0;
    handles.octCam.Y0=0;
    handles.octCam.Nx=1440;
    handles.octCam.Ny=1440;
    set(handles.editROI_X0,'String',num2str(handles.octCam.X0))
    set(handles.editROI_Y0,'String',num2str(handles.octCam.Y0))
    set(handles.editROI_Width,'String',num2str(handles.octCam.Nx))
    set(handles.editROI_Height,'String',num2str(handles.octCam.Ny))
    set(handles.octCam.vid,'ROIPosition',[handles.octCam.X0 handles.octCam.Y0 handles.octCam.Nx handles.octCam.Ny]);
else
    msgbox('Stop live before reseting ROI')
end
guidata(hObject,handles)

function editROI_X0_Callback(hObject, eventdata, handles)
global acq_state
handles.octCam.X0=str2double(get(hObject,'string'));
if acq_state==0
%     set(handles.octCam.vid,'ROIPosition',[handles.octCam.X0 handles.octCam.Y0 handles.octCam.Nx handles.octCam.Ny]);
    set(handles.octCam.vid,'ROIPosition',[handles.octCam.X0 1440-handles.octCam.Ny handles.octCam.Nx handles.octCam.Ny]);
end
guidata(hObject,handles)

function editROI_X0_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editROI_Y0_Callback(hObject, eventdata, handles)
global acq_state
handles.octCam.Y0=str2double(get(hObject,'string'));
if acq_state==0
%     set(handles.octCam.vid,'ROIPosition',[handles.octCam.X0 handles.octCam.Y0 handles.octCam.Nx handles.octCam.Ny]);
    set(handles.octCam.vid,'ROIPosition',[handles.octCam.X0 1440-handles.octCam.Ny handles.octCam.Nx handles.octCam.Ny]);
end
guidata(hObject,handles)

function editROI_Y0_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editROI_Width_Callback(hObject, eventdata, handles)
global acq_state
handles.octCam.Nx=str2double(get(hObject,'string'));
if acq_state==0
%     set(handles.octCam.vid,'ROIPosition',[handles.octCam.X0 handles.octCam.Y0 handles.octCam.Nx handles.octCam.Ny]);
    set(handles.octCam.vid,'ROIPosition',[handles.octCam.X0 1440-handles.octCam.Ny handles.octCam.Nx handles.octCam.Ny]);
end
guidata(hObject,handles)

function editROI_Width_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editROI_Height_Callback(hObject, eventdata, handles)
global acq_state
handles.octCam.Ny=str2double(get(hObject,'string'));
if acq_state==0
%     set(handles.octCam.vid,'ROIPosition',[handles.octCam.X0 handles.octCam.Y0 handles.octCam.Nx handles.octCam.Ny]);
    set(handles.octCam.vid,'ROIPosition',[handles.octCam.X0 1440-handles.octCam.Ny handles.octCam.Nx handles.octCam.Ny]);
end
guidata(hObject,handles)

function editROI_Height_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Fluo camera settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback functions for fluo camera (PCO) parameters. The camera is
% interfaced throught the image acquisition toolbox with a toolbox provided
% by PCO (check the latest version on their website). The camera is trigged
% numerically as we don't need to be perfectly synchronized with anything.
% Nonetheless if the parameters are set properly, one can perform parallel
% acquisition on the OCT and Fluo paths.

% Change the frame rate
function editFluoFrameRate_Callback(hObject, eventdata, handles)
handles.fluoCam.Fcam=str2double(get(hObject,'string'));
% If the exposure time is too high for the new frame rate, we reduce it at
% its maximum admissible value.
if handles.fluoCam.ExpTime>(1000/(1.001*handles.fluoCam.Fcam)-0.04)
    handles.fluoCam.ExpTime =(1000/(1.001*handles.fluoCam.Fcam)-0.04);
    set(handles.fluoCam.src,'E2ExposureTime',1000*handles.fluoCam.ExpTime)
end
set(handles.fluoCam.src,'FRFrameRate_mHz',1000*handles.fluoCam.Fcam)
handles.fluoCam.ExpTime=get(handles.fluoCam.src,'E2ExposureTime')/1000;
handles.fluoCam.Fcam=double(get(handles.fluoCam.src,'FRFrameRate_mHz')/1000);
set(hObject,'String',num2str(handles.fluoCam.Fcam))
set(handles.editFluoExposureTime,'String',num2str(handles.fluoCam.ExpTime))
guidata(hObject,handles)

function editFluoFrameRate_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% Change the exposure time.
function editFluoExposureTime_Callback(hObject, eventdata, handles)
handles.fluoCam.ExpTime=str2double(get(hObject,'string'));
% If the exposure time is too high for the frame rate, we reduce the frame rate at
% its maximum admissible value.
if handles.fluoCam.ExpTime>(1000/(1.001*handles.fluoCam.Fcam)-0.04)
    handles.fluoCam.Fcam=1000/(1.001*(handles.fluoCam.ExpTime+0.04));
    set(handles.fluoCam.src,'FRFrameRate_mHz',1000*handles.fluoCam.Fcam)
end
set(handles.fluoCam.src,'E2ExposureTime',1000*handles.fluoCam.ExpTime)
handles.fluoCam.ExpTime=get(handles.fluoCam.src,'E2ExposureTime')/1000;
handles.fluoCam.Fcam=double(get(handles.fluoCam.src,'FRFrameRate_mHz')/1000);
set(hObject,'String',num2str(handles.fluoCam.ExpTime))
set(handles.editFluoFrameRate,'String',num2str(handles.fluoCam.Fcam))
guidata(hObject,handles)

function editFluoExposureTime_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% Change the number of accumulations (averaged images).
function editFluoNaccu_Callback(hObject, eventdata, handles)
handles.fluoCam.Naccu=str2double(get(hObject,'string'));
guidata(hObject,handles)

function editFluoNaccu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Piezo modulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback functions to set the piezo modulation (in the reference arm)
% parameters.

% Change the voltage (resulting in a greater optical path change).
function editPiezoVoltage_Callback(hObject, eventdata, handles)
handles.exp.AmplPiezo=str2double(get(handles.editPiezoVoltage,'String'));
guidata(hObject,handles)

function editPiezoVoltage_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% Edit piezo phase (introduce an offset in the modulation).
function editPiezoPhase_Callback(hObject, eventdata, handles)
handles.exp.PhiPiezo=str2double(get('hOjbect','string'))*pi/180;
guidata(hObject,handles)

function editPiezoPhase_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% Find the best amplitude for the piezo based on a typical metric function.
function pushFindAmplitude_Callback(hObject, eventdata, handles)
handles=findBestAmplitude(handles);
guidata(hObject,handles)

% Choose the modulation.
function menuPiezoModulation_Callback(hObject, eventdata, handles)
handles.exp.piezoMode=get(hObject,'Value');
set(handles.axesDirectOCT,'visible','off')
set(handles.axesAmplitude,'visible','off')
set(handles.axesPhase,'visible','off')
switch handles.exp.piezoMode
    case 1
        % Clean data print
        colormap(handles.axesDirectOCT,'gray')
        set(get(handles.axesAmplitude,'children'),'visible','off')
        set(get(handles.axesPhase,'children'),'visible','off')
        handles.exp.AmplPiezo=0;
        set(handles.editPiezoVoltage,'String',num2str(0));
        handles.octCam.FcamOCT=20;
        handles.octCam.FrameTime=1000/handles.octCam.FcamOCT; % ms
        if handles.octCam.FrameTime<(handles.octCam.ExpTime+0.2) % Condition to be satisfied for correct imaging.
            handles.octCam.ExpTime=handles.octCam.FrameTime-0.2;
        end
        % Update GUI with new values.
        set(handles.editFrameRate, 'String', num2str(handles.octCam.FcamOCT));
        set(handles.editExposureTime, 'String', num2str(handles.octCam.ExpTime));
    case 2
        % Clean data print
        set(get(handles.axesPhase,'children'),'visible','off')
        colormap(handles.axesDirectOCT,'gray')
        colormap(handles.axesAmplitude,'gray')
        handles.exp.AmplPiezo=4.13;
        set(handles.editPiezoVoltage,'String',num2str(4.13));
        handles.octCam.FcamOCT=80;
        handles.octCam.FrameTime=1000/handles.octCam.FcamOCT; % ms
        if handles.octCam.FrameTime<(handles.octCam.ExpTime+0.2) % Condition to be satisfied for correct imaging.
            handles.octCam.ExpTime=handles.octCam.FrameTime-0.2;
        end
        % Update GUI with new values.
        set(handles.editFrameRate, 'String', num2str(handles.octCam.FcamOCT));
        set(handles.editExposureTime, 'String', num2str(handles.octCam.ExpTime));
    case 3
        colormap(handles.axesDirectOCT,'gray')
        colormap(handles.axesAmplitude,'gray')
        colormap(handles.axesPhase,'gray')
        handles.exp.AmplPiezo=6.2;
        set(handles.editPiezoVoltage,'String',num2str(6.2));
        handles.octCam.FcamOCT=80;
        handles.octCam.FrameTime=1000/handles.octCam.FcamOCT; % ms
        if handles.octCam.FrameTime<(handles.octCam.ExpTime+0.2) % Condition to be satisfied for correct imaging.
            handles.octCam.ExpTime=handles.octCam.FrameTime-0.2;
        end
        % Update GUI with new values.
        set(handles.editFrameRate, 'String', num2str(handles.octCam.FcamOCT));
        set(handles.editExposureTime, 'String', num2str(handles.octCam.ExpTime));
    case 4
    case 5
        % Clean data print
        set(get(handles.axesPhase,'children'),'visible','off')
        colormap(handles.axesAmplitude,'jet')
        handles.exp.AmplPiezo=0;
        set(handles.editPiezoVoltage,'String',num2str(0));
    case 6
        colormap(handles.axesDirectOCT,'gray')
        set(get(handles.axesAmplitude,'children'),'visible','on')
        set(get(handles.axesPhase,'children'),'visible','off')
        handles.exp.AmplPiezo=4.13;
        set(handles.editPiezoVoltage,'String',num2str(4.13));
        handles.octCam.FcamOCT=80;
        handles.octCam.FrameTime=1000/handles.octCam.FcamOCT; % ms
        if handles.octCam.FrameTime<(handles.octCam.ExpTime+0.2) % Condition to be satisfied for correct imaging.
            handles.octCam.ExpTime=handles.octCam.FrameTime-0.2;
        end
        % Update GUI with new values.
        set(handles.editFrameRate, 'String', num2str(handles.octCam.FcamOCT));
        set(handles.editExposureTime, 'String', num2str(handles.octCam.ExpTime));
    case 7
        
end
      
guidata(hObject, handles);

function menuPiezoModulation_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Acquisitions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback functions related to acquisition panel. Cameras parameters for the acquisition are
% given by the same panels as live imaging.

% Type of images to save:
function checkboxDirect_Callback(hObject, eventdata, handles)
handles.save.direct=get(hObject,'value');
guidata(hObject,handles)

function checkboxAmplitude_Callback(hObject, eventdata, handles)
handles.save.amplitude=get(hObject,'value');
guidata(hObject,handles)

function checkboxPhase_Callback(hObject, eventdata, handles)
handles.save.phase=get(hObject,'value');
guidata(hObject,handles)

function checkboxAllRaw_Callback(hObject, eventdata, handles)
handles.save.allraw=get(hObject,'value');
guidata(hObject,handles)

function checkboxFluo_Callback(hObject, eventdata, handles)
handles.save.fluo=get(hObject,'value');
guidata(hObject,handles)

% Number of images to save
function editNbImOCT_Callback(hObject, eventdata, handles)
handles.save.Noct=str2double(get(hObject,'string'));
if handles.save.Noct>100
    set(handles.menuSaveFormat,'value',2)
    handles.save.format=2;
end
guidata(hObject,handles)

function editNbImOCT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editNbImFluo_Callback(hObject, eventdata, handles)
handles.save.Nfluo=str2double(get(hObject,'string'));
guidata(hObject,handles)

function editNbImFluo_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% Where to save
function pushChangePath_Callback(hObject, eventdata, handles)
handles.save.path=uigetdir('C:\Users\User1\Desktop\Mesures');
set(handles.editSavePath,'string',handles.save.path)
guidata(hObject,handles)

function editSavePath_Callback(hObject, eventdata, handles)
handles.save.path=get(hObject,'string');
guidata(hObject,handles)

function editSavePath_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function menuSaveFormat_Callback(hObject, eventdata, handles)
handles.save.format=get(hObject,'Value');
guidata(hObject,handles)

function menuSaveFormat_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% Start acquisition and perform it depending on the asked mode.
function pushSartAcquisition_Callback(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[1 0 0])
handles=acquisition(handles);
set(hObject,'BackgroundColor',[0.94 0.94 0.94])
guidata(hObject,handles)

% Z-Stack option
function checkZStackEnabled_Callback(hObject, eventdata, handles)
handles.save.zStack=get(hObject,'value');
guidata(hObject,handles);

function editZStackStart_Callback(hObject, eventdata, handles)
handles.save.zStackStart=str2double(get(hObject,'string'));
guidata(hObject,handles);

function editZStackStart_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editZStackEnd_Callback(hObject, eventdata, handles)
handles.save.zStackEnd=str2double(get(hObject,'string'));
guidata(hObject,handles);

function editZStackEnd_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editZStackStep_Callback(hObject, eventdata, handles)
handles.save.zStackStep=str2double(get(hObject,'string'));
guidata(hObject,handles);

function editZStackStep_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function checkZStackReturn_Callback(hObject, eventdata, handles)
handles.save.zStackReturn=get(hObject,'value');
guidata(hObject,handles);

% Repeat acquisition option
function checkAcqRepeatEnabled_Callback(hObject, eventdata, handles)
handles.save.repeat=get(hObject,'value');
guidata(hObject,handles);

function checkboxDriftCorrection_Callback(hObject, eventdata, handles)
handles.save.correctDrift=get(hObject,'value');
guidata(hObject,handles);

function editNRepeat_Callback(hObject, eventdata, handles)
handles.save.repeatN=str2double(get(hObject,'string'));
guidata(hObject,handles);

function editNRepeat_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editTimeRepeat_Callback(hObject, eventdata, handles)
handles.save.repeatTime=str2double(get(hObject,'string'));
guidata(hObject,handles);

function editTimeRepeat_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function checkSaveInSameFile_Callback(hObject, eventdata, handles)
handles.save.samefile=get(hObject,'value');
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Reference Arm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback functions related to the referrence arm panel.

% Stop motor movement
function pushRefMotorStop_Callback(hObject, eventdata, handles)
set(handles.pushRefMotorStart,'BackgroundColor',[0.47 0.67 0.19]);
set(handles.pushRefMotorStop,'BackgroundColor',[0.94 0.94 0.94]);
handles.motors.ref.stop();

% Start motor movement
function pushRefMotorStart_Callback(hObject, eventdata, handles)
x=str2double(get(handles.editRefMotorGo,'String'));
handles.motors.RefMode=get(handles.menuRefMotor,'Value');
switch handles.motors.RefMode
    case 1 % Given movement
        switch handles.gui.mode
            case 1
                move=round(handles.motors.ref.Units.positiontonative(x*1e-6)*5); % Translates the value in microns to the number of microsteps. We multiply by 5 for the Thorlabs translation stage.
                handles.motors.ref.moverelative(move);
            case 2
                disp('Not implemented yet')
            case 3
                move=round(handles.motors.ref.Units.positiontonative(x*1e-6)); % Translates the value in microns to the number of microsteps.
                handles.motors.ref.moverelative(move);
        end
    case 2 % Given speed
        set(handles.pushRefMotorStart,'BackgroundColor',[0.94 0.94 0.94]);
        set(handles.pushRefMotorStop,'BackgroundColor',[1 0 0]);
        switch handles.gui.mode
            case 1
                speed=round(handles.motors.ref.Units.velocitytonative(x*1e-6)*5); % Translates the value in um/s to the number of microsteps/s.
                handles.motors.ref.moveatvelocity(speed);
            case 2
                disp('Not implemented yet')
            case 3
                speed=round(handles.motors.ref.Units.velocitytonative(x*1e-6)); % Translates the value in um/s to the number of microsteps/s.
                handles.motors.ref.moveatvelocity(speed);
        end
    case 3 % Given absolute position
        handles.motors.ref.moveabsolute(x);
end
guidata(hObject,handles)

function editRefMotorGo_Callback(hObject, eventdata, handles)
% The value is read in pushRefMotorStart_Callback, nothing to do here about
% that.

function editRefMotorGo_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pushRefMotorPosition_Callback(hObject, eventdata, handles)
handles.motors.refPosition=handles.motors.ref.getposition();
set(handles.textRefMotorPosition,'String',num2str(handles.motors.refPosition));
guidata(hObject,handles)
    
function menuRefMotor_Callback(hObject, eventdata, handles)
% The value is read in pushRefMotorStart_Callback, nothing to do here about
% that.

function menuRefMotor_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pushClearMotors_Callback(hObject, eventdata, handles)
if ~isempty(handles.motors.port)
    if strcmp(handles.motors.port.Status,'open')
        fclose(handles.motors.port);
    end
end
guidata(hObject,handles)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Sample Arm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback functions related to the sample arm panel.

function menuSampleMotor_Callback(hObject, eventdata, handles)
% The value is read in pushSampleMotorStart_Callback, nothing to do here about
% that.

function menuSampleMotor_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pushSampleMotorPosition_Callback(hObject, eventdata, handles)
handles.motors.samplePosition=handles.motors.sample.getposition();
set(handles.textSampleMotorPosition,'String',num2str(handles.motors.samplePosition));
guidata(hObject,handles)

function editSampleMotorGo_Callback(hObject, eventdata, handles)
% The value is read in pushSampleMotorStart_Callback, nothing to do here about
% that.

function editSampleMotorGo_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pushSampleMotorStart_Callback(hObject, eventdata, handles)
x=str2double(get(handles.editSampleMotorGo,'String'));
handles.motors.SampleMode=get(handles.menuSampleMotor,'Value');
switch handles.motors.SampleMode
    case 1 % Given movement
        move=round(handles.motors.sample.Units.positiontonative(x*1e-6)*5); % Translates the value in microns to the number of microsteps.
        handles.motors.sample.moverelative(move);
    case 2 % Given speed
        set(handles.pushSampleMotorStart,'BackgroundColor',[0.94 0.94 0.94]);
        set(handles.pushSampleMotorStop,'BackgroundColor',[1 0 0]);
        speed=round(handles.motors.sample.Units.velocitytonative(x*1e-6)*5); % Translates the value in um/s to the number of microsteps/s.
        handles.motors.sample.moveatvelocity(speed);
    case 3 % Given absolute position
        handles.motors.sample.moveabsolute(x);
end
guidata(hObject,handles)

function pushSampleMotorStop_Callback(hObject, eventdata, handles)
set(handles.pushSampleMotorStart,'BackgroundColor',[0.47 0.67 0.19]);
set(handles.pushSampleMotorStop,'BackgroundColor',[0.94 0.94 0.94]);
handles.motors.sample.stop();

function pushResetMotors_Callback(hObject, eventdata, handles)
if ~isempty(handles.motors.port)
    if strcmp(handles.motors.port.Status,'open')
        fclose(handles.motors.port);
    end
end
handles=initialisationMotors(handles);
guidata(hObject,handles)

function menuIlluminationMode_Callback(hObject, eventdata, handles)
handles.exp.illuminationMode=get(hObject,'value');
guidata(hObject,handles)

function menuIlluminationMode_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function checkRemoteIllumination_Callback(hObject, eventdata, handles)
handles.exp.illuminationEnabled=get(hObject,'value');
guidata(hObject,handles)

function editLedOCTPower_Callback(hObject, eventdata, handles)
handles.exp.LedOCTPower=str2double(get(hObject,'String'));
guidata(hObject,handles)

function editLedOCTPower_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editLedFluoPower_Callback(hObject, eventdata, handles)
handles.exp.LedFluoPower=str2double(get(hObject,'String'));
guidata(hObject,handles)

function editLedFluoPower_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  DFFOCT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback functions related to the DFFOCT controls.

function pushbuttonDFFOCT_Callback(hObject, eventdata, handles)
handles = dffoct_snapshot(handles);
guidata(hObject,handles)

function editVmax_Callback(hObject, eventdata, handles)
handles.exp.dffoct.Vmax=str2double(get(hObject,'String'));
handles = reset_colors(handles);
guidata(hObject,handles)

function editVmax_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editHmin_Callback(hObject, eventdata, handles)
handles.exp.dffoct.Hmin=str2double(get(hObject,'String'));
handles = reset_colors(handles);
guidata(hObject,handles)

function editHmin_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editHmax_Callback(hObject, eventdata, handles)
handles.exp.dffoct.Hmax=str2double(get(hObject,'String'));
handles = reset_colors(handles);
guidata(hObject,handles)

function editHmax_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editSmin_Callback(hObject, eventdata, handles)
handles.exp.dffoct.Smin=str2double(get(hObject,'String'));
handles = reset_colors(handles);
guidata(hObject,handles)

function editSmin_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editSmax_Callback(hObject, eventdata, handles)
handles.exp.dffoct.Smax=str2double(get(hObject,'String'));
handles = reset_colors(handles);
guidata(hObject,handles)

function editSmax_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end