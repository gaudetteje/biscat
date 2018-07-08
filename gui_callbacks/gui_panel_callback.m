function h = gui_panel_callback

h.main = @tabPanelCallback;
h.neur = @neurPanelCallback;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Panel button callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tabPanelCallback(hObject,eventdata)
% swap visibility of tab panels based on calling object

GUI = guidata(hObject);

switch hObject
    case GUI.handles.tab1.butt_tab
        set(GUI.handles.tab1.panel,'Visible','on')
        set(GUI.handles.tab2.panel,'Visible','off')
        set(GUI.handles.tab3.panel,'Visible','off')
        set(GUI.handles.tab4.panel,'Visible','off')
    case GUI.handles.tab2.butt_tab
        set(GUI.handles.tab1.panel,'Visible','off')
        set(GUI.handles.tab2.panel,'Visible','on')
        set(GUI.handles.tab3.panel,'Visible','off')
        set(GUI.handles.tab4.panel,'Visible','off')
    case GUI.handles.tab3.butt_tab
        set(GUI.handles.tab1.panel,'Visible','off')
        set(GUI.handles.tab2.panel,'Visible','off')
        set(GUI.handles.tab3.panel,'Visible','on')
        set(GUI.handles.tab4.panel,'Visible','off')        
    case GUI.handles.tab4.butt_tab
        set(GUI.handles.tab1.panel,'Visible','off')
        set(GUI.handles.tab2.panel,'Visible','off')
        set(GUI.handles.tab3.panel,'Visible','off')
        set(GUI.handles.tab4.panel,'Visible','on')
    otherwise
        warning('Unknown GUI handle')
end


function neurPanelCallback(hObject,eventdata)
% swap visibility of neural transduction panels based on eventdata

GUI = guidata(hObject);

switch eventdata.NewValue
    case GUI.handles.tab2.neur.neur_rcf
        set(GUI.handles.tab2.neur.rcf.panel,'Visible','on')
        set(GUI.handles.tab2.neur.bio.panel,'Visible','off')
        set(GUI.handles.tab2.neur.rnd.panel,'Visible','off')
    case GUI.handles.tab2.neur.neur_bio
        set(GUI.handles.tab2.neur.rcf.panel,'Visible','off')
        set(GUI.handles.tab2.neur.bio.panel,'Visible','on')
        set(GUI.handles.tab2.neur.rnd.panel,'Visible','off')
    case GUI.handles.tab2.neur.neur_rnd
        set(GUI.handles.tab2.neur.rcf.panel,'Visible','off')
        set(GUI.handles.tab2.neur.bio.panel,'Visible','off')
        set(GUI.handles.tab2.neur.rnd.panel,'Visible','on')
    otherwise
        warning(sprintf('Invalid event data received in neurPanelCallback: "%s"',panel))
end

