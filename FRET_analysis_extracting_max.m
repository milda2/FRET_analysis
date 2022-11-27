
%% promt
clc; close all;
%%
prompt = {'\fontsize{16}What is your file name? Case sensitive! '};
Title = 'Input'; 
defaultans = {''}; 
opts.Interpreter = 'tex'; 
answer = inputdlg(prompt,Title,[1, 120],defaultans, opts);

str=answer{1,1};  % This is our cell array.
str1 = char(str);

fn = {'Gain of FRET', 'Loss of FRET'};
[indx,tf] = listdlg('PromptString',{'Select your sensor:'},...
    'SelectionMode','single','ListSize',[150, 50],'ListString',fn);
%% load data
[RawNumbers,~,~] = xlsread(str1);

%% clean data - find and remove NaN (= remove zero clock, etc)
[row, ~] = find(isnan(RawNumbers));
if isempty(row)
    row=0;
end
row = max(row);
CleanedData = RawNumbers((row+1):end, :); 

%% analyse data
[CFP, YFP] = subtract_background (CleanedData);
r1 = ratio (CFP, YFP, indx);
f1 = FRET_change (r1);
c1 = cyan_normal (CFP);
y1 = yellow_normal (YFP);
[~, y2]  = size (CFP);

%% write analysed data into .csv
[x, ~]  = size (CFP);
Empty = zeros(x,1);
BCK = [ CFP, Empty, YFP, Empty, r1, Empty, f1, Empty, c1, Empty, y1];
Labels =['CFP', '', 'YFP', '', 'RATIO', '', 'FRET CHANGE', '', 'CFP NORM', '', 'YFP NORM'];
% writecell({BCK, Labels}, "Analysed_"+str1+".csv")
%str1
% xlswrite("Analysed_"+str1+".csv", [Labels, BCK])
writematrix(BCK,"Analysed_"+str1+".csv") %% 


%% plot data all

figure (91)
subplot (2,2,1)
plot (CleanedData(:, 1), mean(CFP,2), 'b','LineWidth', 2)
hold on;
plot (CleanedData(:, 1), mean(YFP,2), 'y','LineWidth', 2)
hold off;
xlabel('Time (ms)');
ylabel('CFP and YFP');

subplot (2, 2, 2)
plot (CleanedData(:, 1), r1,'LineWidth', 2);
xlabel('Time (ms)');
ylabel('Ratio');

subplot (2, 2, 3)
plot (CleanedData(:, 1), f1, 'LineWidth', 2)
xlabel('Time (ms)');
ylabel('FRET change, %');
legend ('ROI2', 'ROI3', 'ROI4', 'ROI5', 'Location', 'northwest');

subplot (2, 2, 4)
plot (CleanedData(:, 1), mean(c1,2), 'b', 'LineWidth', 2)
hold on;
plot (CleanedData(:, 1), mean(y1,2), 'y', 'LineWidth', 2)
hold off;
xlabel('Time (ms)');
ylabel('Norm. cyan/yellow');


%% SAVE FIGURE
saveas(figure(91), "Figure_"+str1+".tiff");

%% Calculate the FRET change at specified times
%First, calculate the baseline/starting FRET values and Max
%Calcualte basal ratios
basal_ratios = mean (r1(12:20,:));

baseline=[];
RealMax=[];
RealStim1=[];
RealSitm2=[];
RealStim3=[];
[~,x7] = size(f1);

% enter time periods
prompt = {'Start of stim1','Start of Stim 2','Start of Stim3','Start of Stim4','Start of Stim5'};
dlgtitle = 'Time (ms)';
dims = [1, 35];
answer = inputdlg(prompt,dlgtitle,dims);
% Then answer{1} is r1, anser{2} is r2, and so on
% to convert to number
answer = str2double(answer);
Stim1_start = round(answer(1)/5);  % and so on
Stim2_start = round(answer(2)/5);
Stim3_start = round(answer(3)/5);
Stim4_start = round(answer(4)/5);
Stim5_start=round(answer(5)/5); 

