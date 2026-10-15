"""Growth models and comparison metrics used in the project."""

import numpy as np


def exponential(time, initial_value, growth_rate):
    """Predict growth without an upper limit."""
    return initial_value * np.exp(growth_rate * time)


def logistic(time, initial_value, growth_rate, capacity):
    """Predict logistic growth with an upper limit."""
    return capacity / (
        1 + ((capacity - initial_value) / initial_value)
        * np.exp(-growth_rate * time)
    )


def gompertz(time, capacity, shape, rate):
    """Predict an asymmetric growth curve with an upper limit."""
    return capacity * np.exp(-shape * np.exp(-rate * time))


def model_metrics(observed, predicted, n_parameters):
    """Calculate metrics for models fitted to the same observations."""
    observed = np.asarray(observed, dtype=float)
    predicted = np.asarray(predicted, dtype=float)

    if observed.shape != predicted.shape:
        raise ValueError("Observed and predicted values must match.")

    if not (
        np.isfinite(observed).all()
        and np.isfinite(predicted).all()
    ):
        raise ValueError("Values must be finite.")

    n = observed.size
    rss = float(np.sum((observed - predicted) ** 2))

    if n == 0 or rss <= 0:
        raise ValueError("Metrics require data and a positive RSS.")

    # Include the fitted error variance in the parameter count.
    k = n_parameters + 1

    log_likelihood = -0.5 * n * (
        np.log(2 * np.pi) + 1 + np.log(rss / n)
    )

    aic = -2 * log_likelihood + 2 * k
    aicc = (
        aic + 2 * k * (k + 1) / (n - k - 1)
        if n > k + 1 else np.nan
    )
    bic = -2 * log_likelihood + k * np.log(n)

    return {
        "n": n,
        "k": k,
        "RSS": rss,
        "RMSE": np.sqrt(rss / n),
        "AIC": aic,
        "AICc": aicc,
        "BIC": bic,
    }