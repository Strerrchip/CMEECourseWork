from pathlib import Path

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from scipy.optimize import curve_fit

project_root = Path(__file__).resolve().parents[1]
data = pd.read_csv(project_root / "data" / "LogisticGrowthData.csv")

group_columns = [
    "Citation", "Species", "Temp", "Medium",
    "Rep", "Time_units", "PopBio_units",
]

groups = list(data.groupby(group_columns, dropna=False, sort=True))
curve_id = 41
_, curve = groups[curve_id - 1]
curve = curve.sort_values("Time").copy()

# Measure time from the first observation.
time_origin = curve["Time"].min()
time = curve["Time"].to_numpy() - time_origin
observed = curve["PopBio"].to_numpy()


def logistic(time, initial_value, growth_rate, capacity):
    """Predict growth with a constant upper limit."""
    return capacity / (
        1 + ((capacity - initial_value) / initial_value)
        * np.exp(-growth_rate * time)
    )


# Starting values help the fitting method find a solution.
starting_values = [observed[0], 0.02, observed.max()]

parameters, covariance = curve_fit(
    logistic,
    time,
    observed,
    p0=starting_values,
    bounds=([1e-8, 0, 1e-8], [np.inf, np.inf, np.inf]),
    maxfev=20000,
)

initial_value, growth_rate, capacity = parameters
predicted = logistic(time, *parameters)
residuals = observed - predicted
rmse = np.sqrt(np.mean(residuals**2))

print(f"Initial OD: {initial_value:.6f}")
print(f"Growth rate (per hour): {growth_rate:.6f}")
print(f"Upper OD limit: {capacity:.6f}")
print(f"RMSE: {rmse:.6f}")

# Show the fitted curve and the remaining errors.
smooth_time = np.linspace(time.min(), time.max(), 300)

fig, axes = plt.subplots(2, 1, figsize=(7, 7), sharex=True)

axes[0].scatter(time, observed, label="Observed data")
axes[0].plot(
    smooth_time,
    logistic(smooth_time, *parameters),
    color="darkorange",
    label="Logistic model",
)
axes[0].set_ylabel("OD at 595 nm")
axes[0].set_title("Enterobacter sp. at 5 °C")
axes[0].legend()

axes[1].scatter(time, residuals)
axes[1].axhline(0, color="black", linewidth=1)
axes[1].set_xlabel("Time since first observation (hours)")
axes[1].set_ylabel("Observed - predicted")

fig.tight_layout()
results_folder = project_root / "results"
results_folder.mkdir(parents=True, exist_ok=True)
fig.savefig(results_folder / "example_logistic_fit.png", dpi=300)
plt.close(fig)

def exponential(time, initial_value, growth_rate):
    """Predict growth without an upper limit."""
    return initial_value * np.exp(growth_rate * time)


exponential_parameters, _ = curve_fit(
    exponential,
    time,
    observed,
    p0=[observed.mean(), 0.001],
    bounds=([1e-8, 0], [np.inf, np.inf]),
    x_scale=[observed.mean(), 0.001],
    maxfev=20000,
)

exponential_predicted = exponential(time, *exponential_parameters)
exponential_residuals = observed - exponential_predicted
exponential_rmse = np.sqrt(np.mean(exponential_residuals**2))

print("\nExponential model")
print(f"Initial OD: {exponential_parameters[0]:.6f}")
print(f"Growth rate (per hour): {exponential_parameters[1]:.6f}")
print(f"RMSE: {exponential_rmse:.6f}")

fig, axes = plt.subplots(2, 1, figsize=(7, 7), sharex=True)

axes[0].scatter(time, observed, label="Observed data", color="black")
axes[0].plot(
    smooth_time,
    logistic(smooth_time, *parameters),
    label="Logistic",
    color="darkorange",
)
axes[0].plot(
    smooth_time,
    exponential(smooth_time, *exponential_parameters),
    label="Exponential",
    color="steelblue",
)
axes[0].set_ylabel("OD at 595 nm")
axes[0].set_title("Enterobacter sp. at 5 °C")
axes[0].legend()

