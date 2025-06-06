function y = responseSurfaceModel(theta, isON, X)
    % y = theta(1) + ...
    %     theta(2)*X.T + theta(3)*X.pH + theta(4)*X.aW + ...
    %     theta(5)*X.T.^2 + theta(6)*X.pH.^2 + theta(7)*X.aW.^2 + ...
    %     theta(8)*X.T.*X.pH + theta(9)*X.T.*X.aW + theta(10)*X.pH.*X.aW + ...
    %     theta(11)*X.T.*X.pH.*X.aW;
    y = theta(1)*isON(1) + ...
        theta(2)*isON(2)*X.T + ...
        theta(3)*isON(3)*X.pH + ...
        theta(4)*isON(4)*X.aW + ...
        theta(5)*isON(5)*X.T.^2 + ...
        theta(6)*isON(6)*X.pH.^2 + ...
        theta(7)*isON(7)*X.aW.^2 + ...
        theta(8)*isON(8)*X.T.*X.pH + ...
        theta(9)*isON(9)*X.T.*X.aW + ...
        theta(10)*isON(10)*X.pH.*X.aW + ...
        theta(11)*isON(11)*X.T.*X.pH.*X.aW;
end