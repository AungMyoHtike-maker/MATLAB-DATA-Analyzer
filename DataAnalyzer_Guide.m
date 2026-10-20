function varargout = DataAnalyzer_Guide(varargin)
% DATAANALYZER_GUIDE MATLAB code for DataAnalyzer_Guide.fig
%      DATAANALYZER_GUIDE, by itself, creates a new DATAANALYZER_GUIDE or raises the existing
%      singleton*.
%
%      H = DATAANALYZER_GUIDE returns the handle to a new DATAANALYZER_GUIDE or the handle to
%      the existing singleton*.
%
%      DATAANALYZER_GUIDE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DATAANALYZER_GUIDE.M with the given input arguments.
%
%      DATAANALYZER_GUIDE('Property','Value',...) creates a new DATAANALYZER_GUIDE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DataAnalyzer_Guide_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DataAnalyzer_Guide_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DataAnalyzer_Guide

% Last Modified by GUIDE v2.5 19-Oct-2026 13:36:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DataAnalyzer_Guide_OpeningFcn, ...
                   'gui_OutputFcn',  @DataAnalyzer_Guide_OutputFcn, ...
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


% --- Executes just before DataAnalyzer_Guide is made visible.
function DataAnalyzer_Guide_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DataAnalyzer_Guide (see VARARGIN)

% Choose default command line output for DataAnalyzer_Guide
handles.output = hObject;
%%%%%%%%%%%%%%
set(handles.uitableData, 'ColumnEditable', false);
set(handles.uitableData, 'RowName', []);
%%%%%%%%%%%%%%
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DataAnalyzer_Guide wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DataAnalyzer_Guide_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbuttonLoad.
function pushbuttonLoad_Callback(hObject, eventdata, handles)
% Select a CSV file
[file, path] = uigetfile('*.csv', 'Select a CSV Data File');

if isequal(file, 0)
    return;
end

% Read CSV data
try
    T = readtable(fullfile(path, file));
catch ME
    errordlg( ...
        ['Unable to read CSV file: ' ME.message],'File Read Error');
    return;
end
%%%%%%%%%%
% Display original CSV data in Data Preview Table
set(handles.uitableData, ...
    'Data', table2cell(T), ...
    'ColumnName', T.Properties.VariableNames, ...
    'RowName', []);

% Find numeric columns
numericCols = varfun(@isnumeric, T, ...
    'OutputFormat', 'uniform');

data = T{:, numericCols};
names = T.Properties.VariableNames(numericCols);

% Check numeric data
if isempty(data)
    errordlg('No numeric columns found in CSV file.','Data Error');
    return;
end

% Populate variable selection dropdown
set(handles.popupmenuVariable, 'String', names, 'Value', 1);

% Store imported data
handles.data = data;
handles.names = names;
guidata(hObject, handles);

% Plot data in GUIDE axes
cla(handles.axes1);

plot(handles.axes1, data, 'LineWidth', 1.5);
grid(handles.axes1, 'on');

title(handles.axes1, 'Data Trend Analysis');
xlabel(handles.axes1, 'Observation Number');
ylabel(handles.axes1, 'Measured Value');

legend(handles.axes1, names, ...
    'Interpreter', 'none', 'Location', 'best');

% Calculate summary statistics
countValue = sum(~isnan(data), 1);
missingValue = sum(isnan(data), 1);

avgValue = mean(data, 1, 'omitnan');
minValue = min(data, [], 1, 'omitnan');
maxValue = max(data, [], 1, 'omitnan');
stdValue = std(data, 0, 1, 'omitnan');

% Create summary table
Summary = table(names(:), countValue(:), ...
    missingValue(:), avgValue(:), minValue(:), ...
    maxValue(:), stdValue(:), ...
    'VariableNames', {'Variable', 'Count', ...
    'Missing', 'Mean', 'Minimum', 'Maximum', 'StdDev'});

% Display summary in GUIDE table
set(handles.uitableSummary, ...
    'Data', table2cell(Summary), ...
    'ColumnName', Summary.Properties.VariableNames,'RowName', []);

% Store the imported data for other buttons
handles.data = data;
handles.names = names;
guidata(hObject, handles);

% for msgbox
set(handles.textStatus, 'String','Data Loaded Successfully!');
set(handles.textStatus, 'ForegroundColor',[0.10 0.50 0.25]);
% hObject    handle to pushbuttonLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbuttonClear.
function pushbuttonClear_Callback(hObject, eventdata, handles)
% Clear the graph
cla(handles.axes1);

% Clear graph labels and legend
title(handles.axes1, '');
xlabel(handles.axes1, '');
ylabel(handles.axes1, '');
legend(handles.axes1, 'off');
% Reset variable dropdown
set(handles.popupmenuVariable,'String', {'No data loaded'},'Value', 1);

