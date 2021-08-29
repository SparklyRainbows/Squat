function outputStruct = dataToStruct(data)
%% dataToStruct convert data array of unint8 to a struct
% The data array is formatted in the following way:
% header:
% 1. uint8: number of fields   
% body:
% 1. uint8: length of field name
% 2. uint8 x N: array of bytes representing the field name char array
% 3. uint8: length of class name
% 4. uint8 x N: array of bytes representing the class name char array
% 5. uint8: length in byte of value
% 6. uint8 x N: array of bytes representing the value
numFields = data(1);
cellData = cell(2*numFields, 1);
counter = 2;
for i = 1 : numFields
    fieldNameLength = data(counter);
    counter = counter + 1;
    fieldName = char(data(counter + (1:fieldNameLength) - 1));
    counter = counter + fieldNameLength;
    
    classNameLength = data(counter);
    counter = counter + 1;
    className = char(data(counter + (1:classNameLength) - 1));
    counter = counter + classNameLength;
    
    valueLength = data(counter);
    counter = counter + 1;
    if ~strcmp(className, 'char')
        value = typecast(data(counter + (1:valueLength) - 1), className);
    else
        value = char(data(counter + (1:valueLength) - 1));
    end
    counter = counter + valueLength;
    
    cellData{2*i - 1} = fieldName;
    cellData{2*i} = value;
    
end
outputStruct = struct(cellData{:});


end