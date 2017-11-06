% gamma  Gamma distribution object
%
% __Syntax__
%
%     F = distribution.Gamma('ShapeScale', Alpha, Beta)
%     F = distribution.Gamma('AlphaBeta', Alpha, Beta)
%     F = distribution.Gamma('MeanVar', Mean, Var)
%     F = distribution.Gamma('MeanStd', Mean, Std)
%     F = distribution.Gamma('ModeVar', Mode, Var)
%     F = distribution.Gamma('ModeStd', Mode, Std)
%
%
% __Input Arguments__
%
% * `Alpha` [ numeric ] - Shape parameter of Gamma distribution.
%
% * `Beta [ numeric ] - Scale parameter of Gamma distribution.
%
% * `Mean` [ numeric ] - Mean of Gamma distribution.
%
% * `Var` [ numeric ] - Variance of Gamma distribution.
%
% * `Std` [ numeric ] - Std deviation of Gamma distribution.
%
% * `Mode` [ numeric ] - Mode of Gamma distribution.
%
%
% __Output Arguments__
%
% * `F` [ function_handle ] - Function handle returning a value
% proportional to the log density of the Gamma distribution, and giving
% access to other characteristics of the Gamma distribution.
%
%
% __Description__
%
% See [help on the `distribution` package](distribution/Contents) for details on
% using the function handle `F`.
%
%
% Example
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

classdef Gamma < distribution.Abstract
    properties (SetAccess=protected)
        Alpha = NaN       % Shape parameter
        Beta = NaN        % Scale parameter
        Constant = NaN    % Integration constant
    end


    methods
        function this = Gamma(varargin)
            this = this@distribution.Abstract(varargin{:});
            this.Name = 'Gamma';
            if nargin==0
                return
            end
            parameterization = varargin{1};
            if strcmpi(parameterization, 'MeanStd')
                fromMeanStd(this, varargin{2:3});
            elseif strcmpi(parameterization, 'MeanVar')
                fromMeanVar(this, varargin{2:3});
            elseif strcmpi(parameterization, 'AlphaBeta') || strcmpi(parameterization, 'ShapeScale')
                fromAlphaBeta(this, varargin{2:3})
            elseif strcmpi(parameterization, 'ModeVar')
                fromModeVar(this, varargin{2:3});
            elseif strcmpi(parameterization, 'ModeStd')
                fromModeStd(this, varargin{2:3});
            else
                throw( ...
                    exception.Base('Distribution:InvalidParameterization', 'error'), ...
                    this.Name, parameterization ...
                );
            end
            if ~isfinite(this.Mean)
                this.Mean = this.Alpha*this.Beta;
            end
            if ~isfinite(this.Mode)
                this.Mode = max(0, (this.Alpha-1)*this.Beta);
            end
            if ~isfinite(this.Std)
                this.Std = sqrt(this.Var);
            end
            this.Shape = this.Alpha;
            this.Scale = this.Beta;
            this.Constant = 1./(this.Beta^this.Alpha * gamma(this.Alpha));
        end


        function fromAlphaBeta(this, varargin)
            [this.Alpha, this.Beta] = varargin{1:2};
            this.Mean = this.Alpha * this.Beta;
            this.Var = this.Alpha * this.Beta.^2;
        end


        function fromMeanStd(this, varargin)
            [this.Mean, this.Std] = varargin{1:2};
            this.Var = this.Std.^2;
            alphaBetaFromMeanVar(this);
        end


        function fromMeanVar(this, varargin)
            [this.Mean, this.Var] = varargin{1:2};
            alphaBetaFromMeanVar(this);
        end


        function fromModeVar(this, varargin)
            [this.Mode, this.Var] = varargin{1:2};
            alphaBetaFromModeVar(this);
        end


        function fromModeStd(this, varargin)
            [this.Mode, this.Std] = varargin{1:2};
            this.Var = this.Std^2;
            alphaBetaFromModeVar(this);
        end


        function alphaBetaFromMeanVar(this)
            this.Beta = this.Var / this.Mean;
            this.Alpha = this.Mean / this.Beta;
        end


        function alphaBetaFromModeVar(this)
            k = this.Mode^2/this.Var + 2;
            this.Alpha = fzero(@(x) x+1/x - k, [1+1e-10, 1e10]);
            this.Beta = this.Mode/(this.Alpha - 1);
        end


        function y = logPdf(this, x)
            y = zeros(size(x));
            indexInDomain = inDomain(this, x);
            x = x(indexInDomain);
            y(indexInDomain) = (this.Alpha - 1)*log(x) - x/this.Beta;
            y(~indexInDomain) = -Inf;
        end


        function indexInDomain = inDomain(this, x)
            indexInDomain = x>0;
        end


        function y = pdf(this, x)
            y = zeros(size(x));
            indexInDomain = inDomain(this, x);
            x = x(indexInDomain);
            y(indexInDomain) = x.^(this.Alpha-1).*exp(-x/this.Beta) * this.Constant;
        end


        function y = info(this, x)
            y = nan(size(x));
            indexInDomain = inDomain(this, x);
            x = x(indexInDomain);
            y(indexInDomain) = (this.Alpha - 1) / x.^2;
        end
    end
end
