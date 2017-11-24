function handles=initialisationGUI(handles)

handles.gui.oct=0;
handles.gui.fluo=0;
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
handles.save.repeatN=0;
handles.save.repeatTime=0;
handles.save.zStackReturn=0;
handles.save.N=0;
colormap(handles.axesDirectOCT,'gray')
colormap(handles.axesAmplitude,'gray')
colormap(handles.axesPhase,'gray')