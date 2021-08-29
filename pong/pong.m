classdef pong < handle
    
    % globals
    
    properties
        connected = false;
        tcp = [];
        inputs = [];
        graphics
        color
        worldBounds
        paddel1
        paddel2
        paddel1Vel
        paddel2Vel
        ball
        ballR
        ballVel
        paddelShape
        dt
        tmr
        tmr2
    end
    
    methods
        function S = pong()
            close all
            S.setup();
        end
        
        function setup(S)
            S.graphics = cell(4,1);
            S.color = .9*[1 .95 .91]; % Allows for easy change.  Figure color.
            S.worldBounds = [100 100 1000 720];
            fig = figure('units','pixels',...
                'name','Pong',...
                'menubar','none',...
                'numbertitle','off',...
                'position', S.worldBounds,...
                'color', 'k',...
                'keypressfcn', @S.fig_kpfcn,...%
                'closereq', @S.fig_clsrqfcn,...%
                'busyaction','cancel',...
                'renderer','opengl');
            hold on
            ax = gca;
            ax.XTickLabel = [];
            ax.YTickLabel = [];
            ax.XTick = [];
            ax.YTick = [];
            ax.XAxis.Color =  S.color;
            ax.YAxis.Color =  S.color;
            xlim([S.worldBounds(1) S.worldBounds(3)]);
            ylim([S.worldBounds(2) S.worldBounds(4)]);
            
            S.paddel1 = [S.worldBounds(1) + 100, mean(S.worldBounds([2 4]))];
            S.paddel2 = [S.worldBounds(3) - 100, mean(S.worldBounds([2 4]))];
            S.paddel1Vel = [0 0];
            S.paddel2Vel = [0 0];
            xSquare  = [0 0 1 1]' -.5;
            ySquare  = [0 1 1 0]' - .5;
            S.paddelShape = [20*xSquare, 100*ySquare];
            
            S.ball = [mean(S.worldBounds([1 3])), mean(S.worldBounds([2 4]))];
            S.ballR = 5;
            dir = rand(1, 2) - .5;
            S.ballVel = 400*dir./norm(dir);
            S.dt = 0.016;
            S.tmr = timer('Name','pong_timer',...
                'Period', S.dt,... % 1 second between moves time.
                'StartDelay', 0,... %
                'ExecutionMode','fixedrate',...
                'TimerFcn',@S.Update); % Function def. below.
            start(S.tmr);
            
            S.tmr2 = timer('Name','TCP_timer',...
                'Period', 10,... % 1 second between moves time.
                'StartDelay',1,... %
                'ExecutionMode','fixedrate',...
                'TimerFcn',@S.connectToServer); % Function def. below.
            start(S.tmr2)
        end
        
        
        function checkCollision(S)
            if S.ball(1) - S.ballR  <= S.worldBounds(1) % hit left wall
                S.ballVel(1) = abs(S.ballVel(1));
            elseif  S.ball(1) + S.ballR > S.worldBounds(3) % hit right wall
                S.ballVel(1) = -abs(S.ballVel(1));
            elseif  S.ball(2) - S.ballR <= S.worldBounds(2) % hit floor
                S.ballVel(2) = abs(S.ballVel(2));
            elseif  S.ball(2) + S.ballR >= S.worldBounds(4) % hit ceiling
                S.ballVel(2) = -abs(S.ballVel(2));
            end
            S.checkCollisionPaddel(S.paddel1, S.paddelShape)
            S.checkCollisionPaddel(S.paddel2, S.paddelShape)
            
            
        end
        
        function checkCollisionPaddel(S, paddel, paddelShape)
            BL = [paddel(1) + paddelShape(1, 1) paddel(2) + paddelShape(1, 2)];
            TL = [paddel(1) + paddelShape(1, 1) paddel(2) + paddelShape(2, 2)];
            BR = [paddel(1) + paddelShape(3, 1) paddel(2) + paddelShape(1, 2)];
            TR = [paddel(1) + paddelShape(3, 1) paddel(2) + paddelShape(2, 2)];
            lines = {{BL TL}, {TL TR}, {TR, BR}, {BR, BL}};
            S.checkCollisionLines(lines)
        end
        
        function checkCollisionLines(S, lines)
            for i = 1 : length(lines)
                val = lines{i};
                p0 = val{1};
                p1 = val{2};
                % (p1-p0)t + p0
                b0 = S.ball;
                dir = [p1 - p0 1];
                normal = cross(dir, [0 0 -1]);
                normal = normal(1:2);
                normal = normal./norm(normal);
                b1 = S.ballR*normal + b0;
                % (p1-p0)t1 + p0 = (b1-b0)t2 + b0
                b = (b0 - p0)';
                A = [(p1-p0)'  (b1-b0)'];
                t = A\b;
                if any(t>1) || any(t<0)
                    continue % no collision
                end
                val = dot(normal, S.ballVel);
                S.ballVel = S.ballVel - 2*val*normal;
                
            end
            
        end
        
        function Update(S, varargin)
            S.checkCollision();
            S.ball = S.ball + S.ballVel*S.dt;
            S.paddel1 = S.paddel1 + S.paddel1Vel*S.dt;
            S.paddel2 = S.paddel2 + S.paddel2Vel*S.dt;
            S.paddel1Vel = S.paddel1Vel*.7;
            S.paddel2Vel = S.paddel2Vel*.7;
            if S.paddel2(2) + S.paddelShape(2, 2) > S.worldBounds(4)
                S.paddel2(2) = S.worldBounds(4) - S.paddelShape(2, 2);
            elseif S.paddel2(2) + S.paddelShape(1, 2) < S.worldBounds(2)
                S.paddel2(2) = S.worldBounds(2)- S.paddelShape(1, 2);
            end
            
            if S.paddel1(2) + S.paddelShape(2, 2) > S.worldBounds(4)
                S.paddel1(2) = S.worldBounds(4) - S.paddelShape(2, 2);
            elseif S.paddel1(2) + S.paddelShape(1, 2) < S.worldBounds(2)
                S.paddel1(2) = S.worldBounds(2)- S.paddelShape(1, 2);
            end
            
            S.UIUpdate();
        end
        
        function UIUpdate(S)
            x = [S.worldBounds(1) S.worldBounds(1) S.worldBounds(3) S.worldBounds(3)];
            y = [S.worldBounds(2) S.worldBounds(4) S.worldBounds(4) S.worldBounds(2) ];
            for i = 1 : length(S.graphics)
                if ~isempty(S.graphics{i})
                    delete(S.graphics{i})
                end
                
            end
            S.graphics{1} = patch(x,y, S.color, 'EdgeColor', S.color);
            S.graphics{2} = patch(S.paddelShape(:, 1) + S.paddel1(1) , S.paddelShape(:, 2) + S.paddel1(2)...
                , 'white', 'EdgeColor', S.color);
            S.graphics{3} = patch(S.paddelShape(:, 1) + S.paddel2(1) , S.paddelShape(:, 2) + S.paddel2(2)...
                , 'white', 'EdgeColor', S.color);
            S.graphics{4} = plot(S.ball(1), S.ball(2),'MarkerSize', 35, 'MarkerEdgeColor', 'white'...
                ,'Marker', '.', 'MarkerFaceColor','white');
        end
        
        function [] = fig_kpfcn(S, varargin)
            switch varargin{2}.Key
                case 'downarrow'
                    S.paddel2Vel(2) = -600;
                case 'uparrow'
                    S.paddel2Vel(2) = 600;
            end
        end
        
        function [] = fig_clsrqfcn(S, varargin)
            stop(S.tmr);
            stop(S.tmr2);
            delete(varargin{1})
        end
        
        function connectToServer(S, ~, ~, ~)
            if ~S.connected
                try
                    % TCP connection
                    address = '127.0.0.1';
                    port = 55000;
                    S.tcp = tcpclient(address, port);
                    configureCallback(S.tcp, "byte", 2, @S.TCPCallbackFcn);
                    S.connected = true;
                    stop(S.tmr2)
                catch
                    warning('falled to conenct to Server. Please make sure MATLAB server is running.')
                end
            end
        end
        
        function TCPCallbackFcn(S, ~, ~, ~)
            if S.connected
                % if connected && isfield(S, 'CUR') && ~TCPCommandExecuted
                data = read(S.tcp);
                if ~isempty(data)
                    S.inputs = dataToStruct(data);
                    S.fig_kpfcn([], S.inputs);
                end
            end
        end
    end
end