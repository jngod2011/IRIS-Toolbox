function s = prepareSimulate2(this, s, variantRequested)
% prepareSimulate2  Prepare i-th simulation round.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

ixe = this.Quantity.Type==int8(31) | this.Quantity.Type==int8(32);
ne = sum(ixe);
nn = sum(this.Equation.IxHash);
lastEa = s.LastEa;
lastEndgA = s.LastEndgA;
nPerNonlin = s.NPerNonlin;
nName = length(this.Quantity.Name);

% __Loop-Dependent Fields__
% Current values of parameters and steady states.
s.Update = model.IterateOver( );
s.Update.Quantity = this.Variant.Values(:, :, variantRequested);
s.Update.StdCorr = this.Variant.StdCorr(:, :, variantRequested);

% Solution matrices expanded forward if needed.
forward = max([1, lastEa, lastEndgA, nPerNonlin]) - 1;
if isequal(s.Method, 'selective')
    [s.T, s.R, s.K, s.Z, s.H, s.D, s.U, ~, ~, s.Q] = sspaceMatrices(this, variantRequested);
    if forward>0
        [s.R, s.Q] = expandFirstOrder(this, variantRequested, forward);
    end
else
    [s.T, s.R, s.K, s.Z, s.H, s.D, s.U] = sspaceMatrices(this, variantRequested);
    if forward>0
        s.R = expandFirstOrder(this, variantRequested, forward);
    end
end

% Effect of nonlinear add-factors in selective nonlinear simulations.
nPerMax = s.NPer;
if isequal(s.Method, 'selective')
    nPerMax = nPerMax + s.NPerNonlin - 1;
end

% Get steady state lines that will be added to simulated paths to evaluate
% nonlinear equations; the steady state lines include pre-sample init cond.
if isequal(s.Method, 'selective')
    if s.IsDeviation && s.IsAddSstate
        isDelog = false;
        s.XBar = createTrendArray(this, variantRequested, ...
            isDelog, this.Vector.Solution{2}, 0:nPerMax);
        s.YBar = createTrendArray(this, variantRequested, ...
            isDelog, this.Vector.Solution{1}, 0:nPerMax);
    end
end

if s.IsRevision || isequal(s.Method, 'selective')
    % Steady state references.
    minSh = this.Incidence.Dynamic.Shift(1);
    maxSh = this.Incidence.Dynamic.Shift(end);
    s.MinT = minSh;
    isDelog = true;
    id = 1 : nName;
    tVec = (1+minSh) : (nPerMax+maxSh);
    s.L = createTrendArray(this, variantRequested, isDelog, id, tVec);
end

end