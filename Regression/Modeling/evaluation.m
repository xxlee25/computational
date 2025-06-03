function rmse = evaluation(model, val_data)
    y = val_data.growthRate;
    y_hat = model(val_data);
    rmse = sqrt(mean((y - y_hat).^2));
end