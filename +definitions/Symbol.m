classdef Symbol < definitions.CIFWriter
    properties (SetAccess = private)
        symbolId int32                          % The id of the symbol
        name string                             % The name of the symbol
        normalization double                    % The factor by which the geometry is normalized, so each value filled in for lengths is normalized by this factor by the user
        geometries (1, :) geometries.Geometry   % All defined geometries in the symbol
    end
    
    methods
        function obj = Symbol(fileHandle, symbolId, name, normalization)
            % Layer Create an instance of a Layer object that is responsible for managing the information about a layer type in a CIF design.
            arguments
                fileHandle (1, 1) int32         % The file handle to the CIF file
                symbolId (1, 1) int32           % The id of the symbol
                name string                     % The name of the symbol
                normalization (1, 1) double     % The factor by which the geometry is normalized, so each value filled in for lengths is normalized by this factor by the user
            end
            
            % Construct the superclass
            obj = obj@definitions.CIFWriter(fileHandle);
            
            obj.symbolId = symbolId;
            obj.name = name;
            obj.normalization = normalization;
        end
        
        function obj = printFile(obj)
            % Calculate the values for the a and b factors as normalization = a/b * distance where distance = 0.01 um
            distance = 1e-6;
            factor = obj.normalization / distance;
            
            [aFactor, bFactor] = rat(factor);
            
            % Variable that stores the last layer ID
            lastLayer = definitions.Layer.NoLayer();
            
            % First, write the symbol header
            symbolHeader = sprintf("DS%i %i %i;", obj.symbolId, aFactor, bFactor);
            symbolName = sprintf("9 %s;", obj.name);
            
            obj.write(symbolHeader);
            obj.write(symbolName);
            
            % Next, go over all geometries and write them
            for geometry = obj.geometries
                geometry.printFile(lastLayer);
                
                lastLayer = geometry.layer;
            end
            
            % Write the close keyword
            obj.write("DF;");
        end
        
        function csObj = callSymbol(obj, symbol)
            % CALLSYMBOL Call a given symbol. Adds the symbol to the parent symbol and returns a new CallSymbol object to apply transformations
            arguments
                obj definitions.Symbol
                symbol definitions.Symbol   % The Symbol that should be called
            end
            
            % Create the geometry
            csObj = geometries.CallSymbol(obj.fileHandle, symbol);
            
            % And add it to the list of geometries
            obj.geometries(end+1) = csObj;
        end
        
        function pObj = polygon(obj, layer, initialXYs)
            arguments
                obj definitions.Symbol
                layer definitions.Layer         % The layer the geomettry uses
                initialXYs (:, 2) int32 = []    % Optional list with x and y coordinates of the polygon path
            end
            
            % Create the geometry
            pObj = geometries.Polygon(obj.fileHandle, layer, initialXYs);
            
            % And add it to the list of geometries
            obj.geometries(end+1) = pObj;
        end
    end
end