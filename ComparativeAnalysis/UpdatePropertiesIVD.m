function UpdatePropertiesIVD(Modeltype, MatParameter)
    % Common settings
    SegmentName = "L4L5";
    AFMaterialDensity = 1.2e-09; % density for af
    numSubregions = 5;
    numLayers = 5;    

    if Modeltype == 1 % HGO
        % Initialize x with additional elements for DNP and DAF
        x = InitializeMatArray(MatParameter, [3,5], [0,0]);
        [xK1Rad, xK2Rad]=CalculateHGOStiffnessVariation(numSubregions, numLayers, x(6),x(7),x(9),x(10), x(11),x(12));
        % Calculate the fiber angles    
        FiberAngles = CalculateFiberAngles(numSubregions, numLayers, x(13), x(14), x(15));
        %% Write the material parameters to the inp file
        %-- Nucleus - mechanical properties
        fileID = fopen(join(["./MAT/HGO/MaterialParametersNucleus",SegmentName,".inp"],''),'w');
        fprintf(fileID,'%f, %f, %f',x(1:3));
        fclose(fileID);
        %-- Annulus - mechanical properties
        AnnulusRegions = ['A', 'B', 'C', 'D', 'E'];
        AnnulusLayers = 1:5;
        for region = AnnulusRegions
            for layer = AnnulusLayers
                fileID = fopen(join(["./MAT/HGO/MaterialParametersAnnulusRegion", region, num2str(layer), SegmentName, ".inp"], ''), 'w');
                fprintf(fileID, '%f, %f, %f, %f, %f', x(4:5), xK1Rad(layer, AnnulusRegions == region), xK2Rad(layer, AnnulusRegions == region), x(8));
                fclose(fileID);
            end
        end
        %-- Annulus - fiber angles
        AnnulusRegions = ['A', 'B', 'C', 'D', 'E'];
        AnnulusLayers = 1:numLayers;
        for i=1:numSubregions        
            for j=1:numLayers
                FiberAngle = [cosd(FiberAngles(j,i)), sind(FiberAngles(j,i)), 0; cosd(FiberAngles(j,i)), -sind(FiberAngles(j,i)), 0]';
                filename = strjoin(["./MAT/HGO/MaterialParametersAnnulusRegion", AnnulusRegions(i), num2str(AnnulusLayers(j)),SegmentName,"_FiberAngle.inp"], '');
                fileID = fopen(filename,'w');
                fprintf(fileID,'%6.2f, %6.2f, %12.8f\n',FiberAngle);
                fclose(fileID);
            end
        end

    elseif Modeltype == 2 % lin. rebar
        % Initialize x with additional elements for DNP and DAF
        x = InitializeMatArray(MatParameter, [3,6], [0,0]);
        EModFibers = CalculateLinRebarStiffnessVariation(numSubregions, numLayers, x(7), x(8), x(9));
        % Calculate the fiber angles    
        FiberAngles = CalculateFiberAngles(numSubregions, numLayers, x(11), x(12), x(13));

        %% Write the material parameters to the inp file
        %-- Nucleus - mechanical properties
        fileID = fopen(join(["./MAT/LinRebar\MaterialParametersNucleus",SegmentName,".inp"],''),'w');
        fprintf(fileID,'%f, %f, %f',x(1:3));
        fclose(fileID);
        %-- Annulus - mechanical properties
        fileID = fopen(join(["./MAT/LinRebar\MaterialParametersAnnulus",SegmentName,".inp"],''),'w');
        fprintf(fileID,'%f, %f, %f',x(4:6));
        fclose(fileID);    
        % Fiber-Membrane material-definition
        filename = "./MAT/LinRebar/MaterialParametersFiberMembrane.inp";
        fileID = fopen(filename,'w');
        fprintf(fileID, '*Hyperelastic, mooney-rivlin\n%s,%s,%s',num2str(x(4)),num2str(x(5)),num2str(x(6)));
        fclose(fileID);
        %-- AnnulusFibers - mechanical properties
        AnnulusRegions = ['A', 'B', 'C', 'D', 'E'];
        AnnulusLayers = 1:2*numLayers;
        for i=1:numSubregions
            l = 1;
            for j=1:length(AnnulusLayers)
                filename = strjoin(["./MAT/LinRebar/MaterialParametersAnnulusRegion", AnnulusRegions(i), num2str(AnnulusLayers(j)),SegmentName,"_Fibers.inp"], '');
                fileID = fopen(filename,'w');
                fprintf(fileID, '*Elastic\n');
                fprintf(fileID,'%f, %f\n', EModFibers(l,i),x(10));
                fprintf(fileID,'*No Compression\n');
                fclose(fileID);
                if mod(j, 2) == 0
                    l = l + 1;
                end
            end
        end
        %-- Annulus - fiber angles
        for i=1:length(AnnulusRegions)
            l = 1;
            for j=1:length(AnnulusLayers)
                filename = strjoin(["./MAT/LinRebar/MaterialParametersAnnulusRegion", AnnulusRegions(i), num2str(AnnulusLayers(j)),SegmentName,"_FiberAngle.inp"], '');
                % Split the content by commas
                fileID = fopen(filename,'r');
                content = fgets(fileID);
                parts = strsplit(content, ',');
                fclose(fileID);        
                % Locate the angle-entry and replace it with the new value
                new_value = num2str(FiberAngles(l,i));
                if mod(j, 2) == 0                
                    new_value = ['-', new_value];
                    l = l + 1;
                end
                parts{6} = new_value;        
                % Join the modified parts back into a string
                modified_content = strjoin(parts, ',');
                fileID = fopen(filename,'w');
                fprintf(fileID, '%s', modified_content);
                fclose(fileID);
            end
        end
        % Update material density
        filename = "./MAT/LinRebar/MaterialDensity.inp";
        fileID = fopen(filename,'w');
        fprintf(fileID,'%s,', num2str(AFMaterialDensity));
        fclose(fileID);

    else % nonlin. rebar model
        % Initialize x with additional elements for DNP and DAF
        x = InitializeMatArray(MatParameter, [3,6], [0,0]);
        [FiberStrain, FiberStress_0, XLambdaRad] = CalculateNonLinRebarStiffnessVariation(numSubregions, numLayers,x(7), x(8), x(9));
        % Calculate the fiber angles    
        FiberAngles = CalculateFiberAngles(numSubregions, numLayers, x(11), x(12), x(13));
        %% Write the material parameters to the inp file
        %-- Nucleus - mechanical properties
        fileID = fopen(join(["./MAT/NonlinRebar/MaterialParametersNucleus",SegmentName,".inp"],''),'w');
        fprintf(fileID,'%f, %f, %f',x(1:3));
        fclose(fileID);
        %-- Annulus - mechanical properties
        fileID = fopen(join(["./MAT/NonlinRebar/MaterialParametersAnnulus",SegmentName,".inp"],''),'w');
        fprintf(fileID,'%f, %f, %f',x(4:6));
        fclose(fileID);
        % Fiber-Membrane material-definition
        filename = "./MAT/NonlinRebar/MaterialParametersFiberMembrane.inp";
        fileID = fopen(filename,'w');
        fprintf(fileID, '*Hyperelastic, mooney-rivlin\n%s,%s,%s',num2str(x(4)),num2str(x(5)),num2str(x(6)));
        fclose(fileID);
        %-- AnnulusFibres - mechanical properties
        fiberMatDefinition = ['*Hyperelastic, marlow, poisson=', num2str(x(10))];
        fiberMatDefinitionExtra = ['*Hyperelastic, mooney-rivlin, test data input, poisson=', num2str(x(10))];
        filename = "./MAT/NonlinRebar/MaterialFiberDefinition.inp";
        fileID = fopen(filename,'w');
        fprintf(fileID, fiberMatDefinition);
        fclose(fileID);
        filenameFiberDefinition = filename;
        filename = "./MAT/NonlinRebar/MaterialFiberDefinitionExtra.inp";
        fileID = fopen(filename,'w');
        fprintf(fileID, fiberMatDefinitionExtra);
        fclose(fileID);
        filenameFiberDefinitionExtra = filename;
        %-- AnnulusFibers - write mechanical properties
        AnnulusRegions = ['A', 'B', 'C', 'D', 'E'];
        AnnulusLayers = 1:10;
        for i=1:numSubregions
            l = 1;
             for j=1:length(AnnulusLayers)
                filename = strjoin(["./MAT/NonlinRebar/MaterialParametersAnnulusRegion", AnnulusRegions(i), num2str(AnnulusLayers(j)),SegmentName,"_Fibers.inp"], '');
                fileID = fopen(filename,'w');
                if i == numSubregions&& j == length(AnnulusLayers)
                    fprintf(fileID,'*Include, input=%s\n', filenameFiberDefinitionExtra);
                else
                    fprintf(fileID,'*Include, input=%s\n', filenameFiberDefinition);
                end
                fprintf(fileID, '*Uniaxial Test Data\n');
                FiberStress = FiberStress_0 * XLambdaRad(l,i);
                FiberStress(1:10) = FiberStress_0(1:10);
                for k = 1:length(FiberStress)
                    fprintf(fileID,'%f, %f\n', FiberStress(k),FiberStrain(k));
                end
                fclose(fileID);
                if mod(j, 2) == 0
                    l = l + 1;
                end
            end
        end
        %-- Annulus - fiber angles
        for i=1:length(AnnulusRegions)
            l = 1;
            for j=1:length(AnnulusLayers)
                filename = strjoin(["./MAT/NonlinRebar/MaterialParametersAnnulusRegion", AnnulusRegions(i), num2str(AnnulusLayers(j)),SegmentName,"_FiberAngle.inp"], '');
                % Split the content by commas
                fileID = fopen(filename,'r');
                content = fgets(fileID);
                parts = strsplit(content, ',');
                fclose(fileID);        
                % Locate the angle-entry and replace it with the new value
                new_value = num2str(FiberAngles(l,i));
                if mod(j, 2) == 0                
                    new_value = ['-', new_value];
                    l = l + 1;
                end
                parts{6} = new_value;        
                % Join the modified parts back into a string
                modified_content = strjoin(parts, ',');
                fileID = fopen(filename,'w');
                fprintf(fileID, '%s', modified_content);
                fclose(fileID);
            end
        end
        % Update material density
        filename = "./MAT/NonlinRebar/MaterialDensity.inp";
        fileID = fopen(filename,'w');
        fprintf(fileID,'%s,', num2str(AFMaterialDensity));
        fclose(fileID);

    end
