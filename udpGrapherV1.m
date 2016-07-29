function varargout = udpGrapherV1(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @udpGrapherV1_OpeningFcn, ...
                   'gui_OutputFcn',  @udpGrapherV1_OutputFcn, ...
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
end

% --- Outputs from this function are returned to the command line.
function varargout = udpGrapherV1_OutputFcn(hObject, eventdata, handles)  %#ok<*INUSL>
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end


% --- Executes just before udpGrapherV1 is made visible.
function udpGrapherV1_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to udpGrapherV1 (see VARARGIN)
    global xlimit;
    global numDataSetsInPacket;
    global xcounter;
    global countToClearBuffer;
    global secondsBetweenFlushes;
    global startBeenPressed;
    global everStarted;
    global stopBeenPressed;
    global checkBox1Visible;
    global checkBox2Visible;
    global checkBox3Visible;
    global checkBox4Visible;
    global checkBox5Visible;
    global checkBox6Visible;
    global exportSensor1Array;
    global exportSensor2Array;
    global exportSensor3Array;
    global exportSensor4Array;
    global exportSensor5Array;
    global exportSensor6Array;
    
  
    xlimit = 5000;
    numDataSetsInPacket = 45; %Change this value if needed = # sets of data in a packet
    xcounter = 0;
    countToClearBuffer = 0;    
    secondsBetweenFlushes = 20;
    startBeenPressed = false;
    everStarted = false;
    stopBeenPressed = false;
    checkBox1Visible = 'on';
    checkBox2Visible = 'on';
    checkBox3Visible = 'on';
    checkBox4Visible = 'on';
    checkBox5Visible = 'on';
    checkBox6Visible = 'on';
    exportSensor1Array = [];
    exportSensor2Array = [];
    exportSensor3Array = [];
    exportSensor4Array = [];
    exportSensor5Array = [];
    exportSensor6Array = [];
    
    % Choose default command line output for udpGrapherV1
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

% UIWAIT makes udpGrapherV1 wait for user response (see UIRESUME)
% uiwait(handles.figure1);
end

% --- Executes on button press in startbutton.
function startbutton_Callback(hObject, eventdata, handles)
%This is the start button so we want to do alot here....
    global t1;
    global xlimit;
    global numDataSetsInPacket;
    global udpClient;
    global uPlotSensor1;
    global uPlotSensor2;
    global uPlotSensor3;
    global uPlotSensor4;
    global uPlotSensor5;
    global uPlotSensor6;
    global startBeenPressed;
    global everStarted;
    global stopBeenPressed;
    global checkBox1Visible;
    global checkBox2Visible;
    global checkBox3Visible;
    global checkBox4Visible;
    global checkBox5Visible;
    global checkBox6Visible;
    global remoteHostName;
    global remotePort;
    global localPort;
    global validIP;
    global IPEditField;
    
    validIP = true;
    
    if(~startBeenPressed) %I think there needs to be more here
        if(stopBeenPressed)
            %Clear the axes...
            %How to clear the axes
            stopBeenPressed = false;
            clearpoints(uPlotSensor1);
            clearpoints(uPlotSensor2);
            clearpoints(uPlotSensor3);
            clearpoints(uPlotSensor4);
            clearpoints(uPlotSensor5);
            clearpoints(uPlotSensor6);
        end
        
        startBeenPressed = true;
        everStarted = true;
        
      
        udpClient = udp(remoteHostName, remotePort, 'LocalPort', localPort);
        
       %Add more plots here to window if necessary
        uPlotSensor1 = animatedline('Color','g', 'MaximumNumPoints', xlimit, 'Visible', checkBox1Visible);
        uPlotSensor2 = animatedline('Color','r', 'MaximumNumPoints', xlimit, 'Visible', checkBox2Visible);
        uPlotSensor3 = animatedline('Color','b', 'MaximumNumPoints', xlimit, 'Visible', checkBox3Visible);
        uPlotSensor4 = animatedline('Color','y', 'MaximumNumPoints', xlimit, 'Visible', checkBox4Visible);
        uPlotSensor5 = animatedline('Color','m', 'MaximumNumPoints', xlimit, 'Visible', checkBox5Visible);
        uPlotSensor6 = animatedline('Color','w', 'MaximumNumPoints', xlimit, 'Visible', checkBox6Visible);

            %Need to add more to get this to work?
            %Where do I put local read an plot???
            %Setup Udp object
        bytesToRead = (numDataSetsInPacket -1) * 30 + (32); %Reflects length of message recieved may need to be changed
        udpClient.BytesAvailableFcn = {@localReadAndPlot,uPlotSensor1, uPlotSensor2,uPlotSensor3,uPlotSensor4,uPlotSensor5,uPlotSensor6,bytesToRead};
        udpClient.BytesAvailableFcnMode = 'byte';
        udpClient.BytesAvailableFcnCount = bytesToRead;
        udpClient.InputBufferSize = 1000000;

        t1 = clock; %Get the first clock value
        
        try
           fopen(udpClient); 
        catch
           fclose(udpClient);
           delete(udpClient);
           clear udpClient;
           validIP = false;
           disp('In the Catch');
           startBeenPressed = false;
           %Seems to be clearing the graph if makes it here
           disp(stopBeenPressed);
           set(IPEditField, 'BackgroundColor', [1 0.9 0.9]);
        end
        
        if(validIP)
          set(IPEditField, 'BackgroundColor', 'white');
          disp('ValidIP');
          fprintf(udpClient, 'Connection made.');
          pause(3);
        end
        %drawnow;
    end
end

function localReadAndPlot(udpClient,~,uPlotSensor1,uPlotSensor2,uPlotSensor3,uPlotSensor4,uPlotSensor5,uPlotSensor6, bytesToRead)
    global xcounter;
    global xlimit;
    global numDataSetsInPacket;
    global countToClearBuffer;
    global t1;
    global secondsBetweenFlushes;
    global userVerifiedFunction; 
    global exportSensor1Array;
    global exportSensor2Array;
    global exportSensor3Array;
    global exportSensor4Array;
    global exportSensor5Array;
    global exportSensor6Array;
    
    data = fread(udpClient,bytesToRead);
    dataStr = char(data(1:end-2)'); %Convert to an array
   
    if (length(dataStr) == bytesToRead -2) 
        if xcounter >= xlimit
            xcounter = 0;
            clearpoints(uPlotSensor1);
            clearpoints(uPlotSensor2);
            clearpoints(uPlotSensor3);
            clearpoints(uPlotSensor4);
            clearpoints(uPlotSensor5);
            clearpoints(uPlotSensor6);
        end
        
        %Convert to an array of numbers
        dataNum = sscanf(dataStr, '%d,', bytesToRead);
        if(length(dataNum) == (numDataSetsInPacket * 6))
            dataNum2 = reshape(dataNum,[6,numDataSetsInPacket]);
            sensor1Data = userVerifiedFunction(dataNum2(1,:));
            sensor2Data = userVerifiedFunction(dataNum2(2,:));
            sensor3Data = userVerifiedFunction(dataNum2(3,:));
            sensor4Data = userVerifiedFunction(dataNum2(4,:));
            sensor5Data = userVerifiedFunction(dataNum2(5,:));
            sensor6Data = userVerifiedFunction(dataNum2(6,:));
            
            exportSensor1Array = [exportSensor1Array, sensor1Data]; %This will most likely need to be changed
            exportSensor2Array = [exportSensor2Array, sensor2Data];
            exportSensor3Array = [exportSensor3Array, sensor3Data];
            exportSensor4Array = [exportSensor4Array, sensor4Data];
            exportSensor5Array = [exportSensor5Array, sensor5Data];
            exportSensor6Array = [exportSensor6Array, sensor6Data];
            
           
            xData = xcounter+1:(xcounter+numDataSetsInPacket);

            addpoints(uPlotSensor1, xData, sensor1Data);
            addpoints(uPlotSensor2, xData, sensor2Data);
            addpoints(uPlotSensor3, xData, sensor3Data);
            addpoints(uPlotSensor4, xData, sensor4Data);
            addpoints(uPlotSensor5, xData, sensor5Data);
            addpoints(uPlotSensor6, xData, sensor6Data);
            xcounter = xcounter + numDataSetsInPacket;
            drawnow;
        end
    end
    
    t2 = clock;
    if (etime(t2,t1) > secondsBetweenFlushes)
        flushinput(udpClient);
        disp('Flushed and Reset Clock');
        t1 = clock;
    end 
    
    countToClearBuffer = countToClearBuffer + 1;
end

% --- Executes on button press in stopbutton.
function stopbutton_Callback(hObject, eventdata, handles)
    global udpClient;
    global xcounter;
    global startBeenPressed;
    global stopBeenPressed;
    if(startBeenPressed)
        startBeenPressed = false;
        stopBeenPressed = true;
        xcounter = 0;
        flushinput(udpClient);
        fclose(udpClient);
        delete(udpClient);
        clear udpClient;
    end
end


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
    global udpClient;
    global startBeenPressed;
    global everStarted;
    if(startBeenPressed && everStarted) %TODO Add try catch 
        flushinput(udpClient);
        fclose(udpClient);
        delete(udpClient);
        clear udpClient;
        fclose(instrfindall);
    end
end


%%-----------------------CheckBox Code ------------------------------

% --- Executes during object creation, after setting all properties.
function checkbox1_CreateFcn(hObject, eventdata, handles) %#ok<*INUSD>
    set(hObject,'Value',1);
end

% --- Executes during object creation, after setting all properties.
function checkbox2_CreateFcn(hObject, eventdata, handles) %#ok<*DEFNU>
    set(hObject,'Value',1);
end


% --- Executes during object creation, after setting all properties.
function checkbox3_CreateFcn(hObject, eventdata, handles)
    set(hObject,'Value',1);
end


% --- Executes during object creation, after setting all properties.
function checkbox4_CreateFcn(hObject, eventdata, handles)
    set(hObject,'Value',1);
end


% --- Executes during object creation, after setting all properties.
function checkbox5_CreateFcn(hObject, eventdata, handles)
    set(hObject,'Value',1);
end


% --- Executes during object creation, after setting all properties.
function checkbox6_CreateFcn(hObject, eventdata, handles)
    set(hObject,'Value',1);
end

% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
    global uPlotSensor1;
    global startBeenPressed;
    global checkBox1Visible; %making the value of the checkbox global allows us to access in the initial setup
    checkbox1 = get(hObject, 'Value');
    if(checkbox1 == 0)
        checkBox1Visible = 'off';
    else
        checkBox1Visible = 'on';
    end
    
    if(startBeenPressed) %At runtime
        if(checkbox1 == 0)
          %Set plot 1 to be invisible
          set(uPlotSensor1,'Visible','off');
        else
            %we received a one
            set(uPlotSensor1, 'Visible', 'on');
        end
    end
end

% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
    global uPlotSensor2;
    global startBeenPressed;
    global checkBox2Visible; 
    checkBox2 = get(hObject, 'Value');
    
    if(checkBox2 == 0)
        checkBox2Visible = 'off';
    else
        checkBox2Visible = 'on';
    end
    
    if(startBeenPressed)
        if(checkBox2 == 0)
          %Set plot 1 to be invisible
          set(uPlotSensor2,'Visible','off');
        else
            %we received a one
            set(uPlotSensor2, 'Visible', 'on');
        end
    end
end

% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
    global startBeenPressed;
    global uPlotSensor3;
    global checkBox3Visible; 
    checkBox3 = get(hObject, 'Value');
    
    if(checkBox3 == 0)
        checkBox3Visible = 'off';
    else
        checkBox3Visible = 'on';
    end
    
    if(startBeenPressed)
        if(checkBox3 == 0)
          %Set plot 1 to be invisible
          set(uPlotSensor3,'Visible','off');
        else
            %we received a one
            set(uPlotSensor3, 'Visible', 'on');
        end
    end
end

% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
    global uPlotSensor4;
    global startBeenPressed;
    global checkBox4Visible; 
    checkBox4 = get(hObject, 'Value');
    
    if(checkBox4 == 0)
        checkBox4Visible = 'off';
    else
        checkBox4Visible = 'on';
    end
    
    if(startBeenPressed)
        if(checkBox4 == 0)
          %Set plot 1 to be invisible
          set(uPlotSensor4,'Visible','off');
        else
            %we received a one
            set(uPlotSensor4, 'Visible', 'on');
        end
    end
end

% --- Executes on button press in checkbox5.
function checkbox5_Callback(hObject, eventdata, handles)
    global uPlotSensor5;
    global startBeenPressed;
    global checkBox5Visible; 
    checkBox5 = get(hObject, 'Value');
    
    if(checkBox5 == 0)
        checkBox5Visible = 'off';
    else
        checkBox5Visible = 'on';
    end
    if(startBeenPressed)
        if(checkBox5 == 0)
          %Set plot 1 to be invisible
          set(uPlotSensor5,'Visible','off');
        else
            %we received a one
            set(uPlotSensor5, 'Visible', 'on');
        end
    end
end

% --- Executes on button press in checkbox6.
function checkbox6_Callback(hObject, eventdata, handles)
    global uPlotSensor6;
    global startBeenPressed;
    global checkBox6Visible; 
    checkBox6 = get(hObject, 'Value');
    
    if(checkBox6 == 0)  %This to update the state so start callback will be accurate
        checkBox6Visible = 'off';
    else
        checkBox6Visible = 'on';
    end
    
    if(startBeenPressed)
            if(checkBox6 == 0)
              %Set plot 1 to be invisible
              set(uPlotSensor6,'Visible','off');
            else
                %we received a one
                set(uPlotSensor6, 'Visible', 'on');
            end
    end
end

function file_menu_Callback(hObject, eventdata, handles)
end


function udp_properties_menu_Callback(hObject, eventdata, handles)
end


function graph_properties_menu_Callback(hObject, eventdata, handles)
end


function properties_menu_Callback(hObject, eventdata, handles)
end


%----------------UDP Parameters--------------------------------------------

% --- Executes during object creation, after setting all properties.
function HostIPEditField_CreateFcn(hObject, eventdata, handles)
    global remoteHostName;
    global IPEditField;
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    remoteHostName = get(hObject,'String');
    IPEditField = hObject;
end

% --- Executes during object creation, after setting all properties.
function RemotePortEdit_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
    global remotePort;
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    remotePort = str2double(get(hObject,'String'));
end


% --- Executes during object creation, after setting all properties.
function LocalPortEdit_CreateFcn(hObject, eventdata, handles)
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    global localPort;
    localPort = str2double(get(hObject,'String'));
end


function RemotePortEdit_Callback(hObject, eventdata, handles)
    global remotePort;
    remotePort = str2double(get(hObject,'String'));
end

function LocalPortEdit_Callback(hObject, eventdata, handles)
 %Set the value of the local port to whatever it is now
 %Global variable
 %Need to check if the 
    global localPort;
    localPort = str2double(get(hObject,'String'));
end

function HostIPEditField_Callback(hObject, eventdata, handles)
    global remoteHostName;
    remoteHostName = get(hObject,'String');
end

function setButton_Callback(hObject, eventdata, handles)
    %Check to see what the remote port and local port and other are valid
    %TODO change this to a structure similar to used for equation...TODO...
end

%--------------------TOOLBAR Code--------------------------
function csv_Callback(hObject, eventdata, handles)
end

function excel_export_Callback(hObject, eventdata, handles)
    global exportSensor1Array;
    global exportSensor2Array;
    global exportSensor3Array;
    global exportSensor4Array;
    global exportSensor5Array;
    global exportSensor6Array;
    
    %Need to ensure that the graph is stopped when this is pressed
    %TODO
  
    s1 = transpose(exportSensor1Array);
    s2 = transpose(exportSensor2Array);
    s3 = transpose(exportSensor3Array);
    s4 = transpose(exportSensor4Array);
    s5 = transpose(exportSensor5Array);
    s6 = transpose(exportSensor6Array);
    
    filename = 'graphTest1.xlsx'; %Need to implement a way for users to input a TitleName
    xlswrite(filename,s1,1,'A1');
    xlswrite(filename,s2,1,'B1');
    xlswrite(filename,s3,1,'C1');
    xlswrite(filename,s4,1,'D1');
    xlswrite(filename,s5,1,'E1');
    xlswrite(filename,s6,1,'F1');
    
    clear exportSensor1Array; %When to do this needs to be figured out...
    clear exportSensor2Array; %Maybe there should be a reset button?????
    clear exportSensor3Array;
    clear exportSensor4Array;
    clear exportSensor5Array;
    clear exportSensor6Array;
end

function export_csv_Callback(hObject, eventdata, handles)
end

%---------------USER EQUATION INPUT CODE ------------------
function edit_equation_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    %Set the initial equation to be applied to the graph
    global userVerifiedFunction;
    global userDefinedAFunction;
    userDefinedAFunction = false;
    userVerifiedFunction = str2func('@(x) x');
    disp('User Function');
    disp(userVerifiedFunction(1));
    %This will always be x...which will be the always be acceptable
    %input/the default
end


function edit_equation_Callback(hObject, eventdata, handles)
    global userUnVerifiedFunction;
    global userDefinedAFunction;
    global userFunctionFieldHandle;
    global userEQString;
    userDefinedAFunction = true;
    userFunctionFieldHandle = hObject;
    userEQString = get(hObject, 'String');
    userUnVerifiedFunction = str2func(['@(x)' vectorize(userEQString)]);
    disp('Equation Was Added');
end


function applyEquation_Callback(hObject, eventdata, handles)
    global userUnVerifiedFunction;
    global userVerifiedFunction;
    global userDefinedAFunction;
    global userFunctionFieldHandle; %Should I vectorize the equation???
    global userEQString;
    x = [1,2,3];
    equationWasValid = true;
    disp('Apply was pressed');
    if(userDefinedAFunction) %In the event user pressed apply without having inputted an equation.
        try
           y = userUnVerifiedFunction(x);
           disp('Tried the user function');
        catch
           disp('bad function');
           set(userFunctionFieldHandle, 'BackgroundColor', [1 0.9 0.9]);
           equationWasValid = false;
        end
        if(equationWasValid)
            if(length(y) == 3)
                userVerifiedFunction = userUnVerifiedFunction;
                set(userFunctionFieldHandle, 'BackgroundColor', 'white');
                disp('Equation was valid');
            else
                 %set(userFunctionFieldHandle, 'BackgroundColor', [1 0.9 0.9]);
                 %disp('Equation Not valid Because it was a constant');
                 userVerifiedFunction = str2func(strcat('@(x)',userEQString,'*ones(1,length(x))'));
            end
        end
    end
end


% --- Executes on button press in reset_equation.
function reset_equation_Callback(hObject, eventdata, handles)
    global userVerifiedFunction;
    global userFunctionFieldHandle;
    global userUnVerifiedFunction;
    userVerifiedFunction = str2func('@(x) x');
    userUnVerifiedFunction = userVerifiedFunction;
    set(userFunctionFieldHandle, 'String', 'x');
    set(userFunctionFieldHandle, 'BackgroundColor', 'white');
end

% --- Executes on button press in help_button.
function help_button_Callback(hObject, eventdata, handles)
    %TODO bring up popup about syntax
end
