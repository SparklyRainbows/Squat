classdef sensorData < handle
    % sensorData Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        m
        Accelerations = zeros(100, 3);
        ind = 0;
        tmr
        dt = 1/20;
        commands = {'none', 'run', 'jump', 'crouch'};
    end
    
    methods
        function obj = sensorData()
            obj.m = mobiledev();
            obj.m.Logging = 1;
            obj.tmr = timer('Name','pong_timer',...
                'Period', obj.dt,... % 1 second between moves time.
                'StartDelay', 0,... %
                'ExecutionMode','fixedrate',...
                'TimerFcn',@obj.Update); % Function def. below.
            start(obj.tmr);
            tic;
            pause(1);
        end
        
        function delete(obj)
            stop(obj.tmr);
            obj.m.Logging = 0;
            delete(obj.m)
        end
        
        function command = getCommand(obj)
            accFreq = remove_0(fft_from_time(move_avg_filt(obj.Accelerations, 5), 100));
            rms_vals = rms(abs(accFreq(:, 2:4))) %[X, Y, Z] axes
            if (all(rms_vals < 20)) %check stand still
                commandInd = 1;
            elseif (rms_vals(2) < 90) %check for action
                if (rms_vals(2) >= 15) && (rms_vals(2) <= 45) %crouch
                    commandInd = 4;
                elseif (rms_vals(2) >= 60) && (rms_vals(2) <= 95) %jump
                    commandInd = 3;
                end
            end
            if ~exist('commandInd', 'var')
                commandInd = 2;
            end
            
            if (commandInd > 1) && (toc > 1)
                tic;
            else
                commandInd = 1;
            end
            
%             if toc < 1
%                 commandInd = 1;
%             end
            
            command = obj.commands(commandInd);
            
        end
        
        function Update(obj, varargin)
            obj.ind = mod(obj.ind+1, 100);
            data = obj.m.Acceleration;
            if ~isempty(data)
                obj.Accelerations(obj.ind + 1, :) = data;
            end
        end
    end
end