end


function x = InitializeMatArray(MatParameter, PredefinedPositions, PredefinedValues)
    totalLength = length(MatParameter) + length(PredefinedPositions);
    x = zeros(totalLength, 1);
    x(PredefinedPositions) = PredefinedValues;    
    % Logical indexing for positions not predefined
    nonPredefined = true(totalLength, 1);
    nonPredefined(PredefinedPositions) = false;    
    % Directly assign values from MatParameter to non-predefined positions
    x(nonPredefined) = MatParameter;
end

function [xK1Rad, xK2Rad]=CalculateHGOStiffnessVariation(numSubregions, numLayers, K1,K2,K1Circ,K2Circ,K1Rad,K2Rad)
    % Calculate K1 and K2 for the circumferential direction 
    StepCirc = 1:numSubregions;
    StepRad = 1:numLayers;
    xK1Circ = K1 + K1Circ * K1 *(StepCirc-1);
    xK2Circ = K2 + K2Circ * K2 *(StepCirc-1);
    % Calculate the K1 and K2 for the radial direction based on the values of K1
    % and K2 calculated for the circumferential direction    
    xK1Rad = zeros(length(StepRad), length(StepCirc));
    xK2Rad = zeros(length(StepRad), length(StepCirc));
    for i=1:length(StepRad)
        xK1Rad(:,i) = round(xK1Circ(i) + xK1Circ(i) * K1Rad * (StepRad - 1),2);
        xK2Rad(:,i) = round(xK2Circ(i) + xK2Circ(i) * K2Rad * (StepRad - 1),2);
    end
