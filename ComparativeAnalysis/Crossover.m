function CrossedChrom=Crossover(OldChrom,Bounds,NCrossover)
    
    % Number of individuals to be crossed and Chromosome length
    n=size(OldChrom);
    
    % Number of pairs
    n_pairs = floor(n(1,1)/2);
    
    % Define some variables
    Child1=zeros(1,n(1,2));
    Child2=zeros(1,n(1,2));
    CrossedChrom=zeros(NCrossover,n(1,2));
    
    for i=1:n_pairs
        % Parents
        Parent1=OldChrom(2*i-1,:);
        Parent2=OldChrom(2*i,:);
        
        % Check if chromosomes are indentical. If so, apply mutation
        if isequal(Parent1,Parent2)
            MutatedParent=Mutation(Parent2,Bounds);
            % Check if mutation was effective. If not, apply immigration
            if isequal(MutatedParent,Parent2)
                Parent2=Immigration(1,Bounds);
            else
                Parent2=MutatedParent;
            end
        end
    
        % Randomly choose one site on the genetic string
        CrossOverPoint=((n(1,2)-1)-(0+1)).*rand(1,1) + (0+1);  % Original is (b-a).*rand(1,1) + a;
        CrossOverPoint1=round(CrossOverPoint);% round to nearest integer
        
        % Split and combine the characteristics of the parents
        Child1(1:CrossOverPoint1)=Parent1(1:CrossOverPoint1);
        Child1(CrossOverPoint1+1:end)=Parent2(CrossOverPoint1+1:end);
        Child2(1:CrossOverPoint1)=Parent2(1:CrossOverPoint1);
        Child2(CrossOverPoint1+1:end)=Parent1(CrossOverPoint1+1:end);
        
        % Save the new chromosomes
        if NCrossover==1
            CrossedChrom(2*i-1,:)=Child1;
        else
            CrossedChrom(2*i-1,:)=Child1;
            CrossedChrom(2*i,:)=Child2;
        end
    end
    
    % If the Crossover procedure was not effective, try to change the characteristics of the
    % chromossome by applying mutation
    for j=1:NCrossover
        if isequal(CrossedChrom(j,:),OldChrom(j,:))
            MutatedChrom=Mutation(OldChrom(j,:),Bounds);
            CrossedChrom(j,:)=MutatedChrom;
        end
    end

end