function [AF,VF,DV] = autocov_to_var_test(G)

[n,~,q1] = size(G);
q = q1-1;
qn = q*n;

G0 = G(:,:,1);                                               % covariance
GF = reshape(G(:,:,2:end),n,qn)';                            % forward  autocov sequence
GB = reshape(permute(flipdim(G(:,:,2:end),3),[1 3 2]),qn,n); % backward autocov sequence

AF = zeros(n,qn); % forward  coefficients
AB = zeros(n,qn); % backward coefficients (reversed compared with Whittle's treatment)

% initialise recursion

k = 1;            % model order

VB = G0;          % forward  residuals covariance
VF = G0;          % backward residuals covariance

DV = zeros(1,q);

r = q-k;
kf = 1:k*n;       % forward  indices
kb = r*n+1:qn;    % backward indices

AF(:,kf) = GB(kb,:)/VB; % forward  coefficients = DF/VB
AB(:,kb) = GF(kf,:)/VF; % backward coefficients = DB/VF

% and loop

for k=2:q
    
    OVF = VF;
    
    VB = (G0-AB(:,kb)*GB(kb,:));
    VF = (G0-AF(:,kf)*GF(kf,:));
    
    DV(k-1) = norm(VF-OVF)/norm(VF);
    
    AAF = (GB((r-1)*n+1:r*n,:)-AF(:,kf)*GB(kb,:))/VB; % DF/VB
    AAB = (GF((k-1)*n+1:k*n,:)-AB(:,kb)*GF(kf,:))/VF; % DB/VF

    AFPREV = AF(:,kf);
    ABPREV = AB(:,kb);

    r = q-k;
    kf = 1:k*n;
    kb = r*n+1:qn;

    AF(:,kf) = [AFPREV-AAF*ABPREV AAF];
    AB(:,kb) = [AAB ABPREV-AAB*AFPREV];

end

OVF = VF;

VF = G0-AF*GF;
    
DV(q) = norm(VF-OVF)/norm(VF);

AF = reshape(AF,n,n,q);