end

function EModFibers = CalculateLinRebarStiffnessVariation(numSubregions, numLayers, Lambda, LambdaCirc, LambdaRad)
    EModFibers_0 = 450; % starting Young's modulus
    StepCirc = 1:numSubregions;
    StepRad = 1:numLayers;        
    XLambdaCirc = Lambda + LambdaCirc * Lambda * (StepCirc - 1);
    XLambdaRad = zeros(length(StepRad), length(StepCirc));
    for i=1:length(StepRad)
        XLambdaRad(:,i) = round(XLambdaCirc(i) + XLambdaCirc(i) * LambdaRad * (StepRad - 1),2);
    end
    EModFibers = XLambdaRad * EModFibers_0;
end

function [FiberStrain, FiberStress_0, XLambdaRad] = CalculateNonLinRebarStiffnessVariation(numSubregions, numLayers, Lambda, LambdaCirc, LambdaRad)
    % stress-strain data
    FiberStrain = transpose([-0.9,-0.8,-0.7,-0.6,-0.5,-0.4,-0.3,-0.2,-0.1, ...
        0.00, 0.0147,	0.0294,	0.0441,	0.0588,	0.0735,	0.0882,	0.1029,	0.1176,	0.1324,	0.1471,	0.1618,...
        0.1765,	0.1912,	0.2059, 0.2206,	0.2353,	0.2500,	0.2647,	0.2785,	0.2924,	0.3062,	0.3201,	0.3339,...
        0.3478,	0.3616,	0.3754,	0.3893,	0.4031,	0.4170,	0.4308,	0.4446,	0.4585,	0.4723,	0.4862,	0.5000]);
    
    FiberStress_0 = transpose([-0.00001,-0.00001,-0.00001,-0.00001,-0.00001,-0.00001,-0.00001,-0.00001,-0.00001, ...
        0.00,	13.19,	26.38,	39.57,	49.77,	57.97,	66.17,	73.59,	77.86,	82.14,	86.41,	89.55,...
        92.41,	95.26,	97.54,	98.97,	100.39,	101.82,	103.25,	104.59,	105.93,	107.27,	108.62,	109.96,...
        111.30,	112.64,	113.99,	115.33,	116.67,	118.01,	119.36,	120.70,	122.04,	123.38,	124.73,	126.07]);
    
    StepCirc = 1:numSubregions;
    StepRad = 1:numLayers;        
    XLambdaCirc = Lambda + LambdaCirc * Lambda * (StepCirc - 1);
    XLambdaRad = zeros(length(StepRad), length(StepCirc));
    for i=1:length(StepRad)
        XLambdaRad(:,i) = round(XLambdaCirc(i) + XLambdaCirc(i) * LambdaRad * (StepRad - 1),2);
    end
end

function FiberAngles = CalculateFiberAngles(numSubregions, numLayers, Alpha, AlphaCirc, AlphaRad)
    StepCirc = 1:numSubregions;
    StepRad = 1:numLayers;  
    % Calculate the fiber angles    
    XFiberAngleCirc = Alpha + AlphaCirc * Alpha * (StepCirc - 1);
    XFiberAngleRad = zeros(length(StepRad), length(StepCirc));
    for i=1:length(StepRad)
        XFiberAngleRad(:,i) = XFiberAngleCirc(i) + XFiberAngleCirc(i) * AlphaRad * (StepRad - 1);
    end   
    FiberAngles = XFiberAngleRad;
end