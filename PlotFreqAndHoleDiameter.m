%Searches for fundamentals for a given first hole size and then plots the
%fundamentals against hole size


function PlotFreqAndHoleDiameter()
    lambda = 0.026;
    Cp = 1010;
    rho0 = 1.20;
    P0 = 1.01e5;
    gamma = 1.4;
    
    
    len = 229.32e-3-40e-3;
    wallThickness = 0.38e-3;
    radius = 5.21e-3;
    
     % 0 means closed, 1 means open
    holeState = [0; 0; 0; 0; 0; 1];
    
    S = pi*radius*radius;
    K0 = gamma*P0;
    alpha = (gamma-1)*(lambda/(rho0*Cp*S))^0.5;
    K = K0*(1-alpha);
    
    n = 200;
    dx = len/n;
    holeRadii = linspace(0.0e-3, radius, 30);
    
    % for loop over all the holesizes, searching for the first solution. Once
    % found stop and store the found freq, 
    % repeat for all lengths
    freqs = [];
    baseFreq = 0;
    for hole = holeRadii
        % We make a new array of hole radii each step iteration
        rHole = [2.27e-3; 2.6e-3; 2.37e-3; 2.09e-3; 2.7e-3; hole];
        rHolesq = rHole.*rHole;
        freq = 700;
        test = 1000;
        
        % Loop until a frequency is found
        while abs(test) > 2e-4;
           freq = freq + 0.01;

           % Calculate the coefficients for the given frequency and pack them
           % up ready to give the solver
           Zc = -freq*0.2927*sqrt(-1)*rho0*wallThickness/(radius^4);
           Yc = sqrt(-1)*2*pi*pi*freq*wallThickness/K;
           Yo = 1/(9.85*rho0*freq*sqrt(-1));
           params = struct('Zclosed', Zc*(rHolesq.*(1-holeState)),...
                           'Yclosed', Yc*(rHolesq.*(1-holeState)),...
                           'Yopen', Yo*(rHole.*holeState),...
                           'Z0', 2*dx*sqrt(-1)*pi*freq*rho0/S,...
                           'Y0', 2*dx*sqrt(-1)*pi*freq*S/K);

           % The solver gives us arrays for the 3 variables in the system
           [x, P, U] = Solve(n, dx, params, 0, 1);

           % This checks the corrected pressure at the end of the whistle to
           % ensure it's what we want out of a solution
           test = P(n+1) - (sqrt(-1)*1.2266*rho0*freq*U(n+1)/radius);
           test = test/max(P);
        end
        if baseFreq == 0
            baseFreq = freq;
        end
        freqs = [freqs (freq-baseFreq)];
        % Frequency Found, save it and move on to next length
        disp(['Found freq: ' num2str(freq) ' At radius: ' num2str(hole)]);
    end
    
    plot(holeDiameters, freqs);
    title('Frequency change against hole diameters (0 0 0 0 0 1)');
    xlabel('Hole Diameter (m)');
    ylabel('Frequency (Hz)');
end