axes[1].scatter(
    time, residuals,
    label="Logistic", color="darkorange",
)
axes[1].scatter(
    time, exponential_residuals,
    label="Exponential", color="steelblue", marker="x",
)
axes[1].axhline(0, color="black", linewidth=1)
axes[1].set_xlabel("Time since first observation (hours)")
axes[1].set_ylabel("Observed - predicted")
axes[1].legend()

fig.tight_layout()
fig.savefig(results_folder / "example_model_comparison.png", dpi=300)
plt.close(fig)
def model_metrics(name, observed, predicted, n_parameters):
    """Compare models fitted to the same observations."""
    n = len(observed)
    rss = np.sum((observed - predicted) ** 2)

    if rss <= 0:
        raise ValueError("RSS must be positive.")

    # Count the fitted error variance as one extra parameter.
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
        "Model": name,
        "n": n,
        "k": k,
        "RSS": rss,
        "RMSE": np.sqrt(rss / n),
        "AIC": aic,
        "AICc": aicc,
        "BIC": bic,
    }


comparison = pd.DataFrame([
    model_metrics("Logistic", observed, predicted, 3),
    model_metrics("Exponential", observed, exponential_predicted, 2),
])

comparison["Delta_AICc"] = comparison["AICc"] - comparison["AICc"].min()
comparison = comparison.sort_values("AICc")

print("\nModel comparison:")
print(comparison.round(4).to_string(index=False))

comparison.to_csv(
    results_folder / "example_model_metrics.csv",
    index=False,
)

def gompertz(time, capacity, shape, rate):
    """Predict an asymmetric growth curve with an upper limit."""
    return capacity * np.exp(-shape * np.exp(-rate * time))


gompertz_parameters, _ = curve_fit(
    gompertz,
    time,
    observed,
    p0=[
        observed.max(),
        np.log(observed.max() / observed[0]),
        0.02,
    ],
    bounds=([1e-8, 1e-8, 1e-8], [np.inf, np.inf, np.inf]),
    maxfev=20000,
)

gompertz_predicted = gompertz(time, *gompertz_parameters)

comparison = pd.DataFrame([
    model_metrics("Logistic", observed, predicted, 3),
    model_metrics("Exponential", observed, exponential_predicted, 2),
    model_metrics("Gompertz", observed, gompertz_predicted, 3),
])

comparison["Delta_AICc"] = comparison["AICc"] - comparison["AICc"].min()
comparison = comparison.sort_values("AICc")

print("\nThree-model comparison:")
print(comparison.round(4).to_string(index=False))
comparison.to_csv(results_folder / "example_model_metrics.csv", index=False)

fig, axes = plt.subplots(2, 1, figsize=(7, 7), sharex=True)
axes[0].scatter(time, observed, color="black", label="Observed data")

models = [
    ("Logistic", logistic, parameters, "darkorange"),
    ("Exponential", exponential, exponential_parameters, "steelblue"),
    ("Gompertz", gompertz, gompertz_parameters, "seagreen"),
]

for name, model, fitted_parameters, color in models:
    axes[0].plot(
        smooth_time,
        model(smooth_time, *fitted_parameters),
        label=name,
        color=color,
    )
    axes[1].scatter(
        time,
        observed - model(time, *fitted_parameters),
        label=name,
        color=color,
        s=20,
    )

axes[0].set_title("Enterobacter sp. at 5 °C")
axes[0].set_ylabel("OD at 595 nm")
axes[0].legend()

axes[1].axhline(0, color="black", linewidth=1)
axes[1].set_xlabel("Time since first observation (hours)")
axes[1].set_ylabel("Observed - predicted")
axes[1].legend()

fig.tight_layout()
fig.savefig(results_folder / "example_three_models.png", dpi=300)
plt.close(fig)