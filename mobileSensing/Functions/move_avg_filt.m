function f_data = move_avg_filt(time_data, num_pt)
%move_avg_filt performs num_pt moving average filter (low-pass) on data in time domain
%time data: N x 3 matrix. col 1: x, col 2: y, col 3: z
%num_pt: must be odd integer between 3-9

%get accelerations in all 3 axes
%disregard beginning and end data points to account for starting and
%stoping
x = time_data(:, 1);
y = time_data(:, 2);
z = time_data(:, 3);
data = [x y z];

f_data = ones(length(x)-num_pt, 3); %initialize matrix

%perform num_pt moving average filter in all 3 axes
if num_pt == 3 %3 point moving average
    pos = 2;
    for i=pos:length(x) - pos
    f_data(i-1, 1) = 1/num_pt*(data(i-1,1) + data(i,1) + data(i+1,1));
    f_data(i-1, 2) = 1/num_pt*(data(i-1,2) + data(i,2) + data(i+1,2));
    f_data(i-1, 3) = 1/num_pt*(data(i-1,3) + data(i,3) + data(i+1,3));
    end
elseif num_pt == 5 %5 point moving average
    pos = 3;
    for i=pos:length(x) - pos
    f_data(i-2, 1) = 1/num_pt*(data(i-2, 1) + data(i-1,1) + data(i,1) + data(i+1,1) + data(i+2, 1));
    f_data(i-2, 2) = 1/num_pt*(data(i-2, 2) + data(i-1,2) + data(i,2) + data(i+1,2) + data(i+2, 2));
    f_data(i-2, 3) = 1/num_pt*(data(i-2, 3) + data(i-1,3) + data(i,3) + data(i+1,3) + data(i+2, 3));
    end
elseif num_pt == 7 %7 point moving average
    pos = 4;
    for i=pos:length(x) - pos
    f_data(i-3, 1) = 1/num_pt*(data(i-3, 1) + data(i-2, 1) + data(i-1,1) + data(i,1) + data(i+1,1) + data(i+2, 1) +  data(i+3, 1));
    f_data(i-3, 2) = 1/num_pt*(data(i-3, 2) + data(i-2, 2) + data(i-1,2) + data(i,2) + data(i+1,2) + data(i+2, 2) +  data(i+3, 2));
    f_data(i-3, 3) = 1/num_pt*(data(i-3, 3) + data(i-2, 3) + data(i-1,3) + data(i,3) + data(i+1,3) + data(i+2, 3) +  data(i+3, 3));
    end
elseif num_pt == 9 %9 point moving average
    pos = 5;
    for i=pos:length(x) - pos
    f_data(i-4, 1) = 1/num_pt*(data(i-4, 1) + data(i-3, 1) + data(i-2, 1) + data(i-1,1) + data(i,1) + data(i+1,1) + data(i+2, 1) +  data(i+3, 1) + data(i+4, 1));
    f_data(i-4, 2) = 1/num_pt*(data(i-4, 2) + data(i-3, 2) + data(i-2, 2) + data(i-1,2) + data(i,2) + data(i+1,2) + data(i+2, 2) +  data(i+3, 2) + data(i+4, 2));
    f_data(i-4, 3) = 1/num_pt*(data(i-4, 3) + data(i-3, 3) + data(i-2, 3) + data(i-1,3) + data(i,3) + data(i+1,3) + data(i+2, 3) +  data(i+3, 3) + data(i+4, 3));
    end
end