% Clear the Summary Table
set(handles.uitableData, 'Data', []);
set(handles.uitableSummary, 'Data',[]);
% set(handles.uitableSummary, ...
%     'Data', cell(0, 7), ...
%     'ColumnName', {'Variable', 'Count', ...
%     'Missing', 'Mean', 'Minimum', 'Maximum', 'StdDev'}, ...
%     'RowName', []);

% Clear stored data
if isfield(handles, 'data')
    handles = rmfield(handles, 'data');
end

if isfield(handles, 'names')
    handles = rmfield(handles, 'names');
end

% Reset status message
set(handles.textStatus, 'String','Ready — Select a CSV file');

set(handles.textStatus, 'ForegroundColor',[0.25 0.35 0.45]);

% Reset variable dropdown
set(handles.popupmenuVariable,'String', {'No data loaded'},'Value', 1);
% Save updated handles
guidata(hObject, handles);


  
% hObject    handle to pushbuttonClear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbuttonClose.
function pushbuttonClose_Callback(hObject, eventdata, handles)
close gcf;
% hObject    handle to pushbuttonClose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbuttonHistogram.
function pushbuttonHistogram_Callback(hObject, eventdata, handles)
% Check whether data has been loaded
if ~isfield(handles, 'data') || isempty(handles.data)
    errordlg('Please select a CSV file first.', 'No Data');
    return;
end

data = handles.data;
names = handles.names;

% Select the first numeric column
columnIndex = 1;
values = data(:, columnIndex);
values = values(~isnan(values));

if isempty(values)
    errordlg('No valid numeric values to plot.','Data Error');
    return;
end

% Draw histogram
cla(handles.axes1);

histogram(handles.axes1, values);
grid(handles.axes1, 'on');

title(handles.axes1, ...
    ['Histogram: ' names{columnIndex}], ...
    'Interpreter', 'none');

xlabel(handles.axes1, names{columnIndex},'Interpreter', 'none');
ylabel(handles.axes1, 'Frequency');
% hObject    handle to pushbuttonHistogram (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbuttonExport.
function pushbuttonExport_Callback(hObject, eventdata, handles)

% Check whether data has been loaded
if ~isfield(handles, 'data') || isempty(handles.data)
    errordlg('Please select a CSV file first.','No Data');
    return;
end

% Choose output folder
folder = uigetdir(pwd, 'Select Report Folder');

if isequal(folder, 0)
    return;
end

% Prepare summary statistics
data = handles.data;
names = handles.names;

Summary = table( ...
    names(:), ...
    sum(~isnan(data), 1)', ...
    sum(isnan(data), 1)', ...
    mean(data, 1, 'omitnan')', ...
    min(data, [], 1, 'omitnan')', ...
    max(data, [], 1, 'omitnan')', ...
    std(data, 0, 1, 'omitnan')', ...
    'VariableNames', {'Variable', 'Count', ...
    'Missing', 'Mean', 'Minimum', 'Maximum', 'StdDev'});

% Export summary CSV
writetable(Summary, ...
    fullfile(folder, 'summary_report.csv'));

% Export the current graph
exportgraphics(handles.axes1,fullfile(folder, 'data_plot.png'),'Resolution', 200);

set(handles.textStatus, 'String','Report Exported Successfully!');
set(handles.textStatus, 'ForegroundColor',[0.10 0.50 0.25]);

msgbox('Summary and graph exported successfully!','Export Complete');
% hObject    handle to pushbuttonExport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in popupmenuVariable.
function popupmenuVariable_Callback(hObject, eventdata, handles)
% Check whether data has been loaded
if ~isfield(handles, 'data') || isempty(handles.data)
    return;
end

% Get selected variable
selectedIndex = get(hObject, 'Value');
names = handles.names;
data = handles.data;

if selectedIndex > size(data, 2)
    return;
end

% Get selected column
values = data(:, selectedIndex);
values = values(~isnan(values));

if isempty(values)
    errordlg('No valid numeric values in this variable.','Data Error');
    return;
end

% Display selected variable histogram
cla(handles.axes1);

histogram(handles.axes1, values);
grid(handles.axes1, 'on');

title(handles.axes1, ...
    ['Histogram: ' names{selectedIndex}],'Interpreter', 'none');

xlabel(handles.axes1, names{selectedIndex},'Interpreter', 'none');
ylabel(handles.axes1, 'Frequency');

% Update status
set(handles.textStatus, 'String',['Selected Variable: ' names{selectedIndex}]);
% hObject    handle to popupmenuVariable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuVariable contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuVariable


% --- Executes during object creation, after setting all properties.
function popupmenuVariable_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuVariable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
