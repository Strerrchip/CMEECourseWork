"""Fit three growth models using several starting values per curve."""

import argparse
import json
from pathlib import Path

import numpy as np
import pandas as pd
from scipy.optimize import least_squares

from growth_models import exponential, logistic, gompertz, model_metrics


MODELS = {
    "Exponential": (exponential, ["initial_value", "growth_rate"]),
    "Logistic": (logistic, ["initial_value", "growth_rate", "capacity"]),
    "Gompertz": (gompertz, ["capacity", "shape", "rate"]),
}


def starting_values(name, values):
    """Provide several starting points on the scaled measurement axis."""
    initial = max(float(values[0]), 0.01)
    if name == "Exponential":
        return [[max(float(values.mean()), 0.01), r] for r in [0.1, 1, 3]]
    if name == "Logistic":
        return [[initial, r, k] for r in [1, 5, 20] for k in [1, 2]]
    return [[k, b, r] for k in [1, 2] for b in [1, 4] for r in [1, 5, 20]]


def fit_one_model(name, time, observed, max_nfev=2000):
    """Keep the converged solution with the lowest squared error."""
    model, parameter_names = MODELS[name]
    duration = float(time.max())
    value_scale = float(np.max(np.abs(observed)))
    if duration <= 0 or value_scale <= 0:
        raise ValueError("Time span and measurement scale must be positive.")

    # Scaling improves numerical fitting. Report parameters in original units.
    scaled_time = time / duration
    scaled_values = observed / value_scale

    def residual_function(parameters):
        with np.errstate(over="raise", divide="raise", invalid="raise"):
            return model(scaled_time, *parameters) - scaled_values

    best = None
    best_rss = np.inf
    attempts = []
    guesses = starting_values(name, scaled_values)

    for guess in guesses:
        try:
            fitted = least_squares(
                residual_function,
                guess,
                bounds=(np.full(len(guess), 1e-10), np.inf),
                x_scale="jac",
                max_nfev=max_nfev,
            )
            rss = float(np.sum(fitted.fun ** 2))
            valid = bool(fitted.success and np.isfinite(rss))
            attempts.append({
                "start": json.dumps(guess),
                "converged": valid,
                "message": str(fitted.message),
            })
            if valid and rss < best_rss:
                best, best_rss = fitted, rss
        except (ValueError, RuntimeError, FloatingPointError,
                OverflowError, np.linalg.LinAlgError) as error:
            attempts.append({
                "start": json.dumps(guess),
                "converged": False,
                "message": str(error),
            })

    if best is None:
        return {
            "status": "failed", "n_starts": len(guesses),
            "RMSE": np.nan, "AIC": np.nan, "AICc": np.nan,
            "BIC": np.nan, "numerical_review": True,
        }, None, attempts

    parameters = best.x.copy()
    if name == "Exponential":
        parameters *= [value_scale, 1 / duration]
    elif name == "Logistic":
        parameters *= [value_scale, 1 / duration, value_scale]
    else:
        parameters *= [value_scale, 1, 1 / duration]

    # Predictions come from the scaled fit to avoid unnecessary large numbers.
    prediction = model(scaled_time, *best.x) * value_scale
    metrics = model_metrics(observed, prediction, len(parameters))

    rank = int(np.linalg.matrix_rank(best.jac))
    condition = float(np.linalg.cond(best.jac))
    near_lower_bound = bool(np.any(best.x <= 1e-8))
    numerical_review = (
        rank < len(parameters)
        or not np.isfinite(condition)
        or condition > 1e8
        or near_lower_bound
    )

    row = {
        "status": "converged",
        **metrics,
        "n_starts": len(guesses),
        "n_converged_starts": sum(a["converged"] for a in attempts),
        "jacobian_rank": rank,
        "jacobian_condition": condition,
        "near_lower_bound": near_lower_bound,
        "numerical_review": numerical_review,
        **dict(zip(parameter_names, parameters)),
    }
    return row, prediction, attempts


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--curve", help="Fit one curve, for example C041.")
    parser.add_argument("--limit", type=int, help="Fit only the first N curves.")
    parser.add_argument("--max-nfev", type=int, default=2000,
                        help="Maximum function evaluations per starting point.")
    parser.add_argument("--retry-failed", action="store_true",
                        help="Retry failed model-curve pairs from results/batch.")
    args = parser.parse_args()
    if args.limit is not None and args.limit < 1:
        parser.error("--limit must be positive.")
    if args.max_nfev < 1:
        parser.error("--max-nfev must be positive.")

    project_root = Path(__file__).resolve().parents[1]
    results_folder = project_root / "results"
    data = pd.read_csv(results_folder / "prepared_growth_data.csv")
    screening = pd.read_csv(results_folder / "fit_screening.csv")
    eligible = screening["eligible_for_comparison"].astype(str).str.lower().eq("true")
    selected = screening.loc[eligible, "curve_id"].tolist()
    retry_pairs = None
    if args.retry_failed:
        previous = pd.read_csv(results_folder / "batch" / "model_fits.csv")
        failed = previous.loc[previous["status"].eq("failed")]
        retry_pairs = set(zip(failed["curve_id"], failed["model"]))
        selected = [identifier for identifier in selected
                    if identifier in set(failed["curve_id"])]
    if args.curve:
        selected = [identifier for identifier in selected if identifier == args.curve]
    if args.limit:
        selected = selected[:args.limit]
    if not selected:
        raise ValueError("No eligible curves match the requested selection.")

    output_folder = results_folder / (
        f"retry_failed_{args.max_nfev}" if args.retry_failed else
        f"check_{args.curve}" if args.curve else
        f"check_first_{args.limit}" if args.limit else "batch"
    )
    output_folder.mkdir(parents=True, exist_ok=True)
    rows, predictions, all_attempts = [], [], []

    for position, identifier in enumerate(selected, start=1):
        curve = data.loc[data["curve_id"] == identifier].sort_values("Time")
        time = curve["time_since_first"].to_numpy(dtype=float)
        observed = curve["PopBio"].to_numpy(dtype=float)
        for name in MODELS:
            if retry_pairs is not None and (identifier, name) not in retry_pairs:
                continue
            row, prediction, attempts = fit_one_model(
                name, time, observed, max_nfev=args.max_nfev
            )
            rows.append({"curve_id": identifier, "model": name, **row})
            all_attempts.extend(
                {"curve_id": identifier, "model": name, **attempt}
                for attempt in attempts
            )
            if prediction is not None:
                table = curve[["curve_id", "Time", "time_since_first", "PopBio"]].copy()
                table["model"] = name
                table["predicted"] = prediction
                table["residual"] = observed - prediction
                predictions.append(table)
        print(f"Completed {position}/{len(selected)}: {identifier}", flush=True)

    fits = pd.DataFrame(rows)
    if args.retry_failed:
        # Retry files contain only failed pairs, so a ranking would be misleading.
        fits["Delta_AICc"] = np.nan
    else:
        fits["Delta_AICc"] = fits["AICc"] - fits.groupby("curve_id")["AICc"].transform("min")
    fits.to_csv(output_folder / "model_fits.csv", index=False)
    pd.DataFrame(all_attempts).to_csv(output_folder / "fit_attempts.csv", index=False)
    if predictions:
        pd.concat(predictions, ignore_index=True).to_csv(
            output_folder / "predictions.csv", index=False
        )

    print("\nFitting status:")
    print(fits.groupby(["model", "status"]).size().to_string())
    if len(selected) == 1:
        print("\nModel comparison:")
        print(fits[["model", "RMSE", "AICc", "Delta_AICc", "numerical_review"]]
              .sort_values("AICc").round(4).to_string(index=False))
    print(f"\nSaved results to: {output_folder}")
    print("Convergence alone does not show that a model is suitable.")


if __name__ == "__main__":
    main()
