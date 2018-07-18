function handles=initialisationGUI(handles)
% This functions initiate the GUI configuration.

handles.gui.oct=0;
handles.gui.fluo=0;
handles.gui.sdoct=0;
handles.exp.imResize=0.3;
handles.save.allraw=0;
handles.save.direct=0;
handles.save.amplitude=0;
handles.save.phase=0;
handles.save.path=get(handles.editSavePath,'string');
handles.save.zStack=0;
handles.save.zStackStart=0;
handles.save.zStackEnd=0;
handles.save.zStackStep=0;
handles.save.repeat=0;
handles.save.correctDrift=0;
handles.save.repeatN=0;
handles.save.repeatTime=0;
handles.save.zStackReturn=0;
handles.save.samefile=0;
handles.save.Noct=0;
handles.save.Nfluo=0;
handles.save.format=1;
colormap(handles.axesDirectOCT,'gray')
colormap(handles.axesAmplitude,'gray')
colormap(handles.axesPhase,'gray')
handles.exp.LedOCTPower=500;
handles.exp.LedFluoPower=500;
handles.exp.illuminationMode=1;
handles.exp.illuminationOCT=0;
handles.exp.illuminationFluo=0;
handles.exp.dffoct.n_std=50;