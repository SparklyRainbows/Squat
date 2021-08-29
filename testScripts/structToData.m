function data  = structToData(inputStruct)
%% structToData convert a struct into an array of uint8
% The data array will be formatted in the following way:
% header:
% 1. uint8: number of fields   
% body:
% 1. uint8: length of field name
% 2. uint8 x N: array of bytes representing the field name char array
% 3. uint8: length of class name
% 4. uint8 x N: array of bytes representing the class name char array
% 5. uint8: length in byte of value
% 6. uint8 x N: array of bytes representing the value
allFields = fields(inputStruct)';
cellData = cell(1 + 6*length(allFields), 1);
cellData{1} = uint8(length(allFields));
count = 2;
for f = allFields
    field = f{1};
    value = inputStruct.(field);
    validateattributes(value, {'double', 'single', 'uint16', 'uint32',...
        'int16', 'int32', 'char'}, {})
    cellData{count} = uint8(field);
    className = class(value);
    if isa(value, 'logical') || isa(value, 'char') 
        value = uint8(value);
    end
    cellData{count+1} = uint8(field);
    cellData{count} = uint8(length(cellData{count+1}));
    cellData{count + 3} = uint8(className); 
    cellData{count + 2} = uint8(length(cellData{count + 3})); 
    cellData{count + 5} = typecast(value, 'uint8');
    cellData{count + 4} = uint8(length(cellData{count + 5}));
    count =  count + 6;
end
data = [cellData{:}];
if length(data) > 255
   error('length of data array exceeds maximum size of 255') 
end
end