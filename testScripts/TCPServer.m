clear all
matlabtetris();
commands = {'rightarrow','leftarrow', 'downarrow','uparrow'};
tcpipServer = tcpserver('127.0.0.1', 55000);
tic
while toc < 10000000
   ind = randi(4);
   inputStruct = struct('Key', commands{ind}, 'Modifier', 'none');
    if tcpipServer.Connected
        data = structToData(inputStruct);
        write(tcpipServer, data);
    end
    pause(.1)
end