% calculation
for i=1:x7
    trace1=f1(:,i);
    
    [maxFRET, timemax] = max(trace1);
    baseline(1,i) = mean( trace1( 10:20 ));
    bb = timemax-2; %take 3 numbers
    RealMax(1,i) = (sum( trace1(bb:timemax, 1), 'all'))/3 - baseline(1,i); %5 is the number of variables in the array
    
    Range1 = Stim1_start:Stim2_start;
    Stim1 = trace1(Range1);
    [max1, when1] = max(Stim1);
    real_when1 = Range1(when1);
    Real_Stim1(1, i) = (sum(Stim1( (when1-1):(when1+1) ,1),'all')) / 3 - baseline (1,i);   
    i=i+1;

    Range2 = Stim2_start:Stim3_start;
    Stim2 = trace1(Range2);
    [max2, when2] = max(Stim2);
    real_when2 = Range2(when2);
    Real_Stim2(1, i) = (sum(Stim2( (when2-1):(when2+1) ,1),'all')) / 3 - baseline (1,i);   
    i=i+1;

    Range3 = Stim3_start:Stim4_start;
    Stim3 = trace1(Range3);
    [max3, when3] = max(Stim3);
    real_when3 = Range3(when3);
    Real_Stim3(1, i) = (sum(Stim3( (when3-1):(when3+1) ,1),'all')) / 3 - baseline (1,i);   
    i=i+1;
end


opts.Default = 'Ok';

%Calcualte kinetics

%% write analysed data into .csv
[x, ~]  = size (CFP);
Empty = zeros(x,1);
BCK = [ CFP, Empty, YFP, Empty, r1, Empty, f1, Empty, c1, Empty, y1];
%Labels =['CFP', '', 'YFP', '', 'RATIO', '', 'FRET CHANGE', '', 'CFP NORM', '', 'YFP NORM'];
%writetable(BCK, Labels, "Analysed_"+str1+".csv")
%str1
writematrix(BCK,"Analysed_"+str1+".csv") %% 

%% write calcualtions data into .csv

basal_ratios=basal_ratios.';
max_fret = RealMax.';
Stim1 = RealStim1.';
Stim2 = RealStim2.';
Stim3 = RealStim3.';
[x5, ~]  = size (basal_ratios);
Empty2 = zeros(x5,1);
BCK5 = [basal_ratios, Empty2, max_fret, Empty2, ...
    Stim1, Empty2, Stim2, Empty2, Stim3];
% Labels5 ={'basal ratios', '', 'Max FRET change', '', 'Stim1', '', ...
%     'Stim2', '', 'Stim3'};
%str1
writematrix(BCK5,"Calculated_"+str1+".csv") %% 

%%close figure
%close(figure(90));


%% functions

function [CFP, YFP] = subtract_background (RAWdata)
R = RAWdata;
[~, y]  = size (R);
y = y-1-6; % y=total length, -1 for time, -3 for the background, -3 for the final three
a=0;
    for i = 0:3:y % increase in increments =3, start from 0 giving 0, 3, 6 etc.
        W1bck(:,1+a) = R(:, 5+i)-R (:, 2); %R starts from 5 cause 1st is time, 2-4 is bcground
        W2bck(:,1+a) = R(:, 6+i) - R(:, 3);
        a=a+1;
    end
CFP = W1bck;
YFP = W2bck;
end

function r1 = ratio (CFP, YFP, indx)
    if indx == 2
     r1 = CFP./YFP;
    else
     r1 = YFP./CFP;
    end
end

function f1 = FRET_change (r1)
avg3 = mean (r1(12:22,:)); %% From the 12th to the 22th value of the basal, 10 value, averaged before adding first stimulus at 24
f1 = ((r1./avg3)*100)-100;
end

function c1 = cyan_normal (CFP)
avg1 = mean (CFP(10:50, :));
c1 = ((CFP./avg1)*100)-100;
end

function y1 = yellow_normal (YFP)
avg2 = mean (YFP(10:50, :));
y1 = ((YFP./avg2)*100)-100;
end
