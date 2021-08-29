% clear all
p = pong();
if ~exist('fd')
    fd = gameFaceDetector();
end
commands = {'downarrow','uparrow'};
tcpipServer = tcpserver('127.0.0.1', 55000);
tic
while toc < 10000000
    v = fd.getFacePos();
    goalPos = 1080 - 3*mean(reshape(v, 2, []),2);
    dy = p.paddel2(2) - goalPos(2);
    ind = (dy < 0) + 1;
    if abs(dy) > 30
        inputStruct = struct('Key', commands{ind});
        if tcpipServer.Connected
            data = structToData(inputStruct);
            write(tcpipServer, data);
        end
    end
    pause(.000001)
end