system("TempleRunBuild/TempleRun.exe &")
fd = gameFaceDetector();
commands = {'jump', 'roll', 'turn', 'crouch'};
tcpipServer = tcpserver('127.0.0.1', 55000);
%%
tic
while toc < 10000000
    inputStruct = [];
   fd.getFacePos();
   if fd.rightTurn
    inputStruct = struct('turn', -single(1.0) );
   elseif fd.leftTurn
    inputStruct = struct('turn', single(1.0));
   end
    if tcpipServer.Connected && ~isempty(inputStruct)
        data = structToData(inputStruct);
        write(tcpipServer, data);
    end
    pause(.00001)
end