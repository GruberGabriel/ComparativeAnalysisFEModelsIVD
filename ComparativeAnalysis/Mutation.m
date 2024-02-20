function MutatedChrom=Mutation(OldChrom,Bounds)
    
    % Number of individuals to be mutated and Chromosome length
    n=size(OldChrom); 
    
    % Generate variables
    MutatedChrom=OldChrom;
    
    for i=1:n(1,1)
        % Randomly choose one site on the genetic string
        MutationPoint=((n(1,2)-1)).*rand(1,1) + 1;
        MutationPoint1=round(MutationPoint);% round to nearest integer
        % Generate a new random value for the Point1 considering the bounds
        NewValue=Bounds(1,MutationPoint1)+rand(1,1)*(Bounds(2,MutationPoint1)-Bounds(1,MutationPoint1));
        % Mutate the individual by adding the new characteristic
        MutatedChrom(i,MutationPoint1)=NewValue;
    end

end