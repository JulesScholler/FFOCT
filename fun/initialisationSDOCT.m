function handles = initialisationSDOCT(handles)

% Parameters
handles.SDOCT.scanWidth = 1.0; % mm
handles.SDOCT.nScans = 256;
handles.SDOCT.apodization = 0; % bool

% make sure the path to the directory is known from Matlab!
addpath(genpath('C:\Program Files\Thorlabs\SpectralRadar'))
loadlibrary('SpectralRadar', 'SpectralRadar.h')

% initialization of device and data
% here we create pointers to discuss with the device
handles.SDOCT.Dev = calllib('SpectralRadar','initDevice');
handles.SDOCT.Probe = calllib('SpectralRadar','initProbe', handles.SDOCT.Dev, 'Probe');
handles.SDOCT.RawData = calllib('SpectralRadar','createRawData');
handles.SDOCT.Data = calllib('SpectralRadar','createData');
handles.SDOCT.Proc = calllib('SpectralRadar','createProcessingForDevice', handles.SDOCT.Dev);

% Set trigger mode to external - 0: standard - 1: ExternalStart - 2:
% External AScans
handles.SDOCT.triggerMode = calllib('SpectralRadar','getTriggerMode',handles.SDOCT.Dev);
if strcmp(handles.SDOCT.triggerMode, 'Trigger_External_AScan') == 0
    if calllib('SpectralRadar','isTriggerModeAvailable',handles.SDOCT.Dev, 2) == 1
        calllib('SpectralRadar','setTriggerMode', handles.SDOCT.Dev, 2)
    else
        fprintf('Error : External trigger mode is not available')
    end
end

% creating a scan pattern
% Peng SDOCT max AScan rate = 36kHz
handles.SDOCT.ScanPattern = calllib('SpectralRadar','createBScanPattern', handles.SDOCT.Probe, handles.SDOCT.scanWidth, handles.SDOCT.nScans, handles.SDOCT.apodization);
handles.SDOCT.trigPerBScan = calllib('SpectralRadar','getScanPatternPropertyInt', handles.SDOCT.ScanPattern,0);