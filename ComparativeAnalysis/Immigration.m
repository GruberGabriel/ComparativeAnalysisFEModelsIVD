function ImmigratedChrom=Immigration(N,Bounds)
    % return empty array if number of immigrated chromosomes = 0
    if N == 0
        ImmigratedChrom = [];
    else
        % Create some variables
        NewChrom=zeros;
        ImmigratedChrom=zeros(size(Bounds(1,:)));
        
        % Generate a new random individual considering the bounds
        for j=1:N
            for i=1:size(Bounds,2)
                NewChrom(:,i)=Bounds(1,i)+rand(1,1)*(Bounds(2,i)-Bounds(1,i));
            end
            ImmigratedChrom(j,:)=NewChrom;
        end
    end
end