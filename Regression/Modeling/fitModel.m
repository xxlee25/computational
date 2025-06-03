function [theta_hat, p_values, lower, upper] = fitModel(data, conf, significance)
    alpha = 1 - conf;

    % Configare the model with the given significance mask 
    model = @(theta, X) responseSurfaceModel(theta, significance, X);
    
    % Define the objective function (residuals) 
    fun = @(theta) model(theta, data) - data.growthRate;

    % Number of measurements and parameters
    n_meas = height(data);
    n_theta = sum(significance, "all");  % Number of parameters

    % Degrees of freedom
    df = n_meas - n_theta;
    
    % Fit the model using nonlinear least squares (lsqnonlin)
    [theta_hat, LSE, ~, ~, ~, ~, S] = lsqnonlin(fun, zeros(11, 1));

    S = S(:, significance);

    % Mean Squared Error (MSE)
    MSE = (1./df) * LSE;

    % Fisher Information Matrix (FIM)
    FIM = (1./MSE) * (S' * S);

    % Covariance matrix and Standard Errors
    Cov = inv(FIM);
    STD_vals = sqrt(diag(Cov));
    STD = ones(length(significance), 1);
    STD(significance) = STD_vals;

    % Calculate t-statistics
    t = theta_hat ./ STD;

    % Calculate two-tailed p-values
    p_values = 2 * (1 - tcdf(abs(t), df));

    % Critical t-value for confidence interval
    tcrit = tinv(1 - alpha/2, df);

    % Calculate confidence intervals (lower and upper bounds)
    lower = theta_hat - tcrit * STD;
    upper = theta_hat + tcrit * STD;
    lower = lower(significance);
    upper = upper(significance